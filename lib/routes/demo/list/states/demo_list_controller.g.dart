// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Demo 列表页面控制器。
///
/// 负责维护分页流程、错误恢复以及主结果态 / 加载更多交互态写入。

@ProviderFor(DemoListController)
final demoListControllerProvider = DemoListControllerProvider._();

/// Demo 列表页面控制器。
///
/// 负责维护分页流程、错误恢复以及主结果态 / 加载更多交互态写入。
final class DemoListControllerProvider
    extends $NotifierProvider<DemoListController, DemoListState> {
  /// Demo 列表页面控制器。
  ///
  /// 负责维护分页流程、错误恢复以及主结果态 / 加载更多交互态写入。
  DemoListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'demoListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$demoListControllerHash();

  @$internal
  @override
  DemoListController create() => DemoListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DemoListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DemoListState>(value),
    );
  }
}

String _$demoListControllerHash() =>
    r'c6b1c67db7ca0281979d6739cc5763fb74323f57';

/// Demo 列表页面控制器。
///
/// 负责维护分页流程、错误恢复以及主结果态 / 加载更多交互态写入。

abstract class _$DemoListController extends $Notifier<DemoListState> {
  DemoListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DemoListState, DemoListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DemoListState, DemoListState>,
              DemoListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
