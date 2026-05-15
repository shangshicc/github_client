import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Counter 的 Riverpod 状态。
///
/// 该 Provider 用于承载功能2中的最小叶子状态迁移样板，
/// 因为当前计数器只有简单的整数自增逻辑，所以使用 StateProvider 即可。
final StateProvider<int> counterProvider = StateProvider<int>((ref) => 0);
