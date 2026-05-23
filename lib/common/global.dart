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
  // 是否为release版
  static bool get isRelease => const bool.fromEnvironment("dart.vm.product");

  // 初始化全局变量，会在App启动时执行
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    final profileJson = _prefs.getString("profile");
    if (profileJson != null) {
      try {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        if (decoded['user'] != null) {
          profile = Profile.fromJson(decoded);
          _log.i(
            'Global.init loaded stored profile, hasUser=${profile.user != null}, '
            'theme=${profile.theme}, locale=${profile.locale ?? "system"}',
          );
        } else {
          profile = Profile()..theme = 0;
          _log.w(
            'Global.init found stored profile without user, reset to default profile, '
            'theme=${profile.theme}, locale=${profile.locale ?? "system"}',
          );
        }
      } catch (error, stackTrace) {
        profile = Profile()..theme = 0;
        _log.e(
          'Global.init failed to read stored profile, fell back to default profile',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      // 默认主题索引为0， 代表蓝色
      profile = Profile()..theme = 0;
      _log.i(
        'Global.init did not find stored profile, initialized default profile, '
        'theme=${profile.theme}, locale=${profile.locale ?? "system"}',
      );
    }

    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;

    // 初始化网络请求相关配置
    Git.init();
    _log.i(
      'Global.init finished, hasUser=${profile.user != null}, '
      'theme=${profile.theme}, locale=${profile.locale ?? "system"}',
    );
  }

  /// 将当前 Profile 持久化到本地存储。
  ///
  /// 该方法会把内存中的 [profile] 编码后写入 `SharedPreferences`，
  /// 用于保存主题、语言、登录信息等全局配置。
  static Future<void> saveProfile() async {
    try {
      await _prefs.setString("profile", jsonEncode(profile.toJson()));
      _log.i(
        'Global.saveProfile persisted profile, theme=${profile.theme}, '
        'hasUser=${profile.user != null}, locale=${profile.locale ?? "system"}',
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
}
