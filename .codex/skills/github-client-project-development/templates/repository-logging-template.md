# Repository 日志模板

适用于：

- Repository
- Service
- 数据层请求封装
- 本地缓存读写
- 远程请求 + 结果转换

## 推荐结构

```dart
import 'package:github_client_app/common/logger.dart';

final _log = createLogger('[ModuleRepository]');

class ModuleRepository {
  /// 请求远程列表数据。
  ///
  /// [username] 表示目标用户名。
  /// [page] 表示请求页码。
  /// [pageSize] 表示每页数量。
  Future<List<dynamic>> fetchList({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    _log.d(
      'List request started, username=$username, page=$page, pageSize=$pageSize',
    );

    try {
      final response = await _requestRemoteData(
        username: username,
        page: page,
        pageSize: pageSize,
      );

      if (response.isEmpty) {
        _log.w('List request returned empty result, username=$username, page=$page');
        return <dynamic>[];
      }

      _log.i(
        'List request completed, count=${response.length}, username=$username, page=$page',
      );

      return response;
    } catch (error, stackTrace) {
      _log.e(
        'List request failed, username=$username, page=$page',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 从本地缓存读取数据。
  ///
  /// [cacheKey] 表示缓存键名。
  Future<List<dynamic>> readCache({
    required String cacheKey,
  }) async {
    _log.d('Cache read started, key=$cacheKey');

    try {
      final cache = await _readLocalCache(cacheKey: cacheKey);

      if (cache.isEmpty) {
        _log.w('Cache miss, key=$cacheKey');
        return <dynamic>[];
      }

      _log.i('Cache read completed, key=$cacheKey, count=${cache.length}');
      return cache;
    } catch (error, stackTrace) {
      _log.e(
        'Cache read failed, key=$cacheKey',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 远程请求实现。
  ///
  /// [username] 表示目标用户名。
  /// [page] 表示请求页码。
  /// [pageSize] 表示每页数量。
  Future<List<dynamic>> _requestRemoteData({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    return <dynamic>[];
  }

  /// 本地缓存读取实现。
  ///
  /// [cacheKey] 表示缓存键名。
  Future<List<dynamic>> _readLocalCache({
    required String cacheKey,
  }) async {
    return <dynamic>[];
  }
}
```

## 使用说明

- 请求前记录必要参数摘要，不打印敏感头信息。
- 请求成功后记录结果摘要，如 count、页码、是否为空。
- 空态要记录 warning，便于区分“成功但无数据”和“请求失败”。
- catch 中统一输出 error，并尽量保留 stackTrace。
- 如果当前仓储已存在统一异常转换逻辑，沿用现有模式。
