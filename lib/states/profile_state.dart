import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart';

final _log = createLogger('ProfileState');

/// Profile 的 Riverpod 状态控制器。
///
/// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
/// 转换成显式状态更新与显式持久化。
class ProfileNotifier extends Notifier<Profile> {
  /// 构建当前 Profile 的 Riverpod 初始状态。
  ///
  /// 初始状态直接读取 [Global.profile]，确保应用启动后的全局状态与本地
  /// 持久化数据保持一致。
  @override
  Profile build() {
    final Profile initial = Global.profile;
    _log.i(
      'ProfileNotifier initialized, hasUser=${initial.user != null}, '
      'theme=${initial.theme}, locale=${initial.locale ?? "system"}',
    );
    return initial;
  }

  /// 更新登录用户并同步保存 Profile。
  ///
  /// [user] 表示新的登录用户；传入 `null` 时表示退出登录。
  ///
  /// 方法会记录上一次登录名、替换当前用户，并显式触发本地持久化。
  Future<void> updateUser(User? user) async {
    _log.i(
      'updateUser requested, hasUser=${user != null}, '
      'currentTheme=${state.theme}, currentLocale=${state.locale ?? "system"}',
    );
    final Profile previous = _cloneProfile(state);
    final Profile next = _cloneProfile(state);
    final String? previousLogin = previous.user?.login;
    next.lastLogin = previousLogin;
    next.user = user;
    _log.i(
      'updateUser committed, previousLogin=${previousLogin ?? "null"}, '
      'hasUser=${user != null}, theme=${next.theme}, locale=${next.locale ?? "system"}',
    );
    _commit(next);
    try {
      await Global.saveProfile();
      _log.i(
        'updateUser persisted successfully, theme=${Global.profile.theme}, '
        'hasUser=${Global.profile.user != null}, '
        'locale=${Global.profile.locale ?? "system"}',
      );
    } catch (error, stackTrace) {
      _rollback(previous);
      _log.e(
        'updateUser failed to persist profile, rolled back to previous state',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 更新主题并同步保存 Profile。
  ///
  /// [color] 表示用户选择的新主题色。
  ///
  /// 当主题未变化时直接跳过，避免重复写入持久化数据。
  Future<void> updateTheme(MaterialColor color) async {
    _log.i(
      'updateTheme requested, selectedTheme=${color.toARGB32()}, '
      'currentTheme=${state.theme}, hasUser=${state.user != null}',
    );
    if (color.toARGB32() == state.theme) {
      _log.i('updateTheme skipped because selected theme is unchanged');
      return;
    }
    final Profile previous = _cloneProfile(state);
    final Profile next = _cloneProfile(state);
    next.theme = color.toARGB32();
    _log.i(
      'updateTheme committed, theme=${next.theme}, hasUser=${next.user != null}',
    );
    _commit(next);
    _log.i(
      'updateTheme synced to Global.profile, globalTheme=${Global.profile.theme}, '
      'stateTheme=${state.theme}',
    );
    try {
      await Global.saveProfile();
      _log.i(
        'updateTheme persisted successfully, theme=${Global.profile.theme}, '
        'hasUser=${Global.profile.user != null}',
      );
    } catch (error, stackTrace) {
      _rollback(previous);
      _log.e(
        'updateTheme failed to persist profile, rolled back to previous state',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 更新语言并同步保存 Profile。
  ///
  /// [locale] 表示用户选择的语言代码；传入 `null` 时表示跟随系统语言。
  ///
  /// 当语言未变化时直接跳过，避免重复写入持久化数据。
  Future<void> updateLocale(String? locale) async {
    _log.i(
      'updateLocale requested, selectedLocale=${locale ?? "system"}, '
      'currentLocale=${state.locale ?? "system"}',
    );
    if (locale == state.locale) {
      _log.i('updateLocale skipped because selected locale is unchanged');
      return;
    }
    final Profile previous = _cloneProfile(state);
    final Profile next = _cloneProfile(state);
    next.locale = locale;
    _log.i(
      'updateLocale committed, locale=${next.locale ?? "system"}, '
      'hasUser=${next.user != null}',
    );
    _commit(next);
    try {
      await Global.saveProfile();
      _log.i(
        'updateLocale persisted successfully, locale=${Global.profile.locale ?? "system"}, '
        'hasUser=${Global.profile.user != null}',
      );
    } catch (error, stackTrace) {
      _rollback(previous);
      _log.e(
        'updateLocale failed to persist profile, rolled back to previous state',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 同步最新 Profile 到全局单例与 Riverpod 状态。
  ///
  /// [next] 表示更新后的完整 Profile 对象。
  ///
  /// 该方法会同时更新 [Global.profile] 和当前状态，保证全局单例与 UI 监听源一致。
  void _commit(Profile next) {
    Global.profile = next;
    state = next;
  }

  /// 将 Profile 回滚到更新前的快照。
  ///
  /// [previous] 表示更新前的 Profile 快照。
  ///
  /// 该方法只在持久化失败时使用，用于恢复内存状态与全局单例。
  void _rollback(Profile previous) {
    Global.profile = previous;
    state = previous;
  }
}

/// 提供全局 Profile 的 Riverpod 状态入口。
final NotifierProvider<ProfileNotifier, Profile> profileProvider =
    NotifierProvider<ProfileNotifier, Profile>(ProfileNotifier.new);

/// 提供当前登录用户信息。
final Provider<User?> userProvider = Provider<User?>(
  (ref) => ref.watch(profileProvider).user,
);

/// 提供当前登录状态。
final Provider<bool> isLoginProvider = Provider<bool>(
  (ref) => ref.watch(userProvider) != null,
);

/// 提供当前主题色。
final Provider<MaterialColor> themeProvider = Provider<MaterialColor>((ref) {
  final Profile profile = ref.watch(profileProvider);
  final MaterialColor theme = Global.themes.firstWhere(
    (MaterialColor e) => e.toARGB32() == profile.theme,
    orElse: () => Colors.blue,
  );
  _log.i(
    'themeProvider resolved, profileTheme=${profile.theme}, '
    'resolvedTheme=${theme.toARGB32()}, hasUser=${profile.user != null}',
  );
  return theme;
});

/// 提供当前语言标识。
final Provider<String?> localeCodeProvider = Provider<String?>(
  (ref) => _normalizeLocaleCode(ref.watch(profileProvider).locale),
);

/// 提供当前 Locale 对象。
final Provider<Locale?> localeProvider = Provider<Locale?>(
  (ref) => _toLocale(ref.watch(profileProvider).locale),
);

/// 规范化历史存储的 locale 字符串，保持 UI 读取兼容。
///
/// [locale] 表示存储在 Profile 中的语言标识。
String? _normalizeLocaleCode(String? locale) {
  if (locale == null || locale.isEmpty) return null;
  if (locale == 'en_US') return 'en';
  if (locale == 'zh_CN') return 'zh';
  return locale;
}

/// 将 Profile 中的语言字符串转换为 Flutter Locale。
///
/// [locale] 表示存储在 Profile 中的语言标识。
Locale? _toLocale(String? locale) {
  if (locale == null || locale.isEmpty) return null;

  if (locale == 'en_US') return const Locale('en');
  if (locale == 'zh_CN') return const Locale('zh');

  final String normalized = locale.replaceAll('-', '_');
  final List<String> parts = normalized.split('_');
  if (parts.isEmpty || parts.first.isEmpty) return null;
  if (parts.length == 1) return Locale(parts[0]);
  if (parts.length == 2) return Locale(parts[0], parts[1]);

  return Locale.fromSubtags(
    languageCode: parts[0],
    scriptCode: parts[1],
    countryCode: parts[2],
  );
}

/// 深拷贝 Profile，避免在 Riverpod 状态流转中复用可变对象。
///
/// [source] 表示需要复制的 Profile 对象。
Profile _cloneProfile(Profile source) {
  final Map<String, dynamic> json =
      jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>;

  return Profile()
    ..user =
        json['user'] == null
            ? null
            : User.fromJson(json['user'] as Map<String, dynamic>)
    ..token = json['token'] as String?
    ..theme = json['theme'] as num
    ..cache =
        json['cache'] == null
            ? null
            : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>)
    ..lastLogin = json['lastLogin'] as String?
    ..locale = json['locale'] as String?;
}
