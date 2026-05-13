# Provider 日志模板

适用于：

- ChangeNotifier
- 页面状态管理
- 列表分页
- 刷新 / 加载更多 / 重试
- 带 loading / empty / error 的状态流转

## 推荐结构

```dart
import 'package:flutter/foundation.dart';
import 'package:github_client_app/common/logger.dart';

final _log = createLogger('[ModuleProvider]');

class ModuleProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _page = 1;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// 首次加载数据。
  ///
  /// [username] 表示目标用户名。
  Future<void> loadInitialData({
    required String username,
  }) async {
    if (_isLoading) {
      _log.w('当前正在加载中，忽略首次加载请求，username: $username');
      return;
    }

    _log.i('开始初始化加载，username: $username');

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _page = 1;
      _log.d('准备请求首页数据，username: $username, page: $_page');

      final result = await _fetchData(
        username: username,
        page: _page,
      );

      if (result.isEmpty) {
        _log.w('初始化加载结果为空，username: $username');
      } else {
        _log.i('初始化加载成功，count: ${result.length}, username: $username');
      }

      _hasMore = result.isNotEmpty;
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = '加载失败';
      _log.e(
        '初始化加载失败，username: $username, page: $_page, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 下拉刷新数据。
  ///
  /// [username] 表示目标用户名。
  Future<void> refreshData({
    required String username,
  }) async {
    if (_isLoading) {
      _log.w('当前正在加载中，忽略刷新请求，username: $username');
      return;
    }

    _log.i('开始下拉刷新，username: $username');

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      _page = 1;
      _log.d('准备刷新首页数据，username: $username, page: $_page');

      final result = await _fetchData(
        username: username,
        page: _page,
      );

      if (result.isEmpty) {
        _log.w('刷新结果为空，username: $username');
      } else {
        _log.i('刷新成功，count: ${result.length}, username: $username');
      }

      _hasMore = result.isNotEmpty;
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = '刷新失败';
      _log.e(
        '刷新失败，username: $username, page: $_page, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载更多数据。
  ///
  /// [username] 表示目标用户名。
  Future<void> loadMoreData({
    required String username,
  }) async {
    if (_isLoading) {
      _log.w('当前正在加载中，忽略加载更多请求，username: $username');
      return;
    }

    if (!_hasMore) {
      _log.w('当前没有更多数据，忽略加载更多请求，username: $username');
      return;
    }

    _log.i('开始加载更多，username: $username, page: $_page');

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      _log.d('准备请求下一页数据，username: $username, page: $nextPage');

      final result = await _fetchData(
        username: username,
        page: nextPage,
      );

      if (result.isEmpty) {
        _hasMore = false;
        _log.w('加载更多结果为空，username: $username, page: $nextPage');
      } else {
        _page = nextPage;
        _log.i('加载更多成功，count: ${result.length}, page: $_page');
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = '加载更多失败';
      _log.e(
        '加载更多失败，username: $username, page: $_page, error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 重试当前请求。
  ///
  /// [username] 表示目标用户名。
  Future<void> retry({
    required String username,
  }) async {
    _log.i('用户触发重试，username: $username, currentPage: $_page');
    await refreshData(username: username);
  }

  /// 拉取远程数据。
  ///
  /// [username] 表示目标用户名。
  /// [page] 表示请求页码。
  Future<List<dynamic>> _fetchData({
    required String username,
    required int page,
  }) async {
    return <dynamic>[];
  }
}
```

## 使用说明

- 若当前模块已有状态机字段，优先沿用现有结构
- 若已有 logger，优先复用
- 不为了加日志重构整段状态逻辑
- 日志重点放在入口、分页参数、空态、异常、状态切换结果
