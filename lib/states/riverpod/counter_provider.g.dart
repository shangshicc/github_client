// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Counter 的 Riverpod 状态控制器。
///
/// 该控制器用于承载功能2中的最小叶子状态迁移样板，
/// 当前只负责维护一个简单的整数计数并提供递增能力。

@ProviderFor(Counter)
final counterProvider = CounterProvider._();

/// Counter 的 Riverpod 状态控制器。
///
/// 该控制器用于承载功能2中的最小叶子状态迁移样板，
/// 当前只负责维护一个简单的整数计数并提供递增能力。
final class CounterProvider extends $NotifierProvider<Counter, int> {
  /// Counter 的 Riverpod 状态控制器。
  ///
  /// 该控制器用于承载功能2中的最小叶子状态迁移样板，
  /// 当前只负责维护一个简单的整数计数并提供递增能力。
  CounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterHash();

  @$internal
  @override
  Counter create() => Counter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterHash() => r'43d6aa13f2b8c645854e0c5b16a49f71a5f41ddf';

/// Counter 的 Riverpod 状态控制器。
///
/// 该控制器用于承载功能2中的最小叶子状态迁移样板，
/// 当前只负责维护一个简单的整数计数并提供递增能力。

abstract class _$Counter extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
