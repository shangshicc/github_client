import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';

/// Demo 列表页面主结果态。
///
/// 该枚举用于显式描述页面当前展示的主结果，而不是依赖多个布尔字段拼装推断。
enum DemoListPageStateType {
  /// 尚未发起有效请求的初始状态。
  pristine,

  /// 首次进入或首轮请求进行中的加载状态。
  loading,

  /// 请求完成但结果为空的空态。
  empty,

  /// 首载、刷新或重试失败的错误态。
  error,

  /// 已存在可渲染仓库列表的数据态。
  data,
}

/// Demo 列表加载更多交互态。
///
/// 该枚举用于显式区分尾部加载更多的进行中、无更多、失败等结果，避免污染主页面结果态。
enum DemoListLoadMoreStatus {
  /// 当前未处于加载更多交互。
  idle,

  /// 当前正在执行加载更多。
  loading,

  /// 当前已确认无更多数据。
  noMore,

  /// 当前加载更多发生失败。
  failed,
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

/// Demo 列表页面状态。
///
/// 该对象用于承载页面的分页数据、主结果态与加载更多交互态，
/// 作为 Riverpod 控制器与 UI 间的唯一状态快照。
class DemoListState {
  /// 创建 Demo 列表页面状态。
  ///
  /// [repos] 表示当前已加载的仓库列表。
  /// [pageState] 表示当前主结果态。
  /// [phase] 表示当前加载阶段。
  /// [page] 表示下一次请求的页码。
  /// [hasMore] 表示是否还有更多数据。
  /// [loadMoreStatus] 表示当前加载更多交互态。
  /// [errorMessage] 表示当前错误提示文案。
  const DemoListState({
    required this.repos,
    required this.pageState,
    required this.phase,
    required this.page,
    required this.hasMore,
    required this.loadMoreStatus,
    required this.errorMessage,
  });

  /// 当前已加载的仓库列表。
  final List<Repo> repos;

  /// 当前主结果态。
  final DemoListPageStateType pageState;

  /// 当前加载阶段。
  final DemoListLoadPhase phase;

  /// 下一次请求页码。
  final int page;

  /// 当前是否还有更多数据。
  final bool hasMore;

  /// 当前加载更多交互态。
  final DemoListLoadMoreStatus loadMoreStatus;

  /// 当前错误提示文案。
  final String errorMessage;

  /// 当前是否处于任意加载阶段。
  bool get isLoading => phase != DemoListLoadPhase.idle;

  /// 当前是否处于首次加载中。
  bool get isInitialLoading => phase == DemoListLoadPhase.initialLoading;

  /// 当前是否处于下拉刷新中。
  bool get isRefreshing => phase == DemoListLoadPhase.refreshing;

  /// 当前是否处于上拉加载更多中。
  bool get isLoadingMore => phase == DemoListLoadPhase.loadingMore;

  /// 当前是否处于初始未请求状态。
  bool get isPristine => pageState == DemoListPageStateType.pristine;

  /// 当前数据是否为空。
  bool get isEmpty => pageState == DemoListPageStateType.empty;

  /// 当前是否存在错误。
  bool get hasError => pageState == DemoListPageStateType.error;

  /// 当前是否只展示单个状态条目。
  bool get isStateOnly =>
      pageState == DemoListPageStateType.pristine ||
      pageState == DemoListPageStateType.loading ||
      pageState == DemoListPageStateType.empty ||
      pageState == DemoListPageStateType.error;

  /// 当前页面用于 UI 渲染的展示条目。
  List<DemoListItem> get items {
    switch (pageState) {
      case DemoListPageStateType.pristine:
        return const <DemoListItem>[
          DemoListStateItemData(stateType: DemoListStateType.loading),
        ];
      case DemoListPageStateType.loading:
        return const <DemoListItem>[
          DemoListStateItemData(stateType: DemoListStateType.loading),
        ];
      case DemoListPageStateType.empty:
        return const <DemoListItem>[
          DemoListStateItemData(stateType: DemoListStateType.empty),
        ];
      case DemoListPageStateType.error:
        return <DemoListItem>[
          DemoListStateItemData(
            stateType: DemoListStateType.error,
            message: errorMessage,
          ),
        ];
      case DemoListPageStateType.data:
        final List<DemoListItem> nextItems = <DemoListItem>[];
        for (final Repo repo in repos) {
          nextItems.add(DemoListTitleItemData(repo));
          nextItems.add(DemoListMetaItemData(repo));
        }
        return List<DemoListItem>.unmodifiable(nextItems);
    }
  }

  /// 复制当前状态对象。
  ///
  /// 各参数用于按需覆盖对应状态字段。
  ///
  /// 返回值：复制后的新状态对象。
  DemoListState copyWith({
    List<Repo>? repos,
    DemoListPageStateType? pageState,
    DemoListLoadPhase? phase,
    int? page,
    bool? hasMore,
    DemoListLoadMoreStatus? loadMoreStatus,
    String? errorMessage,
  }) {
    return DemoListState(
      repos: repos ?? this.repos,
      pageState: pageState ?? this.pageState,
      phase: phase ?? this.phase,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 创建初始空闲状态。
  ///
  /// 返回值：初始页面状态对象。
  factory DemoListState.initial() {
    return const DemoListState(
      repos: <Repo>[],
      pageState: DemoListPageStateType.pristine,
      phase: DemoListLoadPhase.idle,
      page: 1,
      hasMore: true,
      loadMoreStatus: DemoListLoadMoreStatus.idle,
      errorMessage: '',
    );
  }
}
