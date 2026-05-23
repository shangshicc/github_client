import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_error_reporter.dart';
import 'package:github_client_app/common/log_file_sink.dart';

void main() {
  test(
    'AppErrorReporter 安装 FlutterError 钩子时会保留 presentError 并写入 sink',
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
      expect(sink.records.single.details, contains('widgets library'));
    },
  );

  test('AppErrorReporter 通过 runZonedGuarded 归一化 zone 错误', () async {
    final _MemoryLogFileSink sink = _MemoryLogFileSink();
    final AppErrorReporter reporter = AppErrorReporter(fileSink: sink);

    await reporter.run(() async {
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
}

class _MemoryLogFileSink extends LogFileSink {
  _MemoryLogFileSink();

  final List<AppErrorRecord> records = <AppErrorRecord>[];

  @override
  Future<void> write(AppErrorRecord record) async {
    records.add(record);
  }
}
