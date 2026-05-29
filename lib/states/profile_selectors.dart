import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/app_theme.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart' as models;

import 'profile_state.dart';
import 'profile_utils.dart';

part 'profile_selectors.g.dart';

final _log = createLogger('ProfileSelectors');

/// 提供当前登录用户信息。
@riverpod
models.User? user(Ref ref) {
  return ref.watch(profileProvider).user;
}

/// 提供当前登录状态。
@riverpod
bool isLogin(Ref ref) {
  return ref.watch(userProvider) != null;
}

/// 提供当前皮肤定义。
@riverpod
AppSkin skin(Ref ref) {
  final models.Profile profile = ref.watch(profileProvider);
  final AppSkin resolvedSkin = AppTheme.resolveSkin(
    profile.skinId,
    legacyArgb: profile.theme,
  );
  _log.i(
    'skinProvider resolved, profileSkinId=${profile.skinId ?? "null"}, '
    'profileTheme=${profile.theme}, resolvedSkin=${resolvedSkin.id}, '
    'hasUser=${profile.user != null}',
  );
  return resolvedSkin;
}

/// 提供当前主题色。
///
/// 保留该 provider 以兼容仍依赖主色板的旧页面；新逻辑优先使用 [skinProvider]
/// 或 `Theme.of(context).colorScheme`。
@riverpod
MaterialColor theme(Ref ref) {
  final AppSkin currentSkin = ref.watch(skinProvider);
  _log.i(
    'themeProvider resolved from skin=${currentSkin.id}, '
    'swatch=${currentSkin.swatch.toARGB32()}',
  );
  return currentSkin.swatch;
}

/// 提供当前语言标识。
@riverpod
String? localeCode(Ref ref) {
  return normalizeLocaleCode(ref.watch(profileProvider).locale);
}

/// 提供当前 Locale 对象。
@riverpod
Locale? locale(Ref ref) {
  return localeCodeToLocale(ref.watch(profileProvider).locale);
}
