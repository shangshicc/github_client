import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:github_client_app/common/app_theme.dart';
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
      'ProfileNotifier initialized, skinId=${initial.skinId ?? "null"}, '
      'theme=${initial.theme}, locale=${initial.locale ?? "system"}',
    );
    return initial;
  }

  /// 更新登录用户并同步保存 Profile。
  Future<void> updateUser(models.User? user) async {
    _log.i(
      'updateUser requested, hasUser=${user != null}, '
      'currentSkinId=${state.skinId ?? "null"}, '
      'currentLocale=${state.locale ?? "system"}',
    );
    final models.Profile previous = cloneProfile(state);
    final models.Profile next = cloneProfile(state);
    final String? previousLogin = previous.user?.login;
    next.lastLogin = previousLogin;
    next.user = user;
    _log.i(
      'updateUser committed, previousLogin=${previousLogin ?? "null"}, '
      'hasUser=${user != null}, skinId=${next.skinId ?? "null"}, '
      'locale=${next.locale ?? "system"}',
    );
    _commit(next);
    try {
      await Global.saveProfile();
      _log.i(
        'updateUser persisted successfully, skinId=${Global.profile.skinId ?? "null"}, '
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

  /// 更新主题皮肤并同步保存 Profile。
  ///
  /// [skinId] 表示用户选择的新皮肤标识。
  Future<void> updateSkin(String skinId) async {
    final AppSkin selectedSkin = AppTheme.resolveSkin(skinId);
    final String currentSkinId = AppTheme.resolveSkinId(
      state.skinId,
      legacyArgb: state.theme,
    );
    _log.i(
      'updateSkin requested, selectedSkin=$skinId, currentSkin=$currentSkinId, '
      'hasUser=${state.user != null}',
    );
    if (selectedSkin.id == currentSkinId) {
      _log.i('updateSkin skipped because selected skin is unchanged');
      return;
    }

    final models.Profile previous = cloneProfile(state);
    final models.Profile next =
        cloneProfile(state)
          ..skinId = selectedSkin.id
          ..theme = selectedSkin.swatch.toARGB32();
    _log.i(
      'updateSkin committed, skinId=${next.skinId}, theme=${next.theme}, '
      'hasUser=${next.user != null}',
    );
    _commit(next);
    try {
      await Global.saveProfile();
      _log.i(
        'updateSkin persisted successfully, skinId=${Global.profile.skinId ?? "null"}, '
        'theme=${Global.profile.theme}, hasUser=${Global.profile.user != null}',
      );
    } catch (error, stackTrace) {
      _rollback(previous);
      _log.e(
        'updateSkin failed to persist profile, rolled back to previous state',
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
  /// 为兼容旧调用，内部会自动映射到对应皮肤。
  Future<void> updateTheme(MaterialColor color) async {
    final AppSkin selectedSkin = AppTheme.resolveSkinFromColor(color);
    await updateSkin(selectedSkin.id);
  }

  /// 更新语言并同步保存 Profile。
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
  void _commit(models.Profile next) {
    Global.profile = next;
    state = next;
  }

  /// 将 Profile 回滚到更新前的快照。
  void _rollback(models.Profile previous) {
    Global.profile = previous;
    state = previous;
  }
}
