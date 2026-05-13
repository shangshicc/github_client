import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_view_model.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_empty_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_error_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_loading_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_meta_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_title_item.dart';
import 'package:provider/provider.dart';

final _log = createLogger('[DemoListRoute]');

/// 多类型列表 Demo 页面，负责创建页面级状态并触发首次加载。
class DemoListRoute extends StatefulWidget {
  const DemoListRoute({
    super.key,
    this.viewModelBuilder,
  });

  /// 页面级视图模型构造器。
  ///
  /// 仅用于测试注入场景；默认由页面内部创建 [DemoListViewModel]。
  final DemoListViewModel Function()? viewModelBuilder;

  @override
  State<DemoListRoute> createState() => _DemoListRouteState();
}

class _DemoListRouteState extends State<DemoListRoute> {
  /// 页面级视图模型实例。
  late final DemoListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModelBuilder?.call() ?? DemoListViewModel();
    _scheduleInitialLoad();
  }

  /// 在首帧渲染完成后触发列表首次加载。
  ///
  /// 这样可以确保页面先完成首屏绘制，再启动异步请求，避免把副作用放进 build 流程。
  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _log.d('页面已释放，跳过首次数据加载');
        return;
      }

      _log.d('页面进入，触发首次数据加载');
      _viewModel.loadInitialData();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _DemoListView(),
    );
  }
}

/// 多类型列表视图，根据 ViewModel 状态渲染内容或状态页。
class _DemoListView extends StatelessWidget {
  const _DemoListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).demoList),
      ),
      body: Consumer<DemoListViewModel>(
        builder: (context, viewModel, child) {
          final items = viewModel.items;

          if (viewModel.isStateOnly) {
            // 首次加载中、空态、错误态等状态页不需要下拉刷新和上拉加载。
            final item = items.single;
            if (item is! DemoListStateItemData) {
              // 防御性代码
              final message = 'DemoListRoute state-only 分支期望 '
                  'DemoListStateItemData，'
                  '实际类型: ${item.runtimeType}';
              _log.e(message);
              throw StateError(message);
            }
            // CustomScrollView+SliverFillRemaining 实现占满全屏
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildStateItem(context, item),
                ),
              ],
            );
          }

          return EasyRefresh.builder(
            onRefresh: viewModel.refreshData,
            onLoad: viewModel.hasMore ? viewModel.loadMoreData : null,
            footer: BuilderFooter(
              triggerOffset: 70,
              clamping: false,
              processedDuration: Duration.zero,
              infiniteOffset: 70,
              builder: _buildLoadMoreFooter,
            ),
            childBuilder: (context, physics) {
              return ListView.builder(
                physics: physics,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildRepoItem(context, items[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 构建普通仓库列表条目。
  ///
  /// [context] 表示当前构建上下文。
  /// [item] 表示普通列表分支中的单个展示条目。
  ///
  /// 当普通列表分支错误地收到状态条目时，方法会记录错误日志并抛出 [StateError]。
  Widget _buildRepoItem(BuildContext context, DemoListItem item) {
    switch (item) {
      case DemoListTitleItemData(:final repo):
        return DemoListTitleItem(repo: repo);
      case DemoListMetaItemData(:final repo):
        return DemoListMetaItem(repo: repo);
      case DemoListStateItemData():
        final message = '_buildRepoItem 仅支持 DemoListTitleItemData 与 '
            'DemoListMetaItemData，实际收到: ${item.runtimeType}';
        _log.e(message);
        throw StateError(message);
    }
  }

  /// 构建上拉加载更多的 footer。
  ///
  /// [context] 表示 EasyRefresh footer 的构建上下文，用于读取主题与本地化资源。
  /// [state] 表示 footer 当前的交互状态与可用高度，用于决定是否展示 loading 布局。
  ///
  /// 方法会在 ready 与 processing 阶段复用 [DemoListLoadingItem]，
  /// 其他阶段仅保留 EasyRefresh 需要的占位高度。
  Widget _buildLoadMoreFooter(BuildContext context, IndicatorState state) {
    final shouldShowLoading = state.mode == IndicatorMode.ready ||
        state.mode == IndicatorMode.processing;
    if (!shouldShowLoading) {
      return SizedBox(height: state.offset);
    }

    final footerHeight = state.offset > 56 ? state.offset : 56.0;
    return SizedBox(
      height: footerHeight,
      child: DemoListLoadingItem(
        message: AppLocalizations.of(context).demoListLoading,
        verticalPadding: 6,
        indicatorSize: 18,
        indicatorStrokeWidth: 2,
        spacing: 6,
      ),
    );
  }

  /// 构建 loading、empty、error 三种状态页。
  Widget _buildStateItem(BuildContext context, DemoListStateItemData item) {
    final viewModel = context.read<DemoListViewModel>();
    final l10n = AppLocalizations.of(context);
    switch (item.stateType) {
      case DemoListStateType.loading:
        return DemoListLoadingItem(
          message: item.message?.isNotEmpty == true
              ? item.message!
              : l10n.demoListLoading,
          fillRemaining: true,
        );
      case DemoListStateType.empty:
        return DemoListEmptyItem(
          message: item.message?.isNotEmpty == true
              ? item.message!
              : l10n.demoListEmpty,
          onRefresh: viewModel.refreshData,
        );
      case DemoListStateType.error:
        return DemoListErrorItem(
          message: item.message?.isNotEmpty == true
              ? item.message!
              : l10n.demoListLoadFailed,
          onRetry: viewModel.retry,
        );
    }
  }
}
