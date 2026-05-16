// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Profile 的 Riverpod 状态控制器。
///
/// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
/// 转换成显式状态更新与显式持久化。

@ProviderFor(Profile)
final profileProvider = ProfileProvider._();

/// Profile 的 Riverpod 状态控制器。
///
/// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
/// 转换成显式状态更新与显式持久化。
final class ProfileProvider extends $NotifierProvider<Profile, models.Profile> {
  /// Profile 的 Riverpod 状态控制器。
  ///
  /// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
  /// 转换成显式状态更新与显式持久化。
  ProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  Profile create() => Profile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(models.Profile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<models.Profile>(value),
    );
  }
}

String _$profileHash() => r'1c5142615ff95e1b71fbe5db55d78dffe9455d65';

/// Profile 的 Riverpod 状态控制器。
///
/// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
/// 转换成显式状态更新与显式持久化。

abstract class _$Profile extends $Notifier<models.Profile> {
  models.Profile build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<models.Profile, models.Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<models.Profile, models.Profile>,
              models.Profile,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
