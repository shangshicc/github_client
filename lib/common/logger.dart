import 'package:logger/logger.dart';

import 'global.dart';

/// 默认 Logger 的缓存 key。
const String _defaultLoggerCacheKey = '__default_logger__';

/// 按模块名缓存 Logger 实例，避免重复创建同名日志对象。
final Map<String, Logger> _loggerCache = <String, Logger>{};

/// 创建带统一配置的 Logger 实例，供各模块使用。
///
/// [name] 为模块标识，允许为空。
/// - 当 [name] 为 `null`、空字符串或仅包含空白字符时，返回默认 Logger。
/// - 当 [name] 有效时，按模块名缓存并复用对应 Logger。
Logger createLogger([String? name]) {
  final String cacheKey = _normalizeLoggerCacheKey(name);

  return _loggerCache.putIfAbsent(cacheKey, () {
    return Logger(
      filter: AppLogFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  });
}

/// 规范化 Logger 缓存 key。
///
/// [name] 表示传入的模块名。
/// 当 [name] 为 `null`、空字符串或仅包含空白字符时，返回默认缓存 key。
String _normalizeLoggerCacheKey(String? name) {
  final String? normalizedName = name?.trim();
  if (normalizedName == null || normalizedName.isEmpty) {
    return _defaultLoggerCacheKey;
  }
  return normalizedName;
}

/// 根据 [Global.isRelease] 过滤日志级别。
///
/// 开发模式允许所有级别；release 模式仅允许 warning 及以上，避免线上打印敏感调试信息。
class AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (Global.isRelease) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
