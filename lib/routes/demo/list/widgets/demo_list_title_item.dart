import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/profile_state.dart';

/// 仓库标题条目。
///
/// 用于展示仓库名，作为多类型列表中的主标题内容。
class DemoListTitleItem extends ConsumerWidget {
  /// 创建仓库标题条目。
  ///
  /// [repo] 表示当前条目展示的仓库对象。
  const DemoListTitleItem({
    super.key,
    required this.repo,
  });

  /// 当前仓库对象。
  final Repo repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialColor themeColor = ref.watch(themeProvider);
    final title = repo.fork ? repo.full_name : repo.name;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: .08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_outlined,
            color: themeColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
