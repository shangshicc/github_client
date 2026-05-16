import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_state.dart';

part 'demo_list_controller.g.dart';

final _log = createLogger('[DemoListController]');

/// DemoList 页面仓储 Provider。
final Provider<DemoListRepository> demoListRepositoryProvider =
    Provider<DemoListRepository>((Ref ref) {
      return DemoListRepository();
    });

/// Demo 列表加载更多结果。
enum DemoListLoadMoreOutcome {
  /// 本次加载成功并已追加数据。
  success,

  /// 本次加载没有更多数据可追加。
  noMore,

  /// 本次加载发生失败。
  failed,
}

/// Demo 列表页面控制器。
///
/// 负责维护分页流程、错误恢复以及主结果态 / 加载更多交互态写入。
@Riverpod(keepAlive: false)
class DemoListController extends _$DemoListController {
  /// 单次请求数量。
  static const int pageSize = 5;

  /// 目标用户名。
  ///
  /// 这里默认使用 GitHub 官方演示用户，便于 demo 在非登录场景下也能展示真实数据。
  static const String defaultUsername = 'octocat';

  DemoListRepository get _repository => ref.read(demoListRepositoryProvider);

  @override
  DemoListState build() {
    return DemoListState.initial();
  }

  /// 首次进入页面时加载数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> loadInitialData({String? username}) async {
    if (state.isLoading) {
      _log.d('忽略首次加载，当前已有加载任务执行中');
      return;
    }
    _log.i('开始初始化加载，username: ${username ?? defaultUsername}');
    state = state.copyWith(
      pageState: DemoListPageStateType.loading,
      phase: DemoListLoadPhase.initialLoading,
      loadMoreStatus: DemoListLoadMoreStatus.idle,
      errorMessage: '',
    );
    await _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: true,
    );
  }

  /// 下拉刷新列表数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> refreshData({String? username}) async {
    if (state.isLoading) {
      _log.d('忽略下拉刷新，当前已有加载任务执行中');
      return;
    }
    _log.i('开始下拉刷新');
    if (state.hasError) {
      state = state.copyWith(
        phase: DemoListLoadPhase.refreshing,
        loadMoreStatus: DemoListLoadMoreStatus.idle,
      );
    } else if (state.repos.isEmpty) {
      state = state.copyWith(
        pageState: DemoListPageStateType.loading,
        phase: DemoListLoadPhase.refreshing,
        loadMoreStatus: DemoListLoadMoreStatus.idle,
        errorMessage: '',
      );
    } else {
      state = state.copyWith(
        phase: DemoListLoadPhase.refreshing,
        loadMoreStatus: DemoListLoadMoreStatus.idle,
      );
    }
    await _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: true,
    );
  }

  /// 上拉加载更多数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<DemoListLoadMoreOutcome> loadMoreData({String? username}) async {
    if (state.isLoading) {
      _log.d('忽略加载更多，当前已有加载任务执行中');
      return DemoListLoadMoreOutcome.noMore;
    }
    if (!state.hasMore) {
      _log.d('忽略加载更多，当前已无更多数据');
      return DemoListLoadMoreOutcome.noMore;
    }
    if (state.repos.isEmpty) {
      _log.d('忽略加载更多，当前仓库列表为空');
      return DemoListLoadMoreOutcome.noMore;
    }
    _log.i('开始加载更多，page: ${state.page}');
    state = state.copyWith(
      phase: DemoListLoadPhase.loadingMore,
      loadMoreStatus: DemoListLoadMoreStatus.loading,
    );
    return _loadPage(
      username: username ?? defaultUsername,
      resetBeforeLoad: false,
    );
  }

  /// 重新尝试加载当前页面数据。
  ///
  /// [username] 表示目标 GitHub 用户名，默认使用演示用户。
  Future<void> retry({String? username}) async {
    _log.i('用户触发重试，当前page: ${state.page}');
    await refreshData(username: username);
  }

  /// 执行分页请求并更新列表状态。
  ///
  /// [username] 表示目标 GitHub 用户名。
  /// [resetBeforeLoad] 表示是否在请求前重置现有列表数据。
  Future<DemoListLoadMoreOutcome> _loadPage({
    required String username,
    required bool resetBeforeLoad,
  }) async {
    final int requestPage = resetBeforeLoad ? 1 : state.page;
    final List<Repo> baseRepos = resetBeforeLoad ? <Repo>[] : state.repos;

    try {
      _log.d(
        '请求分页，username: $username, page: $requestPage, reset: $resetBeforeLoad',
      );

      final List<Repo> data = await _repository.fetchRepos(
        username: username,
        page: requestPage,
        pageSize: pageSize,
      );

      final List<Repo> nextRepos = <Repo>[...baseRepos, ...data];
      final bool isNoMore = !resetBeforeLoad && data.isEmpty;
      final DemoListLoadMoreStatus nextLoadMoreStatus =
          resetBeforeLoad
              ? DemoListLoadMoreStatus.idle
              : (isNoMore
                  ? DemoListLoadMoreStatus.noMore
                  : DemoListLoadMoreStatus.idle);

      state = state.copyWith(
        repos: List<Repo>.unmodifiable(nextRepos),
        page: requestPage + 1,
        hasMore: data.length >= pageSize,
        pageState:
            nextRepos.isEmpty
                ? DemoListPageStateType.empty
                : DemoListPageStateType.data,
        loadMoreStatus: nextLoadMoreStatus,
        errorMessage: '',
        phase: DemoListLoadPhase.idle,
      );
      _log.i('分页加载成功，返回 ${data.length} 条，累计 ${nextRepos.length} 条');
      if (isNoMore) {
        _log.d('加载更多结果为空，判定为没有更多数据');
        state = state.copyWith(hasMore: false);
        return DemoListLoadMoreOutcome.noMore;
      }
      if (resetBeforeLoad && nextRepos.isEmpty) {
        _log.d('首载或刷新结果为空，切换到 empty 页面态');
      }
      return DemoListLoadMoreOutcome.success;
    } catch (error, stackTrace) {
      final List<Repo> nextRepos = resetBeforeLoad ? <Repo>[] : state.repos;
      state = state.copyWith(
        repos: List<Repo>.unmodifiable(nextRepos),
        page: state.page,
        hasMore: state.hasMore,
        pageState:
            resetBeforeLoad ? DemoListPageStateType.error : state.pageState,
        loadMoreStatus:
            resetBeforeLoad
                ? DemoListLoadMoreStatus.idle
                : DemoListLoadMoreStatus.failed,
        errorMessage: resetBeforeLoad ? error.toString() : state.errorMessage,
        phase: DemoListLoadPhase.idle,
      );

      _log.e(
        '分页加载失败，username: $username, page: ${state.page}',
        error: error,
        stackTrace: stackTrace,
      );
      return DemoListLoadMoreOutcome.failed;
    }
  }
}
