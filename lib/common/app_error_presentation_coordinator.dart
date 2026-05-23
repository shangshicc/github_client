import 'package:flutter/foundation.dart';
import 'package:github_client_app/common/app_error_reporter.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/router/app_route_paths.dart';

final _log = createLogger('AppErrorPresentationCoordinator');

/// 全局异常展示决策。
enum AppErrorPresentationDecision {
  /// 忽略本次全局展示请求。
  ignore,

  /// 已成功发起统一异常提醒页的展示请求。
  requestShowReminderPage,
}

/// 全局异常展示协调器。
///
/// 只负责“展示意图 + 重入保护”，不处理日志与文件落盘。
class AppErrorPresentationCoordinator {
  /// 创建协调器。
  AppErrorPresentationCoordinator({
    required void Function(String location, {Object? extra}) navigate,
    required String Function() currentLocation,
    String? reminderPath,
  }) : _navigate = navigate,
       _currentLocation = currentLocation,
       _reminderPath = reminderPath ?? AppRoutePaths.errorReminder;

  final void Function(String location, {Object? extra}) _navigate;
  final String Function() _currentLocation;
  final String _reminderPath;

  bool _isReminderVisible = false;

  /// 请求展示统一异常提醒页。
  ///
  /// 如果提醒页已经在显示，则返回忽略；如果路由可用则跳转，
  /// 否则降级为最小兜底 UI。
  AppErrorPresentationDecision present(AppErrorRecord record) {
    if (record.presentationPreference ==
        AppErrorPresentationPreference.fallbackUiOnly) {
      _log.i(
        'skip global reminder presentation and keep local fallback only, '
        'source=${record.source}, target=$_reminderPath',
      );
      return AppErrorPresentationDecision.ignore;
    }

    final String currentLocation = _currentLocation();
    if (currentLocation == _reminderPath) {
      _isReminderVisible = true;
      _log.i(
        'ignore duplicate presentation, source=${record.source}, '
        'location=$currentLocation',
      );
      return AppErrorPresentationDecision.ignore;
    }
    if (_isReminderVisible) {
      _log.i(
        'ignore reentrant presentation, source=${record.source}, '
        'location=$currentLocation',
      );
      return AppErrorPresentationDecision.ignore;
    }

    try {
      _isReminderVisible = true;
      _navigate(_reminderPath);
      _log.i(
        'request reminder page navigation, source=${record.source}, '
        'target=$_reminderPath',
      );
      return AppErrorPresentationDecision.requestShowReminderPage;
    } catch (error, stackTrace) {
      _isReminderVisible = false;
      _log.w(
        'skip reminder presentation because navigation failed, '
        'source=${record.source}, '
        'target=$_reminderPath',
        error: error,
        stackTrace: stackTrace,
      );
      return AppErrorPresentationDecision.ignore;
    }
  }

  /// 关闭提醒页状态。
  void dismiss() {
    _isReminderVisible = false;
  }

  /// 仅用于测试的当前显示状态。
  @visibleForTesting
  bool get isReminderVisible => _isReminderVisible;
}

/// 全局协调器单例，由 main.dart 初始化并由错误页复用。
AppErrorPresentationCoordinator? appErrorPresentationCoordinator;
