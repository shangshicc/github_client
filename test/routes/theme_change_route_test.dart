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
          ..skinId = 'default'
          ..themeMode = 'dark'
          ..locale = 'zh';
  });

  testWidgets('ThemeChangeRoute 仅展示皮肤选择并驱动根部主题刷新', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: _ThemeChangeRouteHarness()),
    );

    expect(find.text('跟随系统'), findsNothing);
    expect(find.text('浅色模式'), findsNothing);
    expect(find.text('深色模式'), findsNothing);

    Container themeMarker = tester.widget<Container>(
      find.byKey(const ValueKey<String>('theme-marker')),
    );
    expect(themeMarker.color, Colors.blue);

    final Finder redThemeItem = find.byKey(
      const ValueKey<String>('skin-sunset'),
    );

    expect(redThemeItem, findsOneWidget);
    await tester.ensureVisible(redThemeItem);
    await tester.pumpAndSettle();
    await tester.tap(redThemeItem, warnIfMissed: false);
    await tester.pump();
    await tester.pump();

    themeMarker = tester.widget<Container>(
      find.byKey(const ValueKey<String>('theme-marker')),
    );
    expect(themeMarker.color, Colors.red);
    expect(Global.profile.theme, Colors.red.toARGB32());
    expect(Global.profile.skinId, 'sunset');
    expect(Global.profile.themeMode, 'dark');
  });
}

class _ThemeChangeRouteHarness extends ConsumerWidget {
  const _ThemeChangeRouteHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSkin skin = ref.watch(skinProvider);
    final MaterialColor themeColor = ref.watch(themeProvider);
    return MaterialApp(
      theme: AppTheme.buildLightThemeDataBySkin(skin),
      darkTheme: AppTheme.buildDarkThemeDataBySkin(skin),
      themeMode: ThemeMode.system,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Stack(
        children: <Widget>[
          const ThemeChangeRoute(),
          Positioned(
            top: 12,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  key: const ValueKey<String>('theme-marker'),
                  color: themeColor,
                  width: 12,
                  height: 12,
                ),
                const Text(
                  'system',
                  key: ValueKey<String>('theme-mode-marker'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
