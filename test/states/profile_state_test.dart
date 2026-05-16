import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
    Global.profile = Profile()..theme = Global.themes.first.toARGB32();
  });

  test('updateUser 在 user 与 cache 为空时不应因克隆 Profile 崩溃', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);
    final User user =
        User()
          ..login = 'tester'
          ..id = 1;

    await expectLater(notifier.updateUser(user), completes);

    final Profile profile = container.read(profileProvider);
    expect(profile.user?.login, 'tester');
    expect(profile.lastLogin, isNull);
  });

  test('updateTheme 会同步更新状态、Global.profile 与本地持久化', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);

    await expectLater(notifier.updateTheme(Colors.red), completes);

    final Profile profile = container.read(profileProvider);
    expect(profile.theme, Colors.red.toARGB32());
    expect(Global.profile.theme, Colors.red.toARGB32());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile');
    expect(profileJson, isNotNull);

    final Map<String, dynamic> decoded =
        jsonDecode(profileJson!) as Map<String, dynamic>;
    expect(decoded['theme'], Colors.red.toARGB32());
  });

  test('updateLocale 会同步更新状态、localeProvider 与本地持久化', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);

    await expectLater(notifier.updateLocale('en'), completes);

    final Profile profile = container.read(profileProvider);
    expect(profile.locale, 'en');
    expect(Global.profile.locale, 'en');
    expect(container.read(localeCodeProvider), 'en');
    expect(container.read(localeProvider), const Locale('en'));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile');
    expect(profileJson, isNotNull);

    final Map<String, dynamic> decoded =
        jsonDecode(profileJson!) as Map<String, dynamic>;
    expect(decoded['locale'], 'en');
  });

  test('localeProvider 会兼容历史 locale 存储值', () {
    Global.profile =
        Profile()
          ..theme = Global.themes.first.toARGB32()
          ..locale = 'en_US';

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeCodeProvider), 'en');
    expect(container.read(localeProvider), const Locale('en'));
  });

  test('updateLocale 传入 null 时会回退为跟随系统语言并持久化', () async {
    Global.profile =
        Profile()
          ..theme = Global.themes.first.toARGB32()
          ..locale = 'zh';

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);

    await expectLater(notifier.updateLocale(null), completes);

    final Profile profile = container.read(profileProvider);
    expect(profile.locale, isNull);
    expect(Global.profile.locale, isNull);
    expect(container.read(localeCodeProvider), isNull);
    expect(container.read(localeProvider), isNull);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('profile');
    expect(profileJson, isNotNull);

    final Map<String, dynamic> decoded =
        jsonDecode(profileJson!) as Map<String, dynamic>;
    expect(decoded['locale'], isNull);
  });

  test('updateTheme 持久化失败时会回滚内存状态与 Global.profile', () async {
    final SharedPreferencesStorePlatform originalStore =
        SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = _FailingSetValueStore(
      originalStore,
    );
    addTearDown(() => SharedPreferencesStorePlatform.instance = originalStore);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);
    final int previousTheme = container.read(profileProvider).theme.toInt();

    await expectLater(
      notifier.updateTheme(Colors.red),
      throwsA(isA<PlatformException>()),
    );

    expect(container.read(profileProvider).theme, previousTheme);
    expect(Global.profile.theme, previousTheme);
  });

  test('updateLocale 持久化失败时会回滚内存状态与 Global.profile', () async {
    Global.profile =
        Profile()
          ..theme = Global.themes.first.toARGB32()
          ..locale = 'zh';

    final SharedPreferencesStorePlatform originalStore =
        SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = _FailingSetValueStore(
      originalStore,
    );
    addTearDown(() => SharedPreferencesStorePlatform.instance = originalStore);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);

    await expectLater(
      notifier.updateLocale('en'),
      throwsA(isA<PlatformException>()),
    );

    expect(container.read(profileProvider).locale, 'zh');
    expect(Global.profile.locale, 'zh');
    expect(container.read(localeProvider), const Locale('zh'));
  });

  test('主题与语言持久化后重新初始化仍可恢复', () async {
    Global.profile =
        Profile()
          ..theme = Global.themes.first.toARGB32()
          ..locale = 'zh'
          ..cache =
              (CacheConfig()
                ..enable = true
                ..maxAge = 3600
                ..maxCount = 100)
          ..user =
              (User()
                ..login = 'restored-user'
                ..id = 9527);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ProfileNotifier notifier = container.read(profileProvider.notifier);
    await notifier.updateTheme(Colors.red);
    await notifier.updateLocale('en');

    final String? persistedProfile = (await SharedPreferences.getInstance())
        .getString('profile');
    expect(persistedProfile, isNotNull);

    await Global.init();

    expect(Global.profile.theme, Colors.red.toARGB32());
    expect(Global.profile.locale, 'en');

    final ProviderContainer restoredContainer = ProviderContainer();
    addTearDown(restoredContainer.dispose);
    expect(restoredContainer.read(themeProvider), Colors.red);
    expect(restoredContainer.read(localeProvider), const Locale('en'));
  });
}

class _FailingSetValueStore extends SharedPreferencesStorePlatform {
  _FailingSetValueStore(this._delegate);

  final SharedPreferencesStorePlatform _delegate;

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    throw PlatformException(
      code: 'write_failed',
      message: 'Simulated shared_preferences write failure',
    );
  }

  @override
  Future<Map<String, Object>> getAll() => _delegate.getAll();

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) =>
      _delegate.clearWithParameters(parameters);

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) => _delegate.getAllWithParameters(parameters);
}
