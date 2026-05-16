// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_selectors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$localeCodeHash() => r'64d084c895fefcb7b0f7df191da874acdf993b1e';

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

String _$localeHash() => r'bdb4f83d7816d15bf5452e920422a8a286fe315e';
