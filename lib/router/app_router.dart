import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/routes/demo.dart';
import 'package:github_client_app/routes/demo/list/demo_list_route.dart';
import 'package:github_client_app/routes/demo/nested_scroll/demo_nested_scroll_route.dart';
import 'package:github_client_app/routes/demo/state_management_demo_route.dart';
import 'package:github_client_app/routes/error_debug_route.dart';
import 'package:github_client_app/routes/error_reminder_page.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/routes/detail_page.dart';
import 'package:github_client_app/routes/selector_page.dart';

import 'app_route_paths.dart';

/// 在进入 themes 页面前校验登录态。
///
/// 当 [Global.profile.user] 为空时，返回登录页路径；否则允许继续进入
/// 主题切换页。
String? _redirectThemesIfUnauthenticated(
  BuildContext context,
  GoRouterState state,
) {
  final bool hasUser = Global.profile.user != null;
  return hasUser ? null : AppRoutePaths.login;
}

/// 创建应用级路由配置。
///
/// 该配置统一收口当前项目首页与既有命名路由，作为 go_router 迁移的
/// 第一阶段基础设施。当前仅为需要登录的 themes 页面补充最小鉴权
/// redirect，不在这里引入全局 ShellRoute 或类型安全路由生成。
GoRouter createAppRouter({String initialLocation = AppRoutePaths.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutePaths.home,
        builder: (context, state) => const HomeRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, state) => const LoginRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.themes,
        redirect: _redirectThemesIfUnauthenticated,
        builder: (context, state) => const ThemeChangeRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.language,
        builder: (context, state) => const LanguageRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.demo,
        builder: (context, state) => const DemoRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.selector,
        builder: (context, state) => const SelectorPage(),
      ),
      GoRoute(
        path: AppRoutePaths.detail,
        builder: (context, state) => const DetailPage(),
      ),
      GoRoute(
        path: AppRoutePaths.demoList,
        builder: (context, state) => const DemoListRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.demoNestedScroll,
        builder: (context, state) => const DemoNestedScrollRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.demoStateManagement,
        builder: (context, state) => const StateManagementDemoRoute(),
      ),
      GoRoute(
        path: AppRoutePaths.errorReminder,
        builder: (context, state) => const ErrorReminderPage(),
      ),
      GoRoute(
        path: AppRoutePaths.errorDebug,
        builder: (context, state) => const ErrorDebugRoute(),
      ),
    ],
  );
}

GoRouter? _appRouter;

/// 读取应用级路由配置。
///
/// 首次读取时按默认首页惰性创建，避免在 `main()` 进入目标 zone 前
/// 提前触发路由初始化。
GoRouter get appRouter => _appRouter ??= createAppRouter();

/// 在应用启动时显式初始化路由配置。
///
/// [initialLocation] 表示应用首次进入时的路由路径，默认首页。
void initializeAppRouter({String initialLocation = AppRoutePaths.home}) {
  _appRouter ??= createAppRouter(initialLocation: initialLocation);
}

/// 重置应用级路由配置，仅用于测试隔离。
@visibleForTesting
void resetAppRouter() {
  _appRouter = null;
}
