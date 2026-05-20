import 'package:github_client_app/common/logger.dart';

final _asyncActionGuardLogger = createLogger('AsyncActionGuard');

/// 异步点击守卫的触发策略。
enum AsyncActionGuardMode {
  /// 执行期间禁止再次进入，适合登录、提交、保存等异步提交动作。
  reentryLock,

  /// 在指定时间窗口内忽略重复触发，适合轻量点击动作。
  debounce,
}

/// 管理异步动作触发门禁的纯工具类。
///
/// 该工具类支持两种互斥策略：
/// - [AsyncActionGuardMode.reentryLock]：执行中禁止重入；
/// - [AsyncActionGuardMode.debounce]：短时间内重复触发防抖。
///
/// 该类不承担 UI 通知与状态分发职责，适合与 Riverpod 或页面局部状态组合使用。
class AsyncActionGuard {
  /// 创建一个异步动作守卫。
  ///
  /// [mode] 表示当前采用的门禁策略。
  /// [debounceDuration] 仅在 [mode] 为 [AsyncActionGuardMode.debounce] 时生效，
  /// 用于限制两次可接受触发之间的最小时间间隔。
  AsyncActionGuard({
    this.mode = AsyncActionGuardMode.reentryLock,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  bool _isRunning = false;
  DateTime? _lastAcceptedAt;

  /// 当前采用的守卫模式。
  final AsyncActionGuardMode mode;

  /// 两次可接受触发之间的最小时间间隔。
  final Duration debounceDuration;

  /// 当前是否存在正在执行中的异步动作。
  bool get isRunning => _isRunning;

  /// 当前时间与最近一次接受触发的时间差是否仍处于防抖窗口内。
  bool get isDebouncing {
    final DateTime? lastAcceptedAt = _lastAcceptedAt;
    if (lastAcceptedAt == null) {
      return false;
    }

    return DateTime.now().difference(lastAcceptedAt) < debounceDuration;
  }

  /// 在守卫保护下执行一个异步动作。
  ///
  /// [action] 表示需要执行的异步回调。
  ///
  /// 返回值：当当前满足策略要求时，返回 [action] 的结果；
  /// 若当前触发被守卫拦截，则直接返回 `null`。
  ///
  /// 副作用：会更新 [isRunning]，并输出开始、跳过、完成与异常日志。
  Future<T?> run<T>(Future<T> Function() action) async {
    if (mode == AsyncActionGuardMode.reentryLock && _isRunning) {
      _asyncActionGuardLogger.i('异步动作被忽略：已有任务执行中');
      return null;
    }

    if (mode == AsyncActionGuardMode.debounce && isDebouncing) {
      _asyncActionGuardLogger.i('异步动作被忽略：仍处于防抖窗口内');
      return null;
    }

    _isRunning = true;
    if (mode == AsyncActionGuardMode.debounce) {
      _lastAcceptedAt = DateTime.now();
    }
    _asyncActionGuardLogger.i('异步动作开始执行');
    try {
      final T result = await action();
      _asyncActionGuardLogger.i('异步动作执行完成');
      return result;
    } catch (error, stackTrace) {
      _asyncActionGuardLogger.e(
        '异步动作执行失败',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _isRunning = false;
    }
  }
}
