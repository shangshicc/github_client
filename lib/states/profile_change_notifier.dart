import 'package:flutter/material.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/models/index.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}

class UserModel extends ProfileChangeNotifier {
  User? get user => _profile.user;

  // App是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => user != null;

  // 用户信息发生变化, 更新用户信息并通知依赖它的子孙widgets更新
  set user(User? user) {
    _profile.lastLogin = _profile.user?.login;
    _profile.user = user;
    notifyListeners();
    // if (user?.login != (_profile.user?.login ?? "")) {
    //   _profile.lastLogin = _profile.user?.login;
    //   _profile.user = user;
    //   notifyListeners();
    // }
  }
}

class ThemeModel extends ProfileChangeNotifier {
  // 获取当前主题，如果为设置主题，则默认使用蓝色主题
  ColorSwatch get theme => Global.themes
      .firstWhere((e) => e.value == _profile.theme, orElse: () => Colors.blue);

  // 主题改变后，通知其依赖项，新主题会立即生效
  set theme(ColorSwatch color) {
    if (color != theme) {
      _profile.theme = color[500]?.value ?? 0;
      notifyListeners();
    }
  }
}

class LocaleModel extends ProfileChangeNotifier {
  // 获取当前用户的App语言配置locale类，如果为null，则语言跟随系统语言
  Locale? getLocale() {
    final locale = _profile.locale;
    if (locale == null || locale.isEmpty) return null;

    // 兼容历史存储值（旧版本使用 en_US / zh_CN）
    if (locale == 'en_US') return const Locale('en');
    if (locale == 'zh_CN') return const Locale('zh');

    final normalized = locale.replaceAll('-', '_');
    final parts = normalized.split('_');
    if (parts.isEmpty || parts.first.isEmpty) return null;
    if (parts.length == 1) return Locale(parts[0]);
    if (parts.length == 2) return Locale(parts[0], parts[1]);

    return Locale.fromSubtags(
      languageCode: parts[0],
      scriptCode: parts[1],
      countryCode: parts[2],
    );
  }

  // 获取当前Locale的字符串表示
  String? get locale {
    final locale = _profile.locale;
    if (locale == 'en_US') return 'en';
    if (locale == 'zh_CN') return 'zh';
    return locale;
  }

  // 用户改变App语言后，通知依赖项更新，语言会立刻更新
  set locale(String? locale) {
    if (locale != _profile.locale) {
      _profile.locale = locale;
      notifyListeners();
    }
  }
}