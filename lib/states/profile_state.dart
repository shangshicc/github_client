import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart' as models;

import 'profile_utils.dart';

export 'profile_selectors.dart';

part 'profile_state.g.dart';

final _log = createLogger('ProfileState');

/// Profile 的 Riverpod 状态控制器。
///
/// 该控制器把 Global.profile 作为唯一真源，并把用户、主题、语言变更
/// 转换成显式状态更新与显式持久化。
@Riverpod(keepAlive: true)
class Profile extends _$Profile {
  /// 构建当前 Profile 的 Riverpod 初始状态。
  ///
  /// 初始状态直接读取 [Global.profile]，确保应用启动后的全局状态与本地
  /// 持久化数据保持一致。
  @override
  models.Profile build() {
    final models.Profile initial = Global.profile;
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
  Future<void> updateUser(models.User? user) async {
    _log.i(
      'updateUser requested, hasUser=${user != null}, '
      'currentTheme=${state.theme}, currentLocale=${state.locale ?? "system"}',
    );
    final models.Profile previous = cloneProfile(state);
    final models.Profile next = cloneProfile(state);
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
    final models.Profile previous = cloneProfile(state);
    final models.Profile next = cloneProfile(state);
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
    final models.Profile previous = cloneProfile(state);
    final models.Profile next = cloneProfile(state);
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
  void _commit(models.Profile next) {
    Global.profile = next;
    state = next;
  }

  /// 将 Profile 回滚到更新前的快照。
  ///
  /// [previous] 表示更新前的 Profile 快照。
  ///
  /// 该方法只在持久化失败时使用，用于恢复内存状态与全局单例。
  void _rollback(models.Profile previous) {
    Global.profile = previous;
    state = previous;
  }
}
