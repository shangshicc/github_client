import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_orientation_policy.dart';

void main() {
  group('AppOrientationPolicy', () {
    test('shortestSide < 600 判定为手机', () {
      expect(AppOrientationPolicy.isPhoneByShortestSide(599), isTrue);
    });

    test('shortestSide >= 600 判定为非手机', () {
      expect(AppOrientationPolicy.isPhoneByShortestSide(600), isFalse);
      expect(AppOrientationPolicy.isPhoneByShortestSide(800), isFalse);
    });

    test('Android 手机返回 portraitUp', () {
      expect(
        AppOrientationPolicy.preferredOrientations(
          platform: TargetPlatform.android,
          shortestSide: 393,
          isWeb: false,
        ),
        const <DeviceOrientation>[DeviceOrientation.portraitUp],
      );
    });

    test('iPad/Android 平板返回空列表，不施加方向限制', () {
      expect(
        AppOrientationPolicy.preferredOrientations(
          platform: TargetPlatform.iOS,
          shortestSide: 820,
          isWeb: false,
        ),
        isEmpty,
      );
      expect(
        AppOrientationPolicy.preferredOrientations(
          platform: TargetPlatform.android,
          shortestSide: 700,
          isWeb: false,
        ),
        isEmpty,
      );
    });

    test('桌面与 Web 返回空列表，不施加方向限制', () {
      expect(
        AppOrientationPolicy.preferredOrientations(
          platform: TargetPlatform.macOS,
          shortestSide: 500,
          isWeb: false,
        ),
        isEmpty,
      );
      expect(
        AppOrientationPolicy.preferredOrientations(
          platform: TargetPlatform.android,
          shortestSide: 393,
          isWeb: true,
        ),
        isEmpty,
      );
    });
  });

  group('AppOrientationCoordinator', () {
    test('相同策略不会重复 apply，不同策略会重新 apply', () async {
      final List<List<DeviceOrientation>> applied = <List<DeviceOrientation>>[];
      double shortestSide = 393;
      final AppOrientationCoordinator coordinator = AppOrientationCoordinator(
        isWeb: false,
        platformResolver: () => TargetPlatform.android,
        shortestSideResolver: () => shortestSide,
        orientationSetter: (List<DeviceOrientation> orientations) async {
          applied.add(List<DeviceOrientation>.of(orientations));
        },
      );

      await coordinator.applyCurrentMetrics();
      await coordinator.applyCurrentMetrics();
      shortestSide = 800;
      await coordinator.applyCurrentMetrics();

      expect(applied, <List<DeviceOrientation>>[
        const <DeviceOrientation>[DeviceOrientation.portraitUp],
        const <DeviceOrientation>[],
      ]);
    });
  });
}
