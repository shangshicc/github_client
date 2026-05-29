import 'package:flutter/material.dart';
import 'package:github_client_app/l10n/app_localizations.dart';

/// Demo 列表加载状态条目。
///
/// 用于展示首次进入、刷新或加载更多时的 loading 反馈。
class DemoListLoadingItem extends StatelessWidget {
  /// 创建加载状态条目。
  ///
  /// [message] 表示 loading 下方展示的提示文案。
  /// [fillRemaining] 表示是否填充剩余页面高度，适用于整页 loading。
  /// [verticalPadding] 表示非整页模式下的上下留白。
  /// [indicatorSize] 表示 loading 指示器的宽高。
  /// [indicatorStrokeWidth] 表示 loading 指示器描边宽度。
  /// [spacing] 表示指示器与文案之间的垂直间距。
  const DemoListLoadingItem({
    super.key,
    this.message,
    this.fillRemaining = false,
    this.verticalPadding = 24,
    this.indicatorSize = 28,
    this.indicatorStrokeWidth = 2.5,
    this.spacing = 12,
  });

  /// loading 提示文案。
  final String? message;

  /// 是否填充剩余页面高度。
  final bool fillRemaining;

  /// 非整页模式下的上下留白。
  final double verticalPadding;

  /// loading 指示器宽高。
  final double indicatorSize;

  /// loading 指示器描边宽度。
  final double indicatorStrokeWidth;

  /// 指示器与文案之间的垂直间距。
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final TextStyle? messageStyle = Theme.of(context).textTheme.bodyMedium;
    final Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(strokeWidth: indicatorStrokeWidth),
          ),
          SizedBox(height: spacing),
          Text(
            message ?? AppLocalizations.of(context).demoListLoading,
            style: messageStyle,
          ),
        ],
      ),
    );

    if (fillRemaining) {
      return SizedBox.expand(child: content);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: content,
    );
  }
}
