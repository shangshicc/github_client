import 'package:flutter/foundation.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';

final _log = createLogger('[DemoListViewModel]');

/// Demo 列表视图模型。
///
/// 负责维护页面状态、分页流程、错误恢复以及展示条目拼装。
class DemoListViewModel extends ChangeNotifier {
  /// 创建 Demo 列表视图模型。
  ///
  /// [repository] 表示数据仓储实例。
  DemoListViewModel({DemoListRepository? repository})
      : _repository = repository ?? DemoListRepository();

  /// 单次请求数量。
  static const int pageSize = 5;

  /// 目标用户名。
  ///
  /// 这里默认使用 GitHub 官方演示用户，便于 demo 在非登录场景下也能展示真实数据。
  static const String defaultUsername = 'octocat';

  final DemoListRepository _repository;
  final List<Repo> _repos = <Repo>[];
  final List<DemoListItem> _items = <DemoListItem>[];
  List<DemoListItem> _visibleItems = const [];

  DemoListLoadPhase _phase = DemoListLoadPhase.idle;
  int _page = 1;
  bool _hasMore = true;
  bool _isEmpty = false;
  bool _hasError = false;
  String _errorMessage = '';

  /// 当前是否处于任意加载阶段。
  bool get isLoading => _phase != DemoListLoadPhase.idle;

  /// 当前是否处于初始加载中。
  bool get isInitialLoading => _phase == DemoListLoadPhase.initialLoading;

  /// 当前是否处于刷新中。
  bool get isRefreshing => _phase == DemoListLoadPhase.refreshing;

  /// 当前是否处于加载更多中。
  bool get isLoadingMore => _phase == DemoListLoadPhase.loadingMore;

  /// 当前数据是否为空。
  bool get isEmpty => _isEmpty;

  /// 当前是否发生错误。
  bool get hasError => _hasError;

  /// 当前错误提示文案。
  String get errorMessage => _errorMessage;

  /// 当前列表是否还有更多数据可加载。
  bool get hasMore => _hasMore;

  /// 当前条目列表。
  List<DemoListItem> get items => _visibleItems;

  /// 当前是否只展示单个状态条目。
  bool get isStateOnly =>
      isInitialLoading || _isEmpty || (_hasError && _items.isEmpty);

  /// 首次进入页面时加载数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> loadInitialData({
    String? username,
  }) async {
    if (isLoading) {
      _log.d('忽略首次加载，当前已有加载任务执行中');
      return;
    }
    _log.i('开始初始化加载，username: ${username ?? defaultUsername}');
    _setLoadPhase(DemoListLoadPhase.initialLoading);
    await _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: true,
    );
  }

  /// 下拉刷新列表数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> refreshData({
    String? username,
  }) async {
    if (isLoading) {
      _log.d('忽略下拉刷新，当前已有加载任务执行中');
      return;
    }
    _log.i('开始下拉刷新');
    _setLoadPhase(DemoListLoadPhase.refreshing);
    await _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: true,
    );
  }

  /// 上拉加载更多数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> loadMoreData({
    String? username,
  }) async {
    if (isLoading) {
      _log.d('忽略加载更多，当前已有加载任务执行中');
      return;
    }
    if (!_hasMore) {
      _log.d('忽略加载更多，当前已无更多数据');
      return;
    }
    if (_repos.isEmpty) {
      _log.d('忽略加载更多，当前仓库列表为空');
      return;
    }
    _log.i('开始加载更多，page: $_page');
    _setLoadPhase(DemoListLoadPhase.loadingMore);
    await _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: false,
    );
  }

  /// 重新尝试加载当前页面数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> retry({
    String? username,
  }) async {
    _log.i('用户触发重试，当前page: $_page');
    await refreshData(username: username);
  }

  /// 执行分页请求并更新列表状态。
  ///
  /// [username] 表示目标 GitHub 用户名。
  /// [resetBeforeLoad] 表示是否在请求前重置现有列表数据。
  Future<void> _loadPage({
    required String username,
    required bool resetBeforeLoad,
  }) async {
    try {
      _log.d('请求分页，username: $username, page: $_page, reset: $resetBeforeLoad');

      if (resetBeforeLoad) {
        _page = 1;
        _repos.clear();
        _items.clear();
        _hasMore = true;
        _isEmpty = false;
        _hasError = false;
        _errorMessage = '';
      }

      final data = await _repository.fetchRepos(
        username: username,
        page: _page,
        pageSize: pageSize,
      );

      _hasMore = data.length >= pageSize;
      _repos.addAll(data);
      _appendRepoItems(data);
      _page++;
      _isEmpty = _repos.isEmpty;
      _hasError = false;
      _errorMessage = '';
      _log.i('分页加载成功，返回 ${data.length} 条，累计 ${_repos.length} 条');
    } catch (error, stackTrace) {
      if (resetBeforeLoad) {
        _repos.clear();
        _items.clear();
        _hasMore = false;
      }
      _hasError = true;
      _errorMessage = error.toString();

      _log.e('分页加载失败，username: $username, page: $_page',
          error: error, stackTrace: stackTrace);
    } finally {
      _setLoadPhase(DemoListLoadPhase.idle);
    }
  }

  /// 设置当前加载阶段并通知依赖项刷新。
  ///
  /// [phase] 表示当前加载阶段。
  void _setLoadPhase(DemoListLoadPhase phase) {
    if (_phase == phase) {
      return;
    }
    _log.d('加载阶段变更: ${phase.name}');
    _phase = phase;
    _syncVisibleItems();
    notifyListeners();
  }

  /// 将仓库数据追加转换为列表展示条目。
  ///
  /// [repos] 表示本次接口返回的仓库数据集合。
  void _appendRepoItems(List<Repo> repos) {
    for (final repo in repos) {
      _items.add(DemoListTitleItemData(repo));
      _items.add(DemoListMetaItemData(repo));
    }
  }

  /// 根据当前加载阶段和结果态同步可见条目缓存。
  void _syncVisibleItems() {
    if (isInitialLoading) {
      _visibleItems = const [
        DemoListStateItemData(stateType: DemoListStateType.loading),
      ];
      return;
    }

    if (_hasError && _items.isEmpty) {
      _visibleItems = [
        DemoListStateItemData(
          stateType: DemoListStateType.error,
          message: _errorMessage,
        ),
      ];
      return;
    }

    if (_isEmpty) {
      _visibleItems = const [
        DemoListStateItemData(stateType: DemoListStateType.empty),
      ];
      return;
    }

    _visibleItems = List.unmodifiable(_items);
  }
}

/// Demo 列表加载阶段。
enum DemoListLoadPhase {
  /// 空闲状态。
  idle,

  /// 首次加载状态。
  initialLoading,

  /// 下拉刷新状态。
  refreshing,

  /// 上拉加载更多状态。
  loadingMore,
}
