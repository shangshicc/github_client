import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/states/counter_provider.dart';
import 'package:github_client_app/states/profile_change_notifier.dart';
import 'common/global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes/demo.dart';

void main() async {
  Global.init().then((e) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
      ],
      child: Consumer2<ThemeModel, LocaleModel>(
        builder: (BuildContext context, themeModel, localeModel, child) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: getaterialColor(themeModel.theme),
            ),
            onGenerateTitle: (context) {
              return AppLocalizations.of(context).title;
            },
            home: const HomeRoute(),
            locale: localeModel.getLocale(),
            // 获取当前支持的语言
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              // 当前项目的本地化语言类
              AppLocalizations.delegate,
              // Material/Cupertino的本地化语言类
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              //组件文件排列的本地化适配类（ltr/rtl）
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              final preferred = localeModel.getLocale();
              if (preferred != null) return preferred;

              if (deviceLocale == null) {
                return supportedLocales.firstWhere(
                  (l) => l.languageCode == 'en',
                  orElse: () => supportedLocales.first,
                );
              }

              // 先尝试精确匹配语言 + 国家/地区
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode &&
                    supportedLocale.countryCode == deviceLocale.countryCode) {
                  return supportedLocale;
                }
              }

              // 再退化为仅匹配语言
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }

              // 如果系统语言不受支持，则默认使用英语
              return supportedLocales.firstWhere(
                (l) => l.languageCode == 'en',
                orElse: () => supportedLocales.first,
              );
            },
            // 注册路由
            routes: <String, WidgetBuilder>{
              "login": (context) => const LoginRoute(),
              "themes": (context) => const ThemeChangeRoute(),
              "language": (context) => const LanguageRoute(),
              "demo": (context) => const DemoRoute()
            },
          );
        },
      ),
    );
  }

  MaterialColor getaterialColor(ColorSwatch themeModel) {
    return MaterialColor(themeModel.toARGB32(), <int, Color>{
      50: themeModel[50]!,
      100: themeModel[100]!,
      200: themeModel[200]!,
      300: themeModel[300]!,
      400: themeModel[400]!,
      500: themeModel[500]!,
      600: themeModel[600]!,
      700: themeModel[700]!,
      800: themeModel[800]!,
      900: themeModel[900]!,
    });
  }
}
