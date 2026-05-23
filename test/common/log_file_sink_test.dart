import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_error_reporter.dart';
import 'package:github_client_app/common/log_file_sink.dart';

void main() {
  test('LogFileSink 会追加写入错误记录而不是覆盖', () async {
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'github_client_log_sink_test_',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final LogFileSink sink = LogFileSink(baseDirectory: tempDirectory);

    await sink.write(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 9, 0),
        source: 'zone',
        error: StateError('first'),
        stackTrace: StackTrace.fromString('stack-1'),
        summary: 'first error',
      ),
    );
    await sink.write(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 9, 1),
        source: 'flutter',
        error: StateError('second'),
        stackTrace: StackTrace.fromString('stack-2'),
        summary: 'second error',
      ),
    );

    final File logFile = await sink.getLogFile();
    final List<String> lines = await logFile.readAsLines();

    expect(lines, hasLength(2));

    final Map<String, dynamic> firstLine =
        jsonDecode(lines.first) as Map<String, dynamic>;
    final Map<String, dynamic> secondLine =
        jsonDecode(lines.last) as Map<String, dynamic>;

    expect(firstLine['source'], 'zone');
    expect(firstLine['error'], contains('first'));
    expect(secondLine['source'], 'flutter');
    expect(secondLine['stackTrace'], contains('stack-2'));
  });
}
