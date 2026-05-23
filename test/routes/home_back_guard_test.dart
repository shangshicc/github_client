import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/home_back_guard.dart';

void main() {
  test('首次返回时应提示用户再次点击退出', () {
    DateTime now = DateTime(2026, 5, 23, 12);
    final HomeBackGuard guard = HomeBackGuard(now: () => now);

    expect(guard.registerBackAttempt(), HomeBackDecision.showHint);
  });

  test('两秒内第二次返回时应允许退出', () {
    DateTime now = DateTime(2026, 5, 23, 12);
    final HomeBackGuard guard = HomeBackGuard(now: () => now);

    expect(guard.registerBackAttempt(), HomeBackDecision.showHint);

    now = now.add(const Duration(seconds: 1));
    expect(guard.registerBackAttempt(), HomeBackDecision.exitApp);
  });

  test('超过两秒后再次返回应重新按首次逻辑处理', () {
    DateTime now = DateTime(2026, 5, 23, 12);
    final HomeBackGuard guard = HomeBackGuard(now: () => now);

    expect(guard.registerBackAttempt(), HomeBackDecision.showHint);

    now = now.add(const Duration(seconds: 3));
    expect(guard.registerBackAttempt(), HomeBackDecision.showHint);
  });
}
