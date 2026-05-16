import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_provider.g.dart';

/// Counter 的 Riverpod 状态控制器。
///
/// 该控制器用于承载功能2中的最小叶子状态迁移样板，
/// 当前只负责维护一个简单的整数计数并提供递增能力。
@Riverpod(keepAlive: true)
class Counter extends _$Counter {
  /// 构建计数器初始值。
  ///
  /// 返回值：初始计数值 `0`。
  @override
  int build() => 0;

  /// 将当前计数值递增 1。
  ///
  /// 副作用：会基于当前 [state] 生成新的计数值并写回 Provider 状态。
  void increment() {
    state = state + 1;
  }
}
