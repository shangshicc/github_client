import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/models/repo.dart';
import 'package:github_client_app/models/user.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_controller.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_state.dart';

void main() {
  test('refreshData 在请求挂起期间不应把状态条目暴露给普通列表分支', () async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <Future<List<Repo>>>[
        Future<List<Repo>>.value(<Repo>[_buildRepo(id: 1, name: 'repo-1')]),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        demoListRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final DemoListController controller =
        container.read(demoListControllerProvider.notifier);

    await controller.loadInitialData();

    final Completer<List<Repo>> refreshCompleter = Completer<List<Repo>>();
    repository.enqueueResponse(refreshCompleter.future);

    final Future<void> refreshFuture = controller.refreshData();
    final DemoListState duringRefresh =
        container.read(demoListControllerProvider);

    expect(duringRefresh.phase, DemoListLoadPhase.refreshing);
    expect(duringRefresh.pageState, DemoListPageStateType.data);
    expect(duringRefresh.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(duringRefresh.isStateOnly, isFalse);
    expect(duringRefresh.items.whereType<DemoListStateItemData>(), isEmpty);
    expect(duringRefresh.items, hasLength(2));

    refreshCompleter.complete(<Repo>[_buildRepo(id: 2, name: 'repo-2')]);
    await refreshFuture;

    final DemoListState afterRefresh =
        container.read(demoListControllerProvider);
    expect(afterRefresh.phase, DemoListLoadPhase.idle);
    expect(afterRefresh.pageState, DemoListPageStateType.data);
    expect(afterRefresh.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(afterRefresh.items.whereType<DemoListStateItemData>(), isEmpty);
    expect(afterRefresh.items, hasLength(2));
  });

  test('retry 在错误页请求挂起期间应继续展示错误态而不是空态', () async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <Future<List<Repo>>>[
        Future<List<Repo>>.error(Exception('network down')),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        demoListRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final DemoListController controller =
        container.read(demoListControllerProvider.notifier);

    await controller.loadInitialData();

    final DemoListState failedState =
        container.read(demoListControllerProvider);
    final DemoListStateItemData failedItem =
        failedState.items.single as DemoListStateItemData;
    expect(failedState.hasError, isTrue);
    expect(failedState.pageState, DemoListPageStateType.error);
    expect(failedState.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(failedState.isStateOnly, isTrue);
    expect(failedItem.stateType, DemoListStateType.error);

    final Completer<List<Repo>> retryCompleter = Completer<List<Repo>>();
    repository.enqueueResponse(retryCompleter.future);

    final Future<void> retryFuture = controller.retry();
    final DemoListState duringRetry =
        container.read(demoListControllerProvider);
    final DemoListStateItemData duringRetryItem =
        duringRetry.items.single as DemoListStateItemData;

    expect(duringRetry.phase, DemoListLoadPhase.refreshing);
    expect(duringRetry.pageState, DemoListPageStateType.error);
    expect(duringRetry.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(duringRetry.isStateOnly, isTrue);
    expect(duringRetryItem.stateType, DemoListStateType.error);

    retryCompleter.complete(<Repo>[_buildRepo(id: 3, name: 'repo-3')]);
    await retryFuture;

    final DemoListState recoveredState =
        container.read(demoListControllerProvider);
    expect(recoveredState.phase, DemoListLoadPhase.idle);
    expect(recoveredState.pageState, DemoListPageStateType.data);
    expect(recoveredState.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(recoveredState.hasError, isFalse);
    expect(recoveredState.items.whereType<DemoListStateItemData>(), isEmpty);
    expect(recoveredState.items, hasLength(2));
  });

  test('loadMoreData 返回 noMore 时应保持列表不变并关闭更多加载', () async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <Future<List<Repo>>>[
        Future<List<Repo>>.value(<Repo>[
          _buildRepo(id: 1, name: 'repo-1'),
          _buildRepo(id: 2, name: 'repo-2'),
          _buildRepo(id: 3, name: 'repo-3'),
          _buildRepo(id: 4, name: 'repo-4'),
          _buildRepo(id: 5, name: 'repo-5'),
        ]),
        Future<List<Repo>>.value(<Repo>[]),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        demoListRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final DemoListController controller =
        container.read(demoListControllerProvider.notifier);

    await controller.loadInitialData();
    final DemoListState afterInitial =
        container.read(demoListControllerProvider);
    expect(afterInitial.hasMore, isTrue);
    expect(afterInitial.pageState, DemoListPageStateType.data);
    expect(afterInitial.loadMoreStatus, DemoListLoadMoreStatus.idle);
    expect(afterInitial.items, hasLength(10));

    final DemoListLoadMoreOutcome outcome = await controller.loadMoreData();
    final DemoListState afterLoadMore =
        container.read(demoListControllerProvider);

    expect(outcome, DemoListLoadMoreOutcome.noMore);
    expect(afterLoadMore.phase, DemoListLoadPhase.idle);
    expect(afterLoadMore.hasMore, isFalse);
    expect(afterLoadMore.hasError, isFalse);
    expect(afterLoadMore.pageState, DemoListPageStateType.data);
    expect(afterLoadMore.loadMoreStatus, DemoListLoadMoreStatus.noMore);
    expect(afterLoadMore.items, hasLength(10));
    expect(afterLoadMore.items.whereType<DemoListStateItemData>(), isEmpty);
  });

  test('loadMoreData 返回 failed 时应保留现有列表并不进入错误页', () async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <Future<List<Repo>>>[
        Future<List<Repo>>.value(<Repo>[
          _buildRepo(id: 1, name: 'repo-1'),
          _buildRepo(id: 2, name: 'repo-2'),
          _buildRepo(id: 3, name: 'repo-3'),
          _buildRepo(id: 4, name: 'repo-4'),
          _buildRepo(id: 5, name: 'repo-5'),
        ]),
        Future<List<Repo>>.error(Exception('load more failed')),
      ],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        demoListRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final DemoListController controller =
        container.read(demoListControllerProvider.notifier);

    await controller.loadInitialData();
    final DemoListState afterInitial =
        container.read(demoListControllerProvider);
    expect(afterInitial.items, hasLength(10));
    expect(afterInitial.pageState, DemoListPageStateType.data);
    expect(afterInitial.loadMoreStatus, DemoListLoadMoreStatus.idle);

    final DemoListLoadMoreOutcome outcome = await controller.loadMoreData();
    final DemoListState afterFailedLoadMore =
        container.read(demoListControllerProvider);

    expect(outcome, DemoListLoadMoreOutcome.failed);
    expect(afterFailedLoadMore.phase, DemoListLoadPhase.idle);
    expect(afterFailedLoadMore.hasError, isFalse);
    expect(afterFailedLoadMore.hasMore, isTrue);
    expect(afterFailedLoadMore.pageState, DemoListPageStateType.data);
    expect(afterFailedLoadMore.loadMoreStatus, DemoListLoadMoreStatus.failed);
    expect(afterFailedLoadMore.items, hasLength(10));
    expect(
        afterFailedLoadMore.items.whereType<DemoListStateItemData>(), isEmpty);
  });
}

/// 构建用于测试的最小仓库对象。
///
/// [id] 表示仓库唯一标识。
/// [name] 表示仓库名称。
///
/// 返回值：满足当前列表展示所需字段的测试仓库对象。
Repo _buildRepo({
  required int id,
  required String name,
}) {
  final Repo repo = Repo();
  repo.id = id;
  repo.name = name;
  repo.full_name = 'tester/$name';
  repo.owner = _buildUser();
  repo.private = false;
  repo.html_url = 'https://example.com/$name';
  repo.description = 'desc-$name';
  repo.fork = false;
  repo.homepage = null;
  repo.language = 'Dart';
  repo.forks_count = 0;
  repo.stargazers_count = 0;
  repo.watchers_count = 0;
  repo.size = 0;
  repo.default_branch = 'main';
  repo.open_issues_count = 0;
  repo.topics = <String>[];
  repo.has_issues = true;
  repo.has_projects = true;
  repo.has_wiki = true;
  repo.has_pages = false;
  repo.has_downloads = true;
  repo.pushed_at = '2026-05-15T00:00:00Z';
  repo.created_at = '2026-05-15T00:00:00Z';
  repo.updated_at = '2026-05-15T00:00:00Z';
  repo.permissions = <String, dynamic>{};
  repo.subscribers_count = 0;
  repo.license = null;
  return repo;
}

/// 构建用于测试的最小用户对象。
///
/// 返回值：满足仓库 owner 字段约束的测试用户对象。
User _buildUser() {
  final User user = User();
  user.login = 'tester';
  user.id = 1;
  user.avatar_url = 'https://example.com/avatar.png';
  user.url = 'https://example.com/users/tester';
  user.type = 'User';
  user.site_admin = false;
  user.name = 'Tester';
  user.company = null;
  user.blog = null;
  user.location = null;
  user.email = null;
  user.hireable = false;
  user.bio = 'bio';
  user.public_repos = 0;
  user.public_gists = 0;
  user.followers = 0;
  user.following = 0;
  user.created_at = '2026-05-15T00:00:00Z';
  user.updated_at = '2026-05-15T00:00:00Z';
  user.total_private_repos = 0;
  user.owned_private_repos = 0;
  return user;
}

/// DemoListRepository 的测试替身。
///
/// 通过按顺序消费预置 Future，模拟首次加载和刷新等不同阶段的返回时机。
class _FakeDemoListRepository extends DemoListRepository {
  /// 创建仓储测试替身。
  ///
  /// [responses] 表示按调用顺序返回的结果队列。
  _FakeDemoListRepository({
    required List<Future<List<Repo>>> responses,
  }) : _responses = Queue<Future<List<Repo>>>.from(responses);

  final Queue<Future<List<Repo>>> _responses;

  /// 向响应队列末尾追加一个新的结果。
  ///
  /// [response] 表示下一次请求可消费的 Future 结果。
  void enqueueResponse(Future<List<Repo>> response) {
    _responses.addLast(response);
  }

  @override
  Future<List<Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) {
    return _responses.removeFirst();
  }
}
