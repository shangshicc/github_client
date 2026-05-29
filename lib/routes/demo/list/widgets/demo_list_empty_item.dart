import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/app_localizations.dart';

/// Demo 列表空数据状态条目。
///
/// 用于在接口成功但返回数据为 0 时展示居中的空态信息和刷新按钮。
class DemoListEmptyItem extends StatelessWidget {
  /// 创建空数据状态条目。
  ///
  /// [message] 表示空态提示文案。
  /// [onRefresh] 表示点击按钮后的刷新回调。
  const DemoListEmptyItem({
    super.key,
    required this.message,
    required this.onRefresh,
  });

  /// 空态提示文案。
  final String message;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).demoListRefreshData),
            ),
          ],
        ),
      ),
    );
  }
}
