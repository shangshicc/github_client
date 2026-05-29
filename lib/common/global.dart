import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'git_api.dart';
import 'net_cache.dart';

final _log = createLogger('Global');

class Global {
  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  // 网络缓存对象
  static NetCache netCache = NetCache();

  // 可选的主题列表
  static List<MaterialColor> get themes => AppTheme.palettes;

  /// 可选的皮肤列表。
  static List<AppSkin> get skins => AppTheme.skins;

  // 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  // 初始化全局变量，会在App启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    final profileJson = _prefs.getString("profile");
    if (profileJson != null) {
      try {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        if (decoded['user'] != null) {
          profile = Profile.fromJson(decoded);
          _normalizeProfileTheme();
          _log.i(
            'Global.init loaded stored profile, hasUser=${profile.user != null}, '
            'skinId=${profile.skinId ?? "null"}, theme=${profile.theme}, '
            'locale=${profile.locale ?? "system"}',
          );
        } else {
          profile = _createDefaultProfile();
          _log.w(
            'Global.init found stored profile without user, reset to default profile, '
            'skinId=${profile.skinId ?? "null"}, theme=${profile.theme}, '
            'locale=${profile.locale ?? "system"}',
          );
        }
      } catch (error, stackTrace) {
        profile = _createDefaultProfile();
        _log.e(
          'Global.init failed to read stored profile, fell back to default profile',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      profile = _createDefaultProfile();
      _log.i(
        'Global.init did not find stored profile, initialized default profile, '
        'skinId=${profile.skinId ?? "null"}, theme=${profile.theme}, '
        'locale=${profile.locale ?? "system"}',
      );
    }

    profile.cache =
        profile.cache ?? CacheConfig()
          ..enable = true
          ..maxAge = 3600
          ..maxCount = 100;

    // 初始化网络请求相关配置
    Git.init();
    _log.i(
      'Global.init finished, hasUser=${profile.user != null}, '
      'skinId=${profile.skinId ?? "null"}, theme=${profile.theme}, '
      'locale=${profile.locale ?? "system"}',
    );
  }

  /// 将当前 Profile 持久化到本地存储。
  static Future<void> saveProfile() async {
    try {
      await _prefs.setString("profile", jsonEncode(profile.toJson()));
      _log.i(
        'Global.saveProfile persisted profile, skinId=${profile.skinId ?? "null"}, '
        'theme=${profile.theme}, hasUser=${profile.user != null}, '
        'locale=${profile.locale ?? "system"}',
      );
    } catch (error, stackTrace) {
      _log.e(
        'Global.saveProfile failed to persist profile',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Profile _createDefaultProfile() {
    return Profile()
      ..theme = AppTheme.defaultSkin.swatch.toARGB32()
      ..skinId = AppTheme.defaultSkin.id;
  }

  static void _normalizeProfileTheme() {
    final AppSkin resolvedSkin = AppTheme.resolveSkin(
      profile.skinId,
      legacyArgb: profile.theme,
    );
    profile.skinId = resolvedSkin.id;
    profile.theme = resolvedSkin.swatch.toARGB32();
  }
}
