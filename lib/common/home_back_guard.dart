import 'package:flutter/foundation.dart';

/// 首页返回拦截的决策结果。
enum HomeBackDecision { showHint, exitApp }

/// 处理首页双击返回退出的时间窗口守卫。
///
/// 该对象只负责纯逻辑决策：首次返回时提示，窗口内再次返回时允许退出。
class HomeBackGuard {
  HomeBackGuard({
    DateTime Function()? now,
    this.exitWindow = const Duration(seconds: 2),
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Duration exitWindow;

  DateTime? _lastBackAttemptAt;

  /// 记录一次返回尝试并给出当前应执行的动作。
  ///
  /// 返回值：首次触发或超时后重试时返回 [HomeBackDecision.showHint]；
  /// 在 [exitWindow] 内再次触发时返回 [HomeBackDecision.exitApp]。
  HomeBackDecision registerBackAttempt() {
    final DateTime now = _now();
    final DateTime? lastBackAttemptAt = _lastBackAttemptAt;
    if (lastBackAttemptAt != null &&
        now.difference(lastBackAttemptAt) <= exitWindow) {
      _lastBackAttemptAt = null;
      return HomeBackDecision.exitApp;
    }
    _lastBackAttemptAt = now;
    return HomeBackDecision.showHint;
  }

  /// 清空上一次返回尝试时间。
  @visibleForTesting
  void reset() {
    _lastBackAttemptAt = null;
  }
}
