import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'log_file_sink.dart';
import 'logger.dart';

/// 统一描述一条应用级错误记录。
class AppErrorRecord {
  /// 创建错误记录。
  ///
  /// [timestamp] 表示记录生成时间。
  /// [source] 表示错误来源，例如 flutter/zone/platform。
  /// [error] 表示原始错误对象。
  /// [stackTrace] 表示错误栈。
  /// [summary] 表示便于快速检索的摘要。
  /// [details] 表示补充说明，例如 FlutterError 的 library/context。
  AppErrorRecord({
    required this.timestamp,
    required this.source,
    required this.error,
    required this.stackTrace,
    required this.summary,
    this.details,
  });

  /// 记录生成时间。
  final DateTime timestamp;

  /// 错误来源。
  final String source;

  /// 原始错误对象。
  final Object error;

  /// 错误堆栈。
  final StackTrace stackTrace;

  /// 便于快速检索的摘要。
  final String summary;

  /// 补充说明。
  final String? details;

  /// 将错误记录转换为可持久化的结构。
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'error': error.toString(),
      'summary': summary,
      'details': details,
      'stackTrace': stackTrace.toString(),
    };
  }
}

/// 负责接入 Flutter/Dart 层的全局异常入口并统一分发。
///
/// 当前仅覆盖 FlutterError、runZonedGuarded 与 root isolate 的
/// PlatformDispatcher.onError，不覆盖原生 crash 深度采集，也不会自动接管
/// 非 root isolate 的未处理异常。
class AppErrorReporter {
  /// 创建错误上报器。
  ///
  /// [logger] 用于输出控制台日志。
  /// [fileSink] 用于将错误追加写入本地文件。
  /// [platformDispatcher] 允许在测试中注入伪对象；默认使用全局实例。
  /// [presentFlutterError] 保留 Flutter 默认错误展示能力。
  AppErrorReporter({
    Logger? logger,
    LogFileSink? fileSink,
    PlatformDispatcher? platformDispatcher,
    void Function(FlutterErrorDetails details)? presentFlutterError,
  }) : _logger = logger ?? createLogger('AppErrorReporter'),
       _fileSink = fileSink ?? LogFileSink(),
       _platformDispatcher = platformDispatcher ?? PlatformDispatcher.instance,
       _presentFlutterError = presentFlutterError ?? FlutterError.presentError;

  final Logger _logger;
  final LogFileSink _fileSink;
  final PlatformDispatcher _platformDispatcher;
  final void Function(FlutterErrorDetails details) _presentFlutterError;

  FlutterExceptionHandler? _previousFlutterErrorHandler;
  ErrorCallback? _previousPlatformErrorHandler;
  bool _isInstalled = false;

  /// 安装 FlutterError 与 PlatformDispatcher 的全局钩子。
  void install() {
    if (_isInstalled) {
      return;
    }
    _previousFlutterErrorHandler = FlutterError.onError;
    _previousPlatformErrorHandler = _platformDispatcher.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      _presentFlutterError(details);
      // unawaited：消除 unawaited_futures 警告
      unawaited(reportFlutterError(details));
    };

    _platformDispatcher.onError = (Object error, StackTrace stackTrace) {
      unawaited(reportPlatformError(error, stackTrace));
      return true;
    };

    _isInstalled = true;
  }

  /// 恢复安装前的全局错误钩子，避免污染其他测试或运行上下文。
  void restore() {
    if (!_isInstalled) {
      return;
    }
    FlutterError.onError = _previousFlutterErrorHandler;
    _platformDispatcher.onError = _previousPlatformErrorHandler;
    _isInstalled = false;
  }

  /// 以统一错误保护运行应用启动流程。
  ///
  /// [bootstrap] 表示实际启动逻辑，例如初始化全局状态并调用 runApp。
  Future<void> run(Future<void> Function() bootstrap) async {
    install();
    final Completer<void> completer = Completer<void>();

    //全局异常捕获方法
    runZonedGuarded(
      () async {
        try {
          await bootstrap();
        } catch (error, stackTrace) {
          await reportZoneError(error, stackTrace);
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      // 错误处理器，处理未捕获的异常
      (Object error, StackTrace stackTrace) {
        unawaited(reportZoneError(error, stackTrace));
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  /// 上报 Flutter 框架层错误。
  Future<void> reportFlutterError(FlutterErrorDetails details) {
    return report(
      AppErrorRecord(
        timestamp: DateTime.now(),
        source: 'flutter',
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
        summary: details.exceptionAsString(),
        details: _buildFlutterDetails(details),
      ),
    );
  }

  /// 上报 zone 未处理错误。
  Future<void> reportZoneError(Object error, StackTrace stackTrace) {
    return report(
      AppErrorRecord(
        timestamp: DateTime.now(),
        source: 'zone',
        error: error,
        stackTrace: stackTrace,
        summary: error.toString(),
      ),
    );
  }

  /// 上报 root isolate / PlatformDispatcher 错误。
  Future<void> reportPlatformError(Object error, StackTrace stackTrace) {
    return report(
      AppErrorRecord(
        timestamp: DateTime.now(),
        source: 'platform',
        error: error,
        stackTrace: stackTrace,
        summary: error.toString(),
      ),
    );
  }

  /// 执行统一日志输出与文件落盘。
  ///
  /// [record] 表示待输出的错误记录。
  Future<void> report(AppErrorRecord record) async {
    _logger.e(
      '[${record.source}] ${record.summary}',
      error: record.error,
      stackTrace: record.stackTrace,
    );
    await _fileSink.write(record);
  }

  String _buildFlutterDetails(FlutterErrorDetails details) {
    final List<String> segments = <String>[];
    if (details.library != null && details.library!.trim().isNotEmpty) {
      segments.add('library=${details.library}');
    }
    if (details.context != null) {
      segments.add('context=${details.context}');
    }
    if (details.informationCollector != null) {
      final Iterable<DiagnosticsNode> nodes =
          details.informationCollector!.call();
      final String information = nodes
          .map((DiagnosticsNode node) => node.toDescription())
          .join(' | ');
      if (information.trim().isNotEmpty) {
        segments.add('information=$information');
      }
    }
    return segments.join(' ; ');
  }
}
