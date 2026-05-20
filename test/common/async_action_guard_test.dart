import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/async_action_guard.dart';

void main() {
  test('AsyncActionGuard 在禁止重入模式下会忽略执行中的重复调用', () async {
    final AsyncActionGuard guard = AsyncActionGuard(
      mode: AsyncActionGuardMode.reentryLock,
    );
    final Completer<void> completer = Completer<void>();
    int callCount = 0;

    final Future<int?> firstRun = guard.run<int>(() async {
      callCount += 1;
      await completer.future;
      return 1;
    });

    expect(guard.isRunning, isTrue);

    final int? secondResult = await guard.run<int>(() async {
      callCount += 1;
      return 2;
    });

    expect(secondResult, isNull);
    expect(callCount, 1);

    completer.complete();
    expect(await firstRun, 1);
    expect(guard.isRunning, isFalse);
  });

  test('AsyncActionGuard 在防抖模式下会忽略窗口内的重复调用', () async {
    final AsyncActionGuard guard = AsyncActionGuard(
      mode: AsyncActionGuardMode.debounce,
      debounceDuration: const Duration(milliseconds: 50),
    );
    int callCount = 0;

    final int? firstResult = await guard.run<int>(() async {
      callCount += 1;
      return 1;
    });

    final int? secondResult = await guard.run<int>(() async {
      callCount += 1;
      return 2;
    });

    expect(firstResult, 1);
    expect(secondResult, isNull);
    expect(callCount, 1);
  });

  test('AsyncActionGuard 在防抖模式下超过窗口后允许再次调用', () async {
    final AsyncActionGuard guard = AsyncActionGuard(
      mode: AsyncActionGuardMode.debounce,
      debounceDuration: const Duration(milliseconds: 20),
    );
    int callCount = 0;

    await guard.run<void>(() async {
      callCount += 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await guard.run<void>(() async {
      callCount += 1;
    });

    expect(callCount, 2);
  });

  test('AsyncActionGuard 异常后会恢复为空闲状态', () async {
    final AsyncActionGuard guard = AsyncActionGuard(
      mode: AsyncActionGuardMode.reentryLock,
    );

    await expectLater(
      guard.run<void>(() async {
        throw StateError('boom');
      }),
      throwsA(isA<StateError>()),
    );

    expect(guard.isRunning, isFalse);
  });

  test('AsyncActionGuard 异常恢复后仍可再次执行', () async {
    final AsyncActionGuard guard = AsyncActionGuard(
      mode: AsyncActionGuardMode.reentryLock,
    );
    int callCount = 0;

    await expectLater(
      guard.run<void>(() async {
        callCount += 1;
        throw StateError('boom');
      }),
      throwsA(isA<StateError>()),
    );

    final int? secondResult = await guard.run<int>(() async {
      callCount += 1;
      return 2;
    });

    expect(secondResult, 2);
    expect(callCount, 2);
    expect(guard.isRunning, isFalse);
  });
}
