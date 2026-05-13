import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/app_localizations.dart';

/// Demo 列表错误状态条目。
///
/// 用于在数据请求失败时展示居中的错误文案和重试按钮。
class DemoListErrorItem extends StatelessWidget {
  /// 创建错误状态条目。
  ///
  /// [message] 表示错误提示文案。
  /// [onRetry] 表示点击按钮后的重试回调。
  const DemoListErrorItem({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// 错误提示文案。
  final String message;

  /// 重试回调。
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).demoListRefreshData),
            ),
          ],
        ),
      ),
    );
  }
}
