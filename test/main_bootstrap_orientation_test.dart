import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_orientation_policy.dart';
import 'package:github_client_app/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    app.createAppOrientationCoordinator = () => AppOrientationCoordinator();
  });

  test('bootstrapApp 启动时会调用方向协调器 start', () async {
    final _RecordingAppOrientationCoordinator coordinator =
        _RecordingAppOrientationCoordinator();
    bool didRunApp = false;

    app.createAppOrientationCoordinator = () => coordinator;

    await app.bootstrapApp(
      routerInitializer: () {},
      presentationCoordinatorInitializer: () {},
      globalInitializer: () async {},
      appRunner: (Widget widget) {
        didRunApp = true;
      },
    );

    expect(coordinator.startCalled, isTrue);
    expect(didRunApp, isTrue);
  });
}

class _RecordingAppOrientationCoordinator extends AppOrientationCoordinator {
  bool startCalled = false;

  @override
  Future<void> start() async {
    startCalled = true;
  }
}
