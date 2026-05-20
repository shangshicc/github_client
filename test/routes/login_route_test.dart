import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/index.dart' as models;
import 'package:github_client_app/routes/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
  });

  testWidgets('LoginRoute 快速连续点击只触发一次登录请求', (WidgetTester tester) async {
    final Completer<models.User> completer = Completer<models.User>();
    int loginCallCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: _LoginTestApp(
          child: LoginRoute(
            showLoadingIndicator: false,
            loginAction: (String username, String password) {
              loginCallCount += 1;
              return completer.future;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'tester');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.pump();

    final Finder loginButtonFinder = find.byType(ElevatedButton);

    await tester.tap(loginButtonFinder);
    await tester.pump();

    ElevatedButton loginButton = tester.widget<ElevatedButton>(
      loginButtonFinder,
    );
    expect(loginButton.onPressed, isNull);
    expect(loginCallCount, 1);

    await tester.tap(loginButtonFinder, warnIfMissed: false);
    await tester.pump();
    expect(loginCallCount, 1);

    final models.User user = models.User()..login = 'tester';
    completer.complete(user);
    await tester.pumpAndSettle();

    expect(find.byType(LoginRoute), findsNothing);
    expect(Global.profile.user?.login, 'tester');
  });
}

class _LoginTestApp extends StatelessWidget {
  const _LoginTestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
