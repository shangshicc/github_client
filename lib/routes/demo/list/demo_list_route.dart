import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_controller.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_state.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_empty_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_error_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_loading_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_meta_item.dart';
import 'package:github_client_app/routes/demo/list/widgets/demo_list_title_item.dart';

final _log = createLogger('[DemoListRoute]');

/// 多类型列表 Demo 页面，负责触发首次加载并消费页面级 Riverpod 状态。
class DemoListRoute extends ConsumerStatefulWidget {
  /// 创建多类型列表 Demo 页面。
  const DemoListRoute({super.key});

  @override
  ConsumerState<DemoListRoute> createState() => _DemoListRouteState();
}

class _DemoListRouteState extends ConsumerState<DemoListRoute> {
  @override
  void initState() {
    super.initState();
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
      ref.read(demoListControllerProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _DemoListView();
  }
}

/// 多类型列表视图，根据 Riverpod 状态快照渲染内容或状态页。
class _DemoListView extends ConsumerWidget {
  const _DemoListView();

  static const double _maxReadableContentWidth = 760;
  static const String _stateConstraintKey = 'demo_list_state_constraint';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DemoListState state = ref.watch(demoListControllerProvider);
    final List<DemoListItem> items = state.items;
    final bool shouldShowStateOnly = state.isStateOnly;
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(demoListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).demoList)),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxContentWidth = _resolveMaxContentWidth(
            constraints.maxWidth,
          );
          return shouldShowStateOnly
              ? _buildStateOnly(
                context,
                items,
                maxContentWidth: maxContentWidth,
                onRefresh: controller.refreshData,
                onRetry: controller.retry,
              )
              : EasyRefresh.builder(
                onRefresh: controller.refreshData,
                onLoad:
                    state.hasMore
                        ? () async {
                          final DemoListLoadMoreOutcome outcome =
                              await controller.loadMoreData();
                          if (!context.mounted) {
                            return;
                          }
                          if (outcome == DemoListLoadMoreOutcome.failed) {
                            showToast(l10n.demoListLoadFailed);
                          }
                        }
                        : null,
                footer: BuilderFooter(
                  triggerOffset: 70,
                  clamping: false,
                  processedDuration: Duration.zero,
                  infiniteOffset: 70,
                  builder:
                      (context, state) => _buildLoadMoreFooter(
                        context,
                        state,
                        maxContentWidth: maxContentWidth,
                      ),
                ),
                childBuilder: (context, physics) {
                  return ListView.builder(
                    physics: physics,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildRepoItem(
                        context,
                        items[index],
                        index: index,
                        maxContentWidth: maxContentWidth,
                      );
                    },
                  );
                },
              );
        },
      ),
    );
  }

  /// 根据可用宽度计算页面内容的最大阅读宽度。
  ///
  /// [availableWidth] 表示页面当前可用的横向空间。
  ///
  /// 返回值：用于列表条目和状态页的统一最大内容宽度。
  double _resolveMaxContentWidth(double availableWidth) {
    if (availableWidth <= _maxReadableContentWidth) {
      return availableWidth;
    }
    return _maxReadableContentWidth;
  }

  /// 为横屏场景构建统一的居中限宽容器。
  ///
  /// [child] 表示需要被约束宽度的子组件。
  /// [maxContentWidth] 表示当前页面计算出的最大可读宽度。
  /// [key] 表示测试或调试时用于定位该约束容器的标识。
  ///
  /// 返回值：顶部对齐、水平居中且带最大宽度限制的内容容器。
  Widget _buildCenteredConstraint(
    Widget child, {
    required double maxContentWidth,
    Key? key,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        key: key,
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }

  /// 构建仅展示单个状态条目的状态页布局。
  ///
  /// [context] 表示当前构建上下文。
  /// [items] 表示页面当前展示条目集合，期望只包含单个状态条目。
  /// [maxContentWidth] 表示横屏下状态页允许使用的最大宽度。
  /// [onRefresh] 表示空态刷新回调。
  /// [onRetry] 表示错误态重试回调。
  ///
  /// 当状态页分支未拿到合法的状态条目时，会记录错误日志并抛出 [StateError]。
  Widget _buildStateOnly(
    BuildContext context,
    List<DemoListItem> items, {
    required double maxContentWidth,
    required Future<void> Function({String? username}) onRefresh,
    required Future<void> Function({String? username}) onRetry,
  }) {
    final DemoListItem item = items.single;
    if (item is! DemoListStateItemData) {
      final message =
          'DemoListRoute state-only 分支期望 DemoListStateItemData，'
          '实际类型: ${item.runtimeType}';
      _log.e(message);
      throw StateError(message);
    }

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildCenteredConstraint(
            _buildStateItem(
              context,
              item,
              onRefresh: onRefresh,
              onRetry: onRetry,
            ),
            key: const ValueKey<String>(_stateConstraintKey),
            maxContentWidth: maxContentWidth,
          ),
        ),
      ],
    );
  }

  /// 构建普通仓库列表条目。
  ///
  /// [context] 表示当前构建上下文。
  /// [item] 表示普通列表分支中的单个展示条目。
  /// [index] 表示当前条目索引，用于测试定位约束容器。
  /// [maxContentWidth] 表示普通列表在横屏下允许使用的最大宽度。
  ///
  /// 当普通列表分支错误地收到状态条目时，方法会记录错误日志并抛出 [StateError]。
  Widget _buildRepoItem(
    BuildContext context,
    DemoListItem item, {
    required int index,
    required double maxContentWidth,
  }) {
    final Widget child;
    switch (item) {
      case DemoListTitleItemData(:final repo):
        child = DemoListTitleItem(repo: repo);
      case DemoListMetaItemData(:final repo):
        child = DemoListMetaItem(repo: repo);
      case DemoListStateItemData():
        final message =
            '_buildRepoItem 仅支持 DemoListTitleItemData 与 '
            'DemoListMetaItemData，实际收到: ${item.runtimeType} stateType:${item.stateType}';
        _log.e(message);
        throw StateError(message);
    }

    return _buildCenteredConstraint(
      child,
      key: ValueKey<String>('demo_list_item_constraint_$index'),
      maxContentWidth: maxContentWidth,
    );
  }

  /// 构建上拉加载更多的 footer。
  ///
  /// [context] 表示 EasyRefresh footer 的构建上下文，用于读取主题与本地化资源。
  /// [state] 表示 footer 当前的交互状态与可用高度，用于决定是否展示 loading 布局。
  /// [maxContentWidth] 表示 footer 横屏下允许使用的最大宽度。
  ///
  /// 方法会在 ready 与 processing 阶段复用 [DemoListLoadingItem]，
  /// 其他阶段仅保留 EasyRefresh 需要的占位高度。
  Widget _buildLoadMoreFooter(
    BuildContext context,
    IndicatorState state, {
    required double maxContentWidth,
  }) {
    final shouldShowLoading =
        state.mode == IndicatorMode.ready ||
        state.mode == IndicatorMode.processing;
    if (!shouldShowLoading) {
      return SizedBox(height: state.offset);
    }

    final footerHeight = state.offset > 56 ? state.offset : 56.0;
    return SizedBox(
      height: footerHeight,
      child: _buildCenteredConstraint(
        DemoListLoadingItem(
          message: AppLocalizations.of(context).demoListLoading,
          verticalPadding: 6,
          indicatorSize: 18,
          indicatorStrokeWidth: 2,
          spacing: 6,
        ),
        maxContentWidth: maxContentWidth,
      ),
    );
  }

  /// 构建 loading、empty、error 三种状态页。
  ///
  /// [context] 表示当前构建上下文。
  /// [item] 表示当前状态页条目。
  /// [onRefresh] 表示空态下点击刷新的回调。
  /// [onRetry] 表示错误态下点击重试的回调。
  Widget _buildStateItem(
    BuildContext context,
    DemoListStateItemData item, {
    required Future<void> Function({String? username}) onRefresh,
    required Future<void> Function({String? username}) onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    switch (item.stateType) {
      case DemoListStateType.loading:
        return DemoListLoadingItem(
          message:
              item.message?.isNotEmpty == true
                  ? item.message!
                  : l10n.demoListLoading,
          fillRemaining: true,
        );
      case DemoListStateType.empty:
        return DemoListEmptyItem(
          message:
              item.message?.isNotEmpty == true
                  ? item.message!
                  : l10n.demoListEmpty,
          onRefresh: () {
            onRefresh();
          },
        );
      case DemoListStateType.error:
        return DemoListErrorItem(
          message:
              item.message?.isNotEmpty == true
                  ? item.message!
                  : l10n.demoListLoadFailed,
          onRetry: () {
            onRetry();
          },
        );
    }
  }
}
