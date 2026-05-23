import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_theme.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/profile.dart' as models;
import 'package:github_client_app/routes/theme_change.dart';
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

  testWidgets('ThemeChangeRoute 点击主题后会驱动根部主题刷新', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: _ThemeChangeRouteHarness()),
    );

    Container themeMarker = tester.widget<Container>(
      find.byKey(const ValueKey<String>('theme-marker')),
    );
    expect(themeMarker.color, Colors.blue);

    final Finder redThemeItem = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byWidgetPredicate(
        (Widget widget) => widget is Container && widget.color == Colors.red,
      ),
    );

    expect(redThemeItem, findsOneWidget);
    await tester.tap(redThemeItem);
    await tester.pump();
    await tester.pump();

    themeMarker = tester.widget<Container>(
      find.byKey(const ValueKey<String>('theme-marker')),
    );
    expect(themeMarker.color, Colors.red);
    expect(Global.profile.theme, Colors.red.toARGB32());
  });
}

class _ThemeChangeRouteHarness extends ConsumerWidget {
  const _ThemeChangeRouteHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialColor themeColor = ref.watch(themeProvider);
    return MaterialApp(
      theme: AppTheme.buildThemeData(themeColor.toARGB32()),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              key: const ValueKey<String>('theme-marker'),
              color: themeColor,
              width: 12,
              height: 12,
            ),
            const Expanded(child: ThemeChangeRoute()),
          ],
        ),
      ),
    );
  }
}
