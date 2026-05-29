import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/main.dart';
import 'package:github_client_app/models/profile.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
    Global.profile =
        models.Profile()
          ..theme = Colors.red.toARGB32()
          ..skinId = 'sunset'
          ..themeMode = 'dark';
  });

  testWidgets('MyApp 将亮暗主题注入 MaterialApp.router 并固定跟随系统', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    final MaterialApp materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
    expect(materialApp.themeMode, ThemeMode.system);
    expect(materialApp.theme?.brightness, Brightness.light);
    expect(materialApp.darkTheme?.brightness, Brightness.dark);
  });
}
