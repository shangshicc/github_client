import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/profile.dart' as models;
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
    Global.profile =
        models.Profile()
          ..theme = Colors.blue.toARGB32()
          ..locale = 'zh';
  });

  testWidgets('LanguageRoute 点击 English 后会驱动根部 locale 刷新', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _LanguageRouteHarness()),
    );

    MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('zh'));
    expect(find.byIcon(Icons.done), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('en'));
    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('LanguageRoute 点击跟随系统后会清空根部 locale 并切换选中项', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _LanguageRouteHarness()),
    );

    MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('zh'));
    expect(find.byIcon(Icons.done), findsOneWidget);

    await tester.tap(find.byType(ListTile).at(2));
    await tester.pump();
    await tester.pump();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, isNull);
    expect(find.byIcon(Icons.done), findsOneWidget);
    expect(Global.profile.locale, isNull);
  });
}

class _LanguageRouteHarness extends ConsumerWidget {
  const _LanguageRouteHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? locale = ref.watch(localeProvider);
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const LanguageRoute(),
    );
  }
}
