import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_error_presentation_coordinator.dart';
import 'package:github_client_app/common/app_error_reporter.dart';

void main() {
  test('协调器首次触发时会请求展示异常提醒页', () {
    final List<String> navigatedLocations = <String>[];
    final AppErrorPresentationCoordinator coordinator =
        AppErrorPresentationCoordinator(
          navigate: (String location, {Object? extra}) {
            navigatedLocations.add(location);
          },
          currentLocation: () => '/home',
          reminderPath: '/error/reminder',
        );

    final AppErrorPresentationDecision decision = coordinator.present(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 13, 0),
        source: 'zone',
        error: StateError('boom'),
        stackTrace: StackTrace.fromString('stack'),
        summary: 'boom',
      ),
    );

    expect(decision, AppErrorPresentationDecision.requestShowReminderPage);
    expect(navigatedLocations, <String>['/error/reminder']);
    expect(coordinator.isReminderVisible, isTrue);
  });

  test('协调器已在异常页时不会重复导航', () {
    int navigationCount = 0;
    final AppErrorPresentationCoordinator coordinator =
        AppErrorPresentationCoordinator(
          navigate: (String location, {Object? extra}) {
            navigationCount++;
          },
          currentLocation: () => '/home',
          reminderPath: '/error/reminder',
        );

    coordinator.present(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 13, 0),
        source: 'zone',
        error: StateError('boom'),
        stackTrace: StackTrace.fromString('stack'),
        summary: 'boom',
      ),
    );
    final AppErrorPresentationDecision secondDecision = coordinator.present(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 13, 1),
        source: 'flutter',
        error: StateError('boom-again'),
        stackTrace: StackTrace.fromString('stack-2'),
        summary: 'boom-again',
      ),
    );

    expect(secondDecision, AppErrorPresentationDecision.ignore);
    expect(navigationCount, 1);
  });

  test('协调器导航失败时会安全忽略，不再降级到全局兜底 UI', () {
    final AppErrorPresentationCoordinator coordinator =
        AppErrorPresentationCoordinator(
          navigate: (String location, {Object? extra}) {
            throw StateError('router unavailable');
          },
          currentLocation: () => '/home',
          reminderPath: '/error/reminder',
        );

    final AppErrorPresentationDecision decision = coordinator.present(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 13, 2),
        source: 'platform',
        error: StateError('boom'),
        stackTrace: StackTrace.fromString('stack-3'),
        summary: 'boom',
      ),
    );

    expect(decision, AppErrorPresentationDecision.ignore);
    expect(coordinator.isReminderVisible, isFalse);
  });

  test('仅允许局部兜底的 FlutterError 不会触发全局导航', () {
    int navigationCount = 0;
    final AppErrorPresentationCoordinator coordinator =
        AppErrorPresentationCoordinator(
          navigate: (String location, {Object? extra}) {
            navigationCount++;
          },
          currentLocation: () => '/home',
          reminderPath: '/error/reminder',
        );

    final AppErrorPresentationDecision decision = coordinator.present(
      AppErrorRecord(
        timestamp: DateTime(2026, 5, 23, 13, 3),
        source: 'flutter',
        error: StateError('build failed'),
        stackTrace: StackTrace.fromString('stack-4'),
        summary: 'build failed',
        presentationPreference: AppErrorPresentationPreference.fallbackUiOnly,
      ),
    );

    expect(decision, AppErrorPresentationDecision.ignore);
    expect(navigationCount, 0);
  });
}
