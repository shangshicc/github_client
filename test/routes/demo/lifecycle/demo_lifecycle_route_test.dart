import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/router/app_router.dart';
import 'package:github_client_app/routes/demo/lifecycle/demo_lifecycle_route.dart';

void main() {
  testWidgets('Demo 生命周期页可从 Demo 首页入口进入', (WidgetTester tester) async {
    await tester.pumpWidget(
      const _TestRouterApp(initialLocation: AppRoutePaths.demo),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('demo-lifecycle-entry')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('demo-lifecycle-entry')),
    );
    await tester.pumpAndSettle();

    expect(find.text('生命周期 Demo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('demo-lifecycle-description')),
      findsOneWidget,
    );
  });

  testWidgets('Demo 生命周期页点击按钮后会更新计数', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DemoLifecycleRoute()));

    expect(
      find.byKey(const ValueKey<String>('demo-lifecycle-counter')),
      findsOneWidget,
    );
    expect(find.text('计数：0'), findsOneWidget);
    expect(find.text('最近应用生命周期：none'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('demo-lifecycle-increment-button')),
    );
    await tester.pump();

    expect(find.text('计数：1'), findsOneWidget);
  });

  testWidgets('Demo 生命周期页在父组件更新配置后展示新标题', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DemoLifecycleRoute(pageTitle: '旧标题')),
    );

    expect(find.text('旧标题'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: DemoLifecycleRoute(pageTitle: '新标题')),
    );
    await tester.pump();

    expect(find.text('新标题'), findsOneWidget);
    expect(find.text('旧标题'), findsNothing);
  });
}

class _TestRouterApp extends StatelessWidget {
  const _TestRouterApp({required this.initialLocation});

  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: createAppRouter(initialLocation: initialLocation),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
