import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/routes/demo/state_management_demo_route.dart';

String _textValue(WidgetTester tester, Key key) {
  final Text textWidget = tester.widget<Text>(find.byKey(key));
  return textWidget.data ?? '';
}

void main() {
  testWidgets('StateManagementDemoRoute 展示两个独立 demo 区块', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: StateManagementDemoRoute()),
    );

    expect(find.text('Demo 1：父组件管理子组件状态'), findsOneWidget);
    expect(find.text('Demo 2：子组件管理内部状态，父组件管理外部状态'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('parent-state-add-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('child-highlight-switch')),
      findsOneWidget,
    );
  });

  testWidgets('Demo 1 由父组件统一维护并重置子组件展示状态', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StateManagementDemoRoute()),
    );

    expect(
      find.byKey(const ValueKey<String>('parent-state-value')),
      findsOneWidget,
    );
    expect(
      _textValue(tester, const ValueKey<String>('parent-state-value')),
      '0',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('parent-state-add-button')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('parent-state-add-button')),
    );
    await tester.pump();

    expect(
      _textValue(tester, const ValueKey<String>('parent-state-value')),
      '2',
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('parent-state-reset-button')),
    );
    await tester.pump();

    expect(
      _textValue(tester, const ValueKey<String>('parent-state-value')),
      '0',
    );
  });

  testWidgets('Demo 2 区分子组件内部高亮与父组件业务状态', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StateManagementDemoRoute()),
    );

    expect(find.text('子组件内部高亮：关闭'), findsOneWidget);
    expect(find.text('父组件业务结果：未订阅'), findsOneWidget);
    expect(find.text('未订阅'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey<String>('child-highlight-switch')),
    );
    await tester.pumpAndSettle();

    expect(find.text('子组件内部高亮：开启'), findsOneWidget);
    expect(find.text('父组件业务结果：未订阅'), findsOneWidget);

    final Finder toggleButton = find.byKey(
      const ValueKey<String>('parent-business-toggle-button'),
    );
    await tester.scrollUntilVisible(toggleButton, 200);
    await tester.pumpAndSettle();
    await tester.tap(toggleButton);
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('parent-business-label')),
      findsOneWidget,
    );
    expect(find.text('父组件业务结果：已订阅'), findsOneWidget);
    expect(find.text('子组件内部高亮：开启'), findsOneWidget);
  });
}
