import 'package:flutter/material.dart';
import 'package:github_client_app/common/async_action_guard.dart';

/// 带异步点击守卫的 ElevatedButton。
///
/// 该组件支持按策略启用“执行中禁点”或“短时防抖”，并统一提供：
/// 1. `reentryLock` 模式下，执行期间展示 loading 并自动禁用点击；
/// 2. `debounce` 模式下，仅拦截时间窗口内的重复点击，不额外托管 loading；
/// 3. 动作完成或失败后自动恢复组件内部运行态。
class AsyncElevatedButton extends StatefulWidget {
  /// 创建一个带异步点击守卫的 ElevatedButton。
  ///
  /// [onPressed] 表示按钮点击后需要执行的异步动作。
  /// [child] 表示默认展示内容。
  /// [loadingChild] 表示按钮处于执行中时展示的内容；为空时复用 [child]。
  /// [guardMode] 表示当前使用的点击守卫策略。
  /// [debounceDuration] 表示防抖模式下两次允许点击之间的最小时间间隔。
  /// [style]、[focusNode]、[autofocus]、[clipBehavior] 的行为与原生 ElevatedButton 一致。
  const AsyncElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.loadingChild,
    this.guardMode = AsyncActionGuardMode.reentryLock,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  });

  /// 按钮点击后执行的异步动作。
  final Future<void> Function() onPressed;

  /// 按钮空闲态展示内容。
  final Widget child;

  /// 按钮执行中展示内容。
  final Widget? loadingChild;

  /// 按钮点击守卫模式。
  final AsyncActionGuardMode guardMode;

  /// 防抖模式下两次允许点击之间的最小时间间隔。
  final Duration debounceDuration;

  /// 按钮样式配置。
  final ButtonStyle? style;

  /// 按钮焦点节点。
  final FocusNode? focusNode;

  /// 是否在页面构建后自动获取焦点。
  final bool autofocus;

  /// 按钮裁剪行为。
  final Clip clipBehavior;

  @override
  State<AsyncElevatedButton> createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton> {
  late final AsyncActionGuard _guard = AsyncActionGuard(
    mode: widget.guardMode,
    debounceDuration: widget.debounceDuration,
  );
  bool _isRunning = false;

  /// 当前模式是否需要由组件托管 loading 与禁用态。
  bool get _shouldManageRunningState =>
      widget.guardMode == AsyncActionGuardMode.reentryLock;

  /// 在按钮守卫保护下执行点击回调，并同步更新 loading 状态。
  ///
  /// 副作用：会在动作执行前后更新本地 `_isRunning`，从而驱动按钮禁用与 loading UI。
  Future<void> _handlePressed() async {
    await _guard.run<void>(() async {
      if (_shouldManageRunningState && mounted) {
        setState(() {
          _isRunning = true;
        });
      }

      try {
        await widget.onPressed();
      } finally {
        if (_shouldManageRunningState && mounted) {
          setState(() {
            _isRunning = false;
          });
        }
      }
    });
  }

  /// 构建按钮执行中的默认 loading 内容。
  ///
  /// 返回值：当未显式传入 [AsyncElevatedButton.loadingChild] 时，展示一个带转圈指示器的行内布局。
  Widget _buildDefaultLoadingChild() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Flexible(child: widget.child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          _isRunning && _shouldManageRunningState ? null : _handlePressed,
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      child:
          _isRunning && _shouldManageRunningState
              ? (widget.loadingChild ?? _buildDefaultLoadingChild())
              : widget.child,
    );
  }
}
