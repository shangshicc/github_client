import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/router/app_router.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'common/app_error_reporter.dart';
import 'common/app_orientation_policy.dart';
import 'common/app_error_presentation_coordinator.dart';
import 'common/app_theme.dart';
import 'common/global.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'common/logger.dart';
import 'widgets/error_widget_fallback.dart';

final _log = createLogger('AppRoot');

typedef AppOrientationCoordinatorFactory = AppOrientationCoordinator Function();

AppOrientationCoordinatorFactory createAppOrientationCoordinator =
    () => AppOrientationCoordinator();

Future<void> main() async {
  // build/render 失败时，仅替换当前出错模块，避免升级为全局宕机态。
  ErrorWidget.builder = (FlutterErrorDetails _) {
    return const ErrorWidgetFallback();
  };

  await bootstrapApp();
}

@visibleForTesting
Future<void> bootstrapApp({
  AppErrorReporter? reporter,
  Future<void> Function()? globalInitializer,
  void Function()? routerInitializer,
  void Function()? presentationCoordinatorInitializer,
  void Function(Widget app)? appRunner,
}) async {
  final AppErrorReporter effectiveReporter =
      reporter ??
      AppErrorReporter(
        errorPresentationHandler: (AppErrorRecord record) async {
          appErrorPresentationCoordinator?.present(record);
        },
      );
  // 注意：不要在这个 guarded zone 外提前读取 appRouter / coordinator，
  // 否则会把路由相关初始化放到错误的 zone 中，重新触发 debugCheckZone。
  // 这里要保证 binding 初始化、路由初始化、启动初始化和 runApp 处于同一个 guarded zone 中。
  await effectiveReporter.guardBootstrap(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final AppOrientationCoordinator orientationCoordinator =
        createAppOrientationCoordinator();
    effectiveReporter.install();
    await orientationCoordinator.start();
    (routerInitializer ?? initializeAppRouter)();
    (presentationCoordinatorInitializer ??
        _initializeAppErrorPresentationCoordinator)();
    await (globalInitializer ?? Global.init)();
    (appRunner ?? runApp)(const ProviderScope(child: MyApp()));
  });
}

void _initializeAppErrorPresentationCoordinator() {
  appErrorPresentationCoordinator = AppErrorPresentationCoordinator(
    navigate: appRouter.go,
    currentLocation:
        // 当前路由栈里，正在显示的页面路径字符串
        () => appRouter.routerDelegate.currentConfiguration.uri.path,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const _AppRoot();
  }
}

/// 应用根部，负责监听全局主题和语言状态。
class _AppRoot extends ConsumerWidget {
  /// 构建应用根部 UI。
  ///
  /// 该组件监听 Riverpod 中的主题和语言状态，并把它们注入 MaterialApp。
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSkin skin = ref.watch(skinProvider);
    final Locale? locale = ref.watch(localeProvider);
    _log.i(
      '_AppRoot build, skin=${skin.id}, theme=${skin.swatch.toARGB32()}, '
      'themeMode=${ThemeMode.system}, locale=${locale?.toString() ?? "system"}',
    );
    return MaterialApp.router(
      theme: AppTheme.buildLightThemeDataBySkin(skin),
      darkTheme: AppTheme.buildDarkThemeDataBySkin(skin),
      themeMode: ThemeMode.system,
      onGenerateTitle: (context) {
        return AppLocalizations.of(context).title;
      },
      locale: locale,
      routerConfig: appRouter,
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
        // 冷启动app时适配选择的app内语言
        final preferred = locale;
        // 手动选择语言时，preferred不为null
        if (preferred != null) return preferred;

        if (deviceLocale == null) {
          // 用户没有选择语言，和系统语言保持一致
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
    );
  }
}
