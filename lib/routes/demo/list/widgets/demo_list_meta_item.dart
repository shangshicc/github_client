import 'package:flutter/material.dart';
import 'package:github_client_app/common/icons.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/index.dart';

/// 仓库核心信息条目。
///
/// 用于展示仓库描述、语言、星标、fork 和更新时间等次级信息。
class DemoListMetaItem extends StatelessWidget {
  /// 创建仓库核心信息条目。
  ///
  /// [repo] 表示当前条目展示的仓库对象。
  const DemoListMetaItem({
    super.key,
    required this.repo,
  });

  /// 当前仓库对象。
  final Repo repo;

  @override
  Widget build(BuildContext context) {
    final description = repo.description?.trim().isNotEmpty == true
        ? repo.description!
        : AppLocalizations.of(context).noDescription;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.25,
                  color: Colors.blueGrey[700],
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.code,
                text: repo.language ?? '--',
              ),
              _MetaChip(
                icon: Icons.star_outline,
                text: '${repo.stargazers_count}',
              ),
              _MetaChip(
                icon: MyIcons.fork,
                text: '${repo.forks_count}',
              ),
              _MetaChip(
                icon: Icons.update,
                text: repo.updated_at,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 仓库信息标签。
///
/// 用于统一展示仓库语言、星标、fork 等核心信息。
class _MetaChip extends StatelessWidget {
  /// 创建仓库信息标签。
  ///
  /// [icon] 表示标签左侧图标。
  /// [text] 表示标签展示文本。
  const _MetaChip({
    required this.icon,
    required this.text,
  });

  /// 标签图标。
  final IconData icon;

  /// 标签文本。
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
        ),
      ],
    );
  }
}
