import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/main.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/router/app_router.dart';
import 'package:github_client_app/routes/demo.dart';
import 'package:github_client_app/routes/demo/list/demo_list_route.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_controller.dart';
import 'package:github_client_app/routes/demo/nested_scroll/demo_nested_scroll_route.dart';
import 'package:github_client_app/routes/detail_page.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/models/index.dart' as models;
import 'package:github_client_app/states/profile_state.dart';
import 'package:github_client_app/states/profile_selectors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
  });

  testWidgets('App root uses MaterialApp.router and opens HomeRoute at /', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.routerConfig, isNotNull);
    expect(find.byType(HomeRoute), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Home unauthenticated -> login via go_router', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isLoginProvider.overrideWithValue(false)],
        child: const _RouteApp(initialLocation: AppRoutePaths.home),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginRoute), findsOneWidget);
  });

  testWidgets('Direct route /selector resolves to SelectorPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouteApp(initialLocation: AppRoutePaths.selector),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('selector Page'), findsOneWidget);
  });

  testWidgets('Direct route /detail resolves to DetailPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouteApp(initialLocation: AppRoutePaths.detail),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsOneWidget);
  });

  testWidgets('Drawer -> themes/language/demo routes all resolve', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _RouteApp(initialLocation: AppRoutePaths.home),
      ),
    );

    await _openDrawer(tester);
    await tester.tap(find.widgetWithIcon(ListTile, Icons.color_lens));
    await tester.pumpAndSettle();
    expect(find.byType(ThemeChangeRoute), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _openDrawer(tester);
    await tester.tap(find.widgetWithIcon(ListTile, Icons.language));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageRoute), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _openDrawer(tester);
    await tester.tap(find.widgetWithIcon(ListTile, Icons.info));
    await tester.pumpAndSettle();
    expect(find.byType(DemoRoute), findsOneWidget);
  });

  testWidgets('Demo -> demo list / nested scroll and back stack', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoListRepositoryProvider.overrideWithValue(
            _FakeDemoListRepository(
              repos: <models.Repo>[_buildRepo(id: 1, name: 'repo-1')],
            ),
          ),
        ],
        child: const _RouteApp(initialLocation: AppRoutePaths.demo),
      ),
    );

    await tester.tap(find.byType(ElevatedButton).at(1));
    await tester.pumpAndSettle();
    expect(find.byType(DemoListRoute), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DemoRoute), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton).at(2));
    await tester.pumpAndSettle();
    expect(find.byType(DemoNestedScrollRoute), findsOneWidget);
  });
  testWidgets('Theme rebuild still works with routerConfig', (
    WidgetTester tester,
  ) async {
    Global.profile = models.Profile()..theme = Colors.blue.toARGB32();

    await tester.pumpWidget(
      const ProviderScope(
        child: _RouteApp(initialLocation: AppRoutePaths.themes),
      ),
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

    await tester.tap(redThemeItem);
    await tester.pump();
    await tester.pump();

    themeMarker = tester.widget<Container>(
      find.byKey(const ValueKey<String>('theme-marker')),
    );
    expect(themeMarker.color, Colors.red);
    expect(Global.profile.theme, Colors.red.toARGB32());
  });

  testWidgets('Locale rebuild still works with routerConfig', (
    WidgetTester tester,
  ) async {
    Global.profile = models.Profile()..locale = 'zh';

    await tester.pumpWidget(
      const ProviderScope(
        child: _RouteApp(initialLocation: AppRoutePaths.language),
      ),
    );

    Text localeMarker = tester.widget<Text>(
      find.byKey(const ValueKey<String>('locale-marker')),
    );
    expect(localeMarker.data, 'zh');

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump();

    localeMarker = tester.widget<Text>(
      find.byKey(const ValueKey<String>('locale-marker')),
    );
    expect(localeMarker.data, 'en');
    expect(Global.profile.locale, 'en');
  });
}

class _RouteApp extends ConsumerWidget {
  const _RouteApp({required this.initialLocation});

  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialColor themeColor = ref.watch(themeProvider);
    final Locale? locale = ref.watch(localeProvider);
    return MaterialApp.router(
      theme: ThemeData(primarySwatch: themeColor),
      locale: locale,
      routerConfig: createAppRouter(initialLocation: initialLocation),
      builder: (BuildContext context, Widget? child) {
        return Column(
          children: <Widget>[
            Container(
              key: const ValueKey<String>('theme-marker'),
              color: themeColor,
              width: 12,
              height: 12,
            ),
            Text(
              locale?.languageCode ?? 'system',
              key: const ValueKey<String>('locale-marker'),
            ),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

Future<void> _openDrawer(WidgetTester tester) async {
  final ScaffoldState scaffoldState = tester.state<ScaffoldState>(
    find.byType(Scaffold).first,
  );
  scaffoldState.openDrawer();
  await tester.pumpAndSettle();
}

class _FakeDemoListRepository extends DemoListRepository {
  _FakeDemoListRepository({required List<models.Repo> repos}) : _repos = repos;

  final List<models.Repo> _repos;

  @override
  Future<List<models.Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    return _repos;
  }
}

models.Repo _buildRepo({required int id, required String name}) {
  final models.Repo repo = models.Repo();
  repo.id = id;
  repo.name = name;
  repo.full_name = 'tester/$name';
  repo.owner = models.User();
  repo.owner.login = 'tester';
  repo.owner.avatar_url = 'https://example.com/avatar.png';
  repo.private = false;
  repo.html_url = 'https://example.com/$name';
  repo.description = 'desc-$name';
  repo.fork = false;
  repo.language = 'Dart';
  repo.forks_count = 0;
  repo.stargazers_count = 0;
  repo.watchers_count = 0;
  repo.size = 0;
  repo.default_branch = 'main';
  repo.open_issues_count = 0;
  repo.topics = <String>[];
  repo.has_issues = true;
  repo.has_projects = true;
  repo.has_wiki = true;
  repo.has_pages = false;
  repo.has_downloads = true;
  repo.pushed_at = '2026-05-15T00:00:00Z';
  repo.created_at = '2026-05-15T00:00:00Z';
  repo.updated_at = '2026-05-15T00:00:00Z';
  repo.permissions = <String, dynamic>{};
  repo.subscribers_count = 0;
  return repo;
}
