import 'package:go_router/go_router.dart';
import 'package:github_client_app/routes/demo.dart';
import 'package:github_client_app/routes/demo/list/demo_list_route.dart';
import 'package:github_client_app/routes/demo/nested_scroll/demo_nested_scroll_route.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/routes/detail_page.dart';
import 'package:github_client_app/routes/selector_page.dart';

import 'app_route_paths.dart';

/// 创建应用级路由配置。
///
/// 该配置统一收口当前项目首页与既有命名路由，作为 go_router 迁移的
/// 第一阶段基础设施。当前仅做行为等价迁移，不在这里引入鉴权 redirect、
/// ShellRoute 或类型安全路由生成。
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
    ],
  );
}

final GoRouter appRouter = createAppRouter();
