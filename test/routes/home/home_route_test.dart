import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/global.dart';
import 'package:github_client_app/common/home_back_guard.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/index.dart' as models;
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/router/app_router.dart';
import 'package:github_client_app/routes/demo.dart';
import 'package:github_client_app/routes/home/data/home_repository.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/states/profile_selectors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Global.init();
  });

  testWidgets(
    'Home unauthenticated shows default account repos and drawer can go login',
    (WidgetTester tester) async {
      final List<String> requestedUsernames = <String>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isLoginProvider.overrideWithValue(false),
            homeRepositoryProvider.overrideWithValue(
              _RecordingHomeRepository(
                requestedUsernames: requestedUsernames,
                repos: <models.Repo>[_buildRepo(id: 1, name: 'repo-1')],
              ),
            ),
          ],
          child: const _RouteApp(initialLocation: AppRoutePaths.home),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(requestedUsernames, contains(HomeRoute.defaultUsername));
      expect(find.text('repo-1'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('home-guest-hint-text')),
        findsOneWidget,
      );
      expect(find.text('Demo account: octocat'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('home-guest-login-button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginRoute), findsOneWidget);
    },
  );

  testWidgets(
    'Drawer unauthenticated -> themes redirects login, language/demo still resolve',
    (WidgetTester tester) async {
      Global.profile = models.Profile()..theme = Colors.blue.toARGB32();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeRepositoryProvider.overrideWithValue(
              _FakeHomeRepository(
                repos: <models.Repo>[_buildRepo(id: 99, name: 'home-repo')],
              ),
            ),
          ],
          child: const _RouteApp(initialLocation: AppRoutePaths.home),
        ),
      );

      await _openDrawer(tester);
      await tester.tap(find.widgetWithIcon(ListTile, Icons.color_lens));
      await tester.pumpAndSettle();
      expect(find.byType(LoginRoute), findsOneWidget);

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
    },
  );

  testWidgets(
    'HomeRoute first back shows hint and second back exits within window',
    (WidgetTester tester) async {
      final List<String> toastMessages = <String>[];
      int exitCount = 0;
      DateTime now = DateTime(2026, 5, 23, 12);
      const MethodChannel toastChannel = MethodChannel(
        'PonnamKarthik/fluttertoast',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(toastChannel, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'showToast') {
              toastMessages.add(methodCall.arguments['msg'] as String);
            }
            return true;
          });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'SystemNavigator.pop') {
            exitCount += 1;
          }
          return null;
        },
      );
      addTearDown(() async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(toastChannel, null);
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeRepositoryProvider.overrideWithValue(
              _FakeHomeRepository(
                repos: <models.Repo>[_buildRepo(id: 99, name: 'home-repo')],
              ),
            ),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: HomeRoute(backGuard: HomeBackGuard(now: () => now)),
          ),
        ),
      );

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(toastMessages, <String>['Press again to exit the app.']);
      await tester.pump(const Duration(seconds: 1));
      expect(exitCount, 0);

      now = now.add(const Duration(seconds: 1));
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(exitCount, 1);
    },
  );

  testWidgets('HomeRoute back hint expires after 2 seconds', (
    WidgetTester tester,
  ) async {
    final List<String> toastMessages = <String>[];
    int exitCount = 0;
    DateTime now = DateTime(2026, 5, 23, 12);
    const MethodChannel toastChannel = MethodChannel(
      'PonnamKarthik/fluttertoast',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'showToast') {
            toastMessages.add(methodCall.arguments['msg'] as String);
          }
          return true;
        });
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'SystemNavigator.pop') {
          exitCount += 1;
        }
        return null;
      },
    );
    addTearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(toastChannel, null);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            _FakeHomeRepository(
              repos: <models.Repo>[_buildRepo(id: 99, name: 'home-repo')],
            ),
          ),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: HomeRoute(backGuard: HomeBackGuard(now: () => now)),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    now = now.add(const Duration(seconds: 3));
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(toastMessages, <String>[
      'Press again to exit the app.',
      'Press again to exit the app.',
    ]);
    expect(exitCount, 0);
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
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository({required List<models.Repo> repos}) : _repos = repos;

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

class _RecordingHomeRepository extends HomeRepository {
  _RecordingHomeRepository({
    required this.requestedUsernames,
    required List<models.Repo> repos,
  }) : _repos = repos;

  final List<String> requestedUsernames;
  final List<models.Repo> _repos;

  @override
  Future<List<models.Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    requestedUsernames.add(username);
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
