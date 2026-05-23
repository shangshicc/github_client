import 'dart:convert';
import 'dart:io';

import 'app_error_reporter.dart';

/// 将错误记录追加写入本地日志文件。
class LogFileSink {
  /// 创建日志文件落盘对象。
  ///
  /// [baseDirectory] 表示日志根目录；默认使用系统临时目录。
  /// [directoryName] 表示日志子目录名称。
  /// [fileName] 表示日志文件名称。
  LogFileSink({
    Directory? baseDirectory,
    this.directoryName = 'github_client_logs',
    this.fileName = 'app_errors.log',
  }) : _baseDirectory = baseDirectory ?? Directory.systemTemp;

  final Directory _baseDirectory;

  /// 日志子目录名称。
  final String directoryName;

  /// 日志文件名称。
  final String fileName;

  /// 返回当前日志文件对象；若目录不存在会自动创建。
  Future<File> getLogFile() async {
    final Directory directory = Directory(
      _joinPath(_baseDirectory.path, directoryName),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File(_joinPath(directory.path, fileName));
  }

  /// 将一条错误记录追加写入本地文件。
  ///
  /// [record] 表示待持久化的错误记录。
  Future<void> write(AppErrorRecord record) async {
    final File file = await getLogFile();
    await file.writeAsString(
      '${jsonEncode(record.toJson())}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  String _joinPath(String left, String right) {
    if (left.endsWith(Platform.pathSeparator)) {
      return '$left$right';
    }
    return '$left${Platform.pathSeparator}$right';
  }
}
