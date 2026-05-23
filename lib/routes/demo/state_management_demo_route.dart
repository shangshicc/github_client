import 'package:flutter/material.dart';

/// 状态管理 Demo 页面。
///
/// 该页面集中承载两个仅使用 `setState` 的局部状态示例，用于演示
/// “父组件管理子组件展示状态”与“子组件管理内部状态、父组件管理外部状态”
/// 两类边界。当前步骤仅搭建路由骨架与可交互的基础结构，后续步骤再按计划补强细节。
class StateManagementDemoRoute extends StatelessWidget {
  /// 创建状态管理 Demo 页面。
  const StateManagementDemoRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Management Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _ParentOwnsChildStateSection(),
          SizedBox(height: 16),
          _SplitStateOwnershipSection(),
        ],
      ),
    );
  }
}

/// 父组件直接拥有并更新子组件展示状态的 Demo 区块。
class _ParentOwnsChildStateSection extends StatefulWidget {
  /// 创建父组件管理子组件状态区块。
  const _ParentOwnsChildStateSection();

  @override
  State<_ParentOwnsChildStateSection> createState() =>
      _ParentOwnsChildStateSectionState();
}

class _ParentOwnsChildStateSectionState
    extends State<_ParentOwnsChildStateSection> {
  int _selectedCount = 0;

  /// 增加当前由父组件维护的计数值。
  void _incrementSelectedCount() {
    setState(() {
      _selectedCount += 1;
    });
  }

  /// 重置当前由父组件维护的计数值。
  void _resetSelectedCount() {
    setState(() {
      _selectedCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _DemoSectionCard(
      title: 'Demo 1：父组件管理子组件状态',
      description: '父组件统一持有计数状态，子组件只负责展示与触发事件。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusBadge(label: '父组件当前计数', value: '$_selectedCount'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              ElevatedButton(
                key: const ValueKey<String>('parent-state-add-button'),
                onPressed: _incrementSelectedCount,
                child: const Text('父组件 +1'),
              ),
              OutlinedButton(
                key: const ValueKey<String>('parent-state-reset-button'),
                onPressed: _resetSelectedCount,
                child: const Text('重置'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatePreviewTile(
            title: '子组件展示区',
            subtitle: '当前展示完全依赖父组件传入的状态值。',
            trailing: Text(
              '$_selectedCount',
              key: const ValueKey<String>('parent-state-value'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// 子组件管理内部瞬时状态、父组件管理外部业务状态的 Demo 区块。
class _SplitStateOwnershipSection extends StatefulWidget {
  /// 创建内外状态拆分管理区块。
  const _SplitStateOwnershipSection();

  @override
  State<_SplitStateOwnershipSection> createState() =>
      _SplitStateOwnershipSectionState();
}

class _SplitStateOwnershipSectionState
    extends State<_SplitStateOwnershipSection> {
  bool _isSubscribed = false;

  /// 切换父组件维护的业务状态。
  void _toggleSubscription() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _DemoSectionCard(
      title: 'Demo 2：子组件管理内部状态，父组件管理外部状态',
      description: '父组件维护订阅结果，子组件只管理自己的瞬时高亮反馈。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusBadge(label: '父组件业务状态', value: _isSubscribed ? '已订阅' : '未订阅'),
          const SizedBox(height: 12),
          _SubscriptionToggleCard(
            isSubscribed: _isSubscribed,
            onToggleSubscription: _toggleSubscription,
          ),
        ],
      ),
    );
  }
}

/// 统一承载单个 Demo 区块的卡片容器。
class _DemoSectionCard extends StatelessWidget {
  /// 创建 Demo 区块卡片。
  ///
  /// [title] 表示区块标题。
  /// [description] 表示区块说明。
  /// [child] 表示区块主体内容。
  const _DemoSectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  /// 区块标题。
  final String title;

  /// 区块说明。
  final String description;

  /// 区块主体内容。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// 展示当前状态摘要的小型标签。
class _StatusBadge extends StatelessWidget {
  /// 创建状态摘要标签。
  ///
  /// [label] 表示状态名称。
  /// [value] 表示状态值。
  const _StatusBadge({required this.label, required this.value});

  /// 状态名称。
  final String label;

  /// 状态值。
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

/// 统一展示示例中的状态说明条目。
class _StatePreviewTile extends StatelessWidget {
  /// 创建状态说明条目。
  ///
  /// [title] 表示主标题。
  /// [subtitle] 表示副标题说明。
  /// [trailing] 表示右侧状态展示组件。
  const _StatePreviewTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  /// 主标题。
  final String title;

  /// 副标题说明。
  final String subtitle;

  /// 右侧状态展示组件。
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}

/// 通过子组件持有内部高亮态，演示与父组件业务状态分离的交互卡片。
class _SubscriptionToggleCard extends StatefulWidget {
  /// 创建订阅切换交互卡片。
  ///
  /// [isSubscribed] 表示父组件当前维护的业务状态。
  /// [onToggleSubscription] 表示通知父组件切换业务状态的回调。
  const _SubscriptionToggleCard({
    required this.isSubscribed,
    required this.onToggleSubscription,
  });

  /// 父组件当前维护的业务状态。
  final bool isSubscribed;

  /// 通知父组件切换业务状态的回调。
  final VoidCallback onToggleSubscription;

  @override
  State<_SubscriptionToggleCard> createState() =>
      _SubscriptionToggleCardState();
}

class _SubscriptionToggleCardState extends State<_SubscriptionToggleCard> {
  bool _isHighlighted = false;

  /// 切换子组件内部维护的高亮状态。
  void _toggleHighlight() {
    setState(() {
      _isHighlighted = !_isHighlighted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            _isHighlighted
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '子组件内部高亮：${_isHighlighted ? '开启' : '关闭'}',
                  key: const ValueKey<String>('child-highlight-label'),
                ),
              ),
              Switch(
                key: const ValueKey<String>('child-highlight-switch'),
                value: _isHighlighted,
                onChanged: (_) => _toggleHighlight(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '父组件业务结果：${widget.isSubscribed ? '已订阅' : '未订阅'}',
            key: const ValueKey<String>('parent-business-label'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey<String>('parent-business-toggle-button'),
            onPressed: widget.onToggleSubscription,
            child: Text(widget.isSubscribed ? '取消订阅' : '立即订阅'),
          ),
        ],
      ),
    );
  }
}
