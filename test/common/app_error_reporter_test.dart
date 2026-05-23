import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_error_reporter.dart';
import 'package:github_client_app/common/log_file_sink.dart';

void main() {
  test(
    'AppErrorReporter 对 build/render 类 FlutterError 保留 presentError 并标记局部兜底',
    () async {
      final _MemoryLogFileSink sink = _MemoryLogFileSink();
      FlutterErrorDetails? presentedDetails;
      final AppErrorReporter reporter = AppErrorReporter(
        fileSink: sink,
        presentFlutterError: (FlutterErrorDetails details) {
          presentedDetails = details;
        },
      );
      addTearDown(reporter.restore);

      reporter.install();

      final FlutterErrorDetails details = FlutterErrorDetails(
        exception: StateError('flutter failed'),
        stack: StackTrace.fromString('flutter-stack'),
        library: 'widgets library',
        context: ErrorDescription('while building test widget'),
      );

      FlutterError.onError?.call(details);
      await Future<void>.delayed(Duration.zero);

      expect(presentedDetails, same(details));
      expect(sink.records, hasLength(1));
      expect(sink.records.single.source, 'flutter');
      expect(
        sink.records.single.presentationPreference,
        AppErrorPresentationPreference.fallbackUiOnly,
      );
      expect(sink.records.single.details, contains('widgets library'));
    },
  );

  test('AppErrorReporter 对非 build/render 的 FlutterError 保持全局展示优先', () async {
    final _MemoryLogFileSink sink = _MemoryLogFileSink();
    final AppErrorReporter reporter = AppErrorReporter(fileSink: sink);
    addTearDown(reporter.restore);

    reporter.install();

    final FlutterErrorDetails details = FlutterErrorDetails(
      exception: StateError('scheduler failed'),
      stack: StackTrace.fromString('scheduler-stack'),
      library: 'scheduler library',
      context: ErrorDescription('during a scheduler callback'),
    );

    FlutterError.onError?.call(details);
    await Future<void>.delayed(Duration.zero);

    expect(sink.records, hasLength(1));
    expect(sink.records.single.source, 'flutter');
    expect(
      sink.records.single.presentationPreference,
      AppErrorPresentationPreference.reminderPagePreferred,
    );
    expect(sink.records.single.details, contains('scheduler library'));
  });

  test('AppErrorReporter 通过 guardBootstrap 归一化 zone 错误', () async {
    final _MemoryLogFileSink sink = _MemoryLogFileSink();
    final AppErrorReporter reporter = AppErrorReporter(fileSink: sink);
    reporter.install();

    await reporter.guardBootstrap(() async {
      throw StateError('zone failed');
    });
    await Future<void>.delayed(Duration.zero);
    reporter.restore();

    expect(sink.records, hasLength(1));
    expect(sink.records.single.source, 'zone');
    expect(sink.records.single.error.toString(), contains('zone failed'));
  });

  test('AppErrorReporter 安装 PlatformDispatcher 钩子后返回 true 并写入 sink', () async {
    final _MemoryLogFileSink sink = _MemoryLogFileSink();
    final AppErrorReporter reporter = AppErrorReporter(fileSink: sink);
    addTearDown(reporter.restore);

    reporter.install();

    final bool handled = PlatformDispatcher.instance.onError!(
      StateError('platform failed'),
      StackTrace.fromString('platform-stack'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(handled, isTrue);
    expect(sink.records, hasLength(1));
    expect(sink.records.single.source, 'platform');
    expect(
      sink.records.single.stackTrace.toString(),
      contains('platform-stack'),
    );
  });

  test('AppErrorReporter 会在记录后触发展示回调，且展示失败不影响记录', () async {
    final _MemoryLogFileSink sink = _MemoryLogFileSink();
    final List<AppErrorRecord> presentedRecords = <AppErrorRecord>[];
    final AppErrorReporter reporter = AppErrorReporter(
      fileSink: sink,
      errorPresentationHandler: (AppErrorRecord record) async {
        presentedRecords.add(record);
        throw StateError('presentation failed');
      },
    );

    await reporter.reportZoneError(
      StateError('zone failed for presentation'),
      StackTrace.fromString('zone-stack'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(sink.records, hasLength(1));
    expect(presentedRecords, hasLength(1));
    expect(sink.records.single.summary, contains('zone failed'));
  });
}

class _MemoryLogFileSink extends LogFileSink {
  _MemoryLogFileSink();

  final List<AppErrorRecord> records = <AppErrorRecord>[];

  @override
  Future<void> write(AppErrorRecord record) async {
    records.add(record);
  }
}
