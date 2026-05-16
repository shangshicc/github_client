import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/global.dart';
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

/// 提供当前主题色。
@riverpod
MaterialColor theme(Ref ref) {
  final models.Profile profile = ref.watch(profileProvider);
  final MaterialColor theme = Global.themes.firstWhere(
    (MaterialColor e) => e.toARGB32() == profile.theme,
    orElse: () => Colors.blue,
  );
  _log.i(
    'themeProvider resolved, profileTheme=${profile.theme}, '
    'resolvedTheme=${theme.toARGB32()}, hasUser=${profile.user != null}',
  );
  return theme;
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
