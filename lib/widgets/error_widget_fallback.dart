import 'package:flutter/material.dart';

/// 用于局部异常提醒的错误提示模块。
class ErrorWidgetFallback extends StatelessWidget {
  /// 创建错误提醒模块。
  const ErrorWidgetFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          elevation: 0,
          color: const Color(0xFFFFF4F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF3C7C7)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: _FallbackContent(
              title: '当前模块暂时不可用',
              message: '这部分内容刚刚发生异常，你可以稍后重试或继续使用页面其他功能。',
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackContent extends StatelessWidget {
  const _FallbackContent({
    required this.title,
    required this.message,
    this.iconSize = 40,
  });

  final String title;
  final String message;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.error_outline, size: iconSize, color: Colors.redAccent),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}
