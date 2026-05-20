import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/async_action_guard.dart';
import 'package:github_client_app/widgets/async_elevated_button.dart';

void main() {
  testWidgets('AsyncElevatedButton 点击后展示 loading 并在完成后恢复', (
    WidgetTester tester,
  ) async {
    final Completer<void> completer = Completer<void>();
    int callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncElevatedButton(
            onPressed: () async {
              callCount += 1;
              await completer.future;
            },
            loadingChild: const Text('提交中'),
            child: const Text('提交'),
          ),
        ),
      ),
    );

    final Finder buttonFinder = find.byType(ElevatedButton);

    await tester.tap(buttonFinder);
    await tester.pump();

    final ElevatedButton loadingButton = tester.widget<ElevatedButton>(
      buttonFinder,
    );
    expect(callCount, 1);
    expect(loadingButton.onPressed, isNull);
    expect(find.text('提交中'), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    final ElevatedButton idleButton = tester.widget<ElevatedButton>(
      buttonFinder,
    );
    expect(idleButton.onPressed, isNotNull);
    expect(find.text('提交'), findsOneWidget);
  });

  testWidgets('AsyncElevatedButton 在执行中不会重复触发回调', (WidgetTester tester) async {
    final Completer<void> completer = Completer<void>();
    int callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncElevatedButton(
            onPressed: () async {
              callCount += 1;
              await completer.future;
            },
            child: const Text('提交'),
          ),
        ),
      ),
    );

    final Finder buttonFinder = find.byType(ElevatedButton);

    await tester.tap(buttonFinder);
    await tester.pump();
    await tester.tap(buttonFinder, warnIfMissed: false);
    await tester.pump();

    expect(callCount, 1);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('AsyncElevatedButton 在防抖模式下不托管 loading 与禁用态', (
    WidgetTester tester,
  ) async {
    final Completer<void> completer = Completer<void>();
    int callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncElevatedButton(
            guardMode: AsyncActionGuardMode.debounce,
            debounceDuration: const Duration(milliseconds: 100),
            onPressed: () async {
              callCount += 1;
              await completer.future;
            },
            loadingChild: const Text('提交中'),
            child: const Text('提交'),
          ),
        ),
      ),
    );

    final Finder buttonFinder = find.byType(ElevatedButton);

    await tester.tap(buttonFinder);
    await tester.pump();

    final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
    expect(callCount, 1);
    expect(button.onPressed, isNotNull);
    expect(find.text('提交中'), findsNothing);
    expect(find.text('提交'), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
  });
}
