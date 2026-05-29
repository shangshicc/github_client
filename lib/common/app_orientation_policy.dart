import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'logger.dart';

final _log = createLogger('AppOrientationPolicy');

/// 应用方向策略工具。
///
/// 约定：仅手机设备固定竖屏；平板、桌面与 Web 不施加方向限制。
class AppOrientationPolicy {
  /// 手机与非手机的最短边阈值。
  static const double phoneShortestSideBreakpoint = 600;

  /// 判断给定最短逻辑像素边是否属于手机尺寸。
  static bool isPhoneByShortestSide(double shortestSide) {
    return shortestSide < phoneShortestSideBreakpoint;
  }

  /// 判断当前平台是否属于需要参与“手机锁竖屏”策略的移动平台。
  static bool supportsPhoneOrientationPolicy(TargetPlatform platform) {
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  /// 根据平台与最短边，计算首选方向集合。
  ///
  /// 返回空列表表示不施加方向限制，由系统自由旋转。
  static List<DeviceOrientation> preferredOrientations({
    required TargetPlatform platform,
    required double shortestSide,
    required bool isWeb,
  }) {
    if (isWeb || !supportsPhoneOrientationPolicy(platform)) {
      return const <DeviceOrientation>[];
    }
    if (isPhoneByShortestSide(shortestSide)) {
      return const <DeviceOrientation>[DeviceOrientation.portraitUp];
    }
    return const <DeviceOrientation>[];
  }
}

/// 全局方向策略协调器。
///
/// 负责在启动与窗口尺寸变化时重新计算并应用方向策略。
class AppOrientationCoordinator with WidgetsBindingObserver {
  AppOrientationCoordinator({
    WidgetsBinding? binding,
    bool isWeb = kIsWeb,
    TargetPlatform Function()? platformResolver,
    double Function()? shortestSideResolver,
    Future<void> Function(List<DeviceOrientation>)? orientationSetter,
  }) : _binding = binding ?? WidgetsFlutterBinding.ensureInitialized(),
       _isWeb = isWeb,
       _platformResolver = platformResolver ?? (() => defaultTargetPlatform),
       _shortestSideResolver =
           shortestSideResolver ??
           (() {
             final view =
                 WidgetsFlutterBinding.ensureInitialized()
                     .platformDispatcher
                     .views
                     .first;
             final Size logicalSize =
                 view.display.size / view.display.devicePixelRatio;
             return logicalSize.shortestSide;
           }),
       _orientationSetter =
           orientationSetter ?? SystemChrome.setPreferredOrientations;

  final WidgetsBinding _binding;
  final bool _isWeb;
  final TargetPlatform Function() _platformResolver;
  final double Function() _shortestSideResolver;
  final Future<void> Function(List<DeviceOrientation>) _orientationSetter;

  List<DeviceOrientation>? _lastAppliedOrientations;
  bool _started = false;

  /// 启动方向策略监听并立即应用一次。
  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _binding.addObserver(this);
    await applyCurrentMetrics();
  }

  @override
  void didChangeMetrics() {
    applyCurrentMetrics();
  }

  /// 根据当前窗口 metrics 重新计算并应用方向策略。
  Future<void> applyCurrentMetrics() async {
    final double shortestSide = _shortestSideResolver();
    final List<DeviceOrientation> nextOrientations =
        AppOrientationPolicy.preferredOrientations(
          platform: _platformResolver(),
          shortestSide: shortestSide,
          isWeb: _isWeb,
        );

    if (_listEquals(_lastAppliedOrientations, nextOrientations)) {
      return;
    }

    _lastAppliedOrientations = List<DeviceOrientation>.of(nextOrientations);
    _log.i(
      'Apply orientations=$nextOrientations, '
      'shortestSide=$shortestSide, platform=${_platformResolver()}, isWeb=$_isWeb',
    );
    await _orientationSetter(nextOrientations);
  }

  static bool _listEquals(
    List<DeviceOrientation>? a,
    List<DeviceOrientation>? b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null || a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}
