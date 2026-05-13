import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/app_localizations.dart';

/// NestedScrollView 经典业务 Demo 页面。
///
/// 页面使用“个人主页 + 吸顶 Tab”的常见结构，演示外层头部和内层列表的联动滚动。
class DemoNestedScrollRoute extends StatelessWidget {
  const DemoNestedScrollRoute({super.key});

  /// Demo 使用的固定标签页配置。
  static const List<_NestedTabData> _tabs = [
    _NestedTabData(
      key: 'repositories',
      titleBuilder: _tabRepositoriesTitle,
      items: <String>[
        'flutter_github_client',
        'github_api_wrapper',
        'design_system_demo',
        'issue_dashboard',
        'repo_search_playground',
        'profile_timeline_demo',
      ],
    ),
    _NestedTabData(
      key: 'activity',
      titleBuilder: _tabActivityTitle,
      items: <String>[
        'Opened issue #128 · 优化列表空态样式',
        'Merged PR #205 · 接入主题切换缓存',
        'Commented on flutter/flutter · NestedScrollView 使用讨论',
        'Reviewed PR #212 · 修复分页重复请求',
        'Published release v1.3.0 · 改善本地化流程',
        'Created discussion · 个人主页滚动交互设计',
      ],
    ),
    _NestedTabData(
      key: 'stars',
      titleBuilder: _tabStarsTitle,
      items: <String>[
        'flutter/flutter',
        'dart-lang/sdk',
        'flutter/packages',
        'invertase/melos',
        'hyochan/flutter_slidable',
        'jonataslaw/getx',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: 280,
                  forceElevated: innerBoxIsScrolled,
                  title: Text(l10n.demoNestedScroll),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildFlexibleHeader(context),
                  ),
                  bottom: TabBar(
                    tabs: _tabs
                        .map(
                          (tab) => Tab(
                            text: tab.titleBuilder(l10n),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs
                .map(
                  (tab) => _NestedScrollTabView(
                    tab: tab,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// 构建顶部可折叠的个人主页头部区域。
  ///
  /// [context] 表示当前页面上下文，用于读取主题和本地化资源。
  Widget _buildFlexibleHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 72, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chen Wei',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@chenwei-dev',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.demoNestedScrollProfileBio,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      value: '32',
                      label: l10n.demoNestedScrollStatsRepos,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      value: '1.2k',
                      label: l10n.demoNestedScrollStatsFollowers,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      value: '186',
                      label: l10n.demoNestedScrollStatsFollowing,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部统计信息卡片。
  ///
  /// [context] 表示当前页面上下文。
  /// [value] 表示统计值。
  /// [label] 表示统计项文案。
  Widget _buildStatCard({
    required BuildContext context,
    required String value,
    required String label,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 返回“仓库”标签的标题文案。
  ///
  /// [l10n] 表示当前语言资源对象。
  static String _tabRepositoriesTitle(AppLocalizations l10n) {
    return l10n.demoNestedScrollTabRepositories;
  }

  /// 返回“动态”标签的标题文案。
  ///
  /// [l10n] 表示当前语言资源对象。
  static String _tabActivityTitle(AppLocalizations l10n) {
    return l10n.demoNestedScrollTabActivity;
  }

  /// 返回“星标”标签的标题文案。
  ///
  /// [l10n] 表示当前语言资源对象。
  static String _tabStarsTitle(AppLocalizations l10n) {
    return l10n.demoNestedScrollTabStars;
  }
}

/// 单个标签页的数据定义。
class _NestedTabData {
  const _NestedTabData({
    required this.key,
    required this.titleBuilder,
    required this.items,
  });

  final String key;
  final String Function(AppLocalizations l10n) titleBuilder;
  final List<String> items;
}

/// NestedScrollView 内层标签页列表。
class _NestedScrollTabView extends StatelessWidget {
  const _NestedScrollTabView({required this.tab});

  final _NestedTabData tab;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>('nested_scroll_${tab.key}'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList.builder(
                itemCount: tab.items.length,
                itemBuilder: (context, index) {
                  return _NestedScrollListItem(
                    title: tab.items[index],
                    subtitle: _buildSubtitle(
                      context: context,
                      itemTitle: tab.items[index],
                      index: index,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建列表项的副标题文案。
  ///
  /// [context] 表示当前页面上下文，用于读取本地化资源。
  /// [itemTitle] 表示当前主标题内容。
  /// [index] 表示当前列表项序号。
  String _buildSubtitle({
    required BuildContext context,
    required String itemTitle,
    required int index,
  }) {
    final l10n = AppLocalizations.of(context);
    return l10n.demoNestedScrollListItemSubtitle(index + 1, itemTitle);
  }
}

/// 标签页列表项。
class _NestedScrollListItem extends StatelessWidget {
  const _NestedScrollListItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.widgets_outlined),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
