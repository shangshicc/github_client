// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selector 页面状态控制器。
///
/// 该控制器负责初始化商品列表，并在点击时切换指定商品的收藏状态。

@ProviderFor(Selector)
final selectorProvider = SelectorProvider._();

/// Selector 页面状态控制器。
///
/// 该控制器负责初始化商品列表，并在点击时切换指定商品的收藏状态。
final class SelectorProvider
    extends $NotifierProvider<Selector, SelectorState> {
  /// Selector 页面状态控制器。
  ///
  /// 该控制器负责初始化商品列表，并在点击时切换指定商品的收藏状态。
  SelectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectorHash();

  @$internal
  @override
  Selector create() => Selector();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectorState>(value),
    );
  }
}

String _$selectorHash() => r'cf015eefbe8f77ee0b2700e154f0464ac05fc2b9';

/// Selector 页面状态控制器。
///
/// 该控制器负责初始化商品列表，并在点击时切换指定商品的收藏状态。

abstract class _$Selector extends $Notifier<SelectorState> {
  SelectorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SelectorState, SelectorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SelectorState, SelectorState>,
              SelectorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
