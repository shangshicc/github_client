import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_error_presentation_coordinator.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/router/app_router.dart';
import 'package:github_client_app/routes/error_reminder_page.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
    appErrorPresentationCoordinator = AppErrorPresentationCoordinator(
      navigate: (String location, {Object? extra}) {},
      currentLocation: () => AppRoutePaths.errorReminder,
    );
  });

  testWidgets('异常提醒页可见且带有返回首页动作', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: _ErrorReminderRouteApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorReminderPage), findsOneWidget);
    expect(find.text('应用刚刚发生了异常'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('error-reminder-home-button')),
      findsOneWidget,
    );
  });

  testWidgets('点击返回首页后能回到 home 路由', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: _ErrorReminderRouteApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('error-reminder-home-button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorReminderPage), findsNothing);
    expect(find.byType(HomeRoute), findsOneWidget);
  });
}

class _ErrorReminderRouteApp extends ConsumerWidget {
  const _ErrorReminderRouteApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialColor themeColor = ref.watch(themeProvider);
    final Locale? locale = ref.watch(localeProvider);
    return MaterialApp.router(
      theme: ThemeData(primarySwatch: themeColor),
      locale: locale,
      routerConfig: createAppRouter(
        initialLocation: AppRoutePaths.errorReminder,
      ),
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
