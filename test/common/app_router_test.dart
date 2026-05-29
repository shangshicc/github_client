import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/router/app_router.dart';

void main() {
  tearDown(resetAppRouter);

  test('appRouter 首次读取时惰性创建默认首页路由', () {
    final router = appRouter;

    expect(router.routeInformationProvider.value.uri.path, AppRoutePaths.home);
    expect(identical(appRouter, router), isTrue);
  });

  test('initializeAppRouter 只在首次调用时创建路由实例', () {
    initializeAppRouter(initialLocation: AppRoutePaths.errorDebug);
    final firstRouter = appRouter;

    initializeAppRouter(initialLocation: AppRoutePaths.login);
    final secondRouter = appRouter;

    expect(identical(firstRouter, secondRouter), isTrue);
    expect(
      firstRouter.routeInformationProvider.value.uri.path,
      AppRoutePaths.errorDebug,
    );
  });
}
