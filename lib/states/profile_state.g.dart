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

String _$profileHash() => r'3f25f3deed1cff4e96dd5c15f07b8b7e3ae0381d';

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

/// 提供当前登录用户信息。

@ProviderFor(user)
final userProvider = UserProvider._();

/// 提供当前登录用户信息。

final class UserProvider
    extends $FunctionalProvider<models.User?, models.User?, models.User?>
    with $Provider<models.User?> {
  /// 提供当前登录用户信息。
  UserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @$internal
  @override
  $ProviderElement<models.User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  models.User? create(Ref ref) {
    return user(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(models.User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<models.User?>(value),
    );
  }
}

String _$userHash() => r'904bb25588af1e22f9703724818233bb28a69eab';

/// 提供当前登录状态。

@ProviderFor(isLogin)
final isLoginProvider = IsLoginProvider._();

/// 提供当前登录状态。

final class IsLoginProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 提供当前登录状态。
  IsLoginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLoginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLoginHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isLogin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLoginHash() => r'15c34326049e9b7847078b49d09b569dba1c2c12';

/// 提供当前主题色。

@ProviderFor(theme)
final themeProvider = ThemeProvider._();

/// 提供当前主题色。

final class ThemeProvider
    extends $FunctionalProvider<MaterialColor, MaterialColor, MaterialColor>
    with $Provider<MaterialColor> {
  /// 提供当前主题色。
  ThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeHash();

  @$internal
  @override
  $ProviderElement<MaterialColor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MaterialColor create(Ref ref) {
    return theme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MaterialColor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MaterialColor>(value),
    );
  }
}

String _$themeHash() => r'716f3c84fa925f35b1ac762add32fae2b2ae18b9';

/// 提供当前语言标识。

@ProviderFor(localeCode)
final localeCodeProvider = LocaleCodeProvider._();

/// 提供当前语言标识。

final class LocaleCodeProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// 提供当前语言标识。
  LocaleCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeCodeHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return localeCode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$localeCodeHash() => r'5342f43dc63e0e02c18783e329cdcaa13862e743';

/// 提供当前 Locale 对象。

@ProviderFor(locale)
final localeProvider = LocaleProvider._();

/// 提供当前 Locale 对象。

final class LocaleProvider
    extends $FunctionalProvider<Locale?, Locale?, Locale?>
    with $Provider<Locale?> {
  /// 提供当前 Locale 对象。
  LocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeHash();

  @$internal
  @override
  $ProviderElement<Locale?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale? create(Ref ref) {
    return locale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeHash() => r'b11329e7269b86dcd01a9a78a150cde505aae54b';
