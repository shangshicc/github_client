import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/app_theme.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/repo.dart';
import 'package:github_client_app/models/user.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/demo_list_route.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_controller.dart';
import 'package:github_client_app/states/profile_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DemoListRoute 首帧会自动触发首次加载并展示错误态', (WidgetTester tester) async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <_FakeResponseFactory>[
        () => Future<List<Repo>>.error(Exception('network down')),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoListRepositoryProvider.overrideWithValue(repository),
          themeProvider.overrideWithValue(Colors.blue),
        ],
        child: const _TestApp(child: DemoListRoute()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump();

    expect(repository.requests, hasLength(1));
    expect(find.text('Exception: network down'), findsOneWidget);

    await _disposeRoute(tester);
  });

  testWidgets('DemoListRoute 深色主题下使用语义颜色而非写死浅色背景', (WidgetTester tester) async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <_FakeResponseFactory>[
        () =>
            Future<List<Repo>>.value(<Repo>[_buildRepo(id: 3, name: 'repo-3')]),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoListRepositoryProvider.overrideWithValue(repository),
          themeProvider.overrideWithValue(Colors.blue),
        ],
        child: const _TestApp(
          themeMode: ThemeMode.dark,
          child: DemoListRoute(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    final ThemeData theme = Theme.of(
      tester.element(find.byType(DemoListRoute)),
    );
    final Container titleContainer = tester.widget<Container>(
      find
          .byWidgetPredicate(
            (Widget widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).borderRadius ==
                    const BorderRadius.vertical(top: Radius.circular(12)),
          )
          .first,
    );
    final BoxDecoration titleDecoration =
        titleContainer.decoration! as BoxDecoration;
    expect(titleDecoration.color, theme.colorScheme.primaryContainer);

    final Container metaContainer = tester.widget<Container>(
      find
          .byWidgetPredicate(
            (Widget widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).borderRadius ==
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
          )
          .first,
    );
    final BoxDecoration metaDecoration =
        metaContainer.decoration! as BoxDecoration;
    expect(metaDecoration.color, theme.colorScheme.surfaceContainerLow);

    final Text descriptionText = tester.widget<Text>(find.text('desc-repo-3'));
    expect(descriptionText.style?.color, theme.colorScheme.onSurfaceVariant);

    await _disposeRoute(tester);
  });

  testWidgets('DemoListRoute 错误页点击重试后可恢复列表展示', (WidgetTester tester) async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <_FakeResponseFactory>[
        () => Future<List<Repo>>.error(Exception('network down')),
        () =>
            Future<List<Repo>>.value(<Repo>[_buildRepo(id: 2, name: 'repo-2')]),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoListRepositoryProvider.overrideWithValue(repository),
          themeProvider.overrideWithValue(Colors.blue),
        ],
        child: const _TestApp(child: DemoListRoute()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(repository.requests, hasLength(1));
    expect(find.text('Exception: network down'), findsOneWidget);

    await tester.tap(find.text('Refresh data'));
    await tester.pump();
    await tester.pump();

    expect(repository.requests, hasLength(2));
    expect(find.text('repo-2'), findsOneWidget);
    expect(find.text('Exception: network down'), findsNothing);

    await _disposeRoute(tester);
  });

  testWidgets('DemoListRoute 横屏宽屏下会收敛主内容宽度并保持列表可见', (
    WidgetTester tester,
  ) async {
    final _FakeDemoListRepository repository = _FakeDemoListRepository(
      responses: <_FakeResponseFactory>[
        () => Future<List<Repo>>.value(<Repo>[
          _buildRepo(id: 1, name: 'repo-1'),
          _buildRepo(id: 2, name: 'repo-2'),
        ]),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(932, 430));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoListRepositoryProvider.overrideWithValue(repository),
          themeProvider.overrideWithValue(Colors.blue),
        ],
        child: const _TestApp(child: DemoListRoute()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('repo-1'), findsOneWidget);
    expect(find.text('desc-repo-1'), findsOneWidget);

    final ConstrainedBox constraintBox = tester.widget<ConstrainedBox>(
      find.byKey(const ValueKey<String>('demo_list_item_constraint_0')),
    );
    final Size constrainedSize = tester.getSize(
      find.byKey(const ValueKey<String>('demo_list_item_constraint_0')),
    );

    expect(constraintBox.constraints.maxWidth, 760);
    expect(constrainedSize.width, lessThan(932));

    await _disposeRoute(tester);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.themeMode = ThemeMode.light});

  final Widget child;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.buildLightThemeData(Colors.blue.toARGB32()),
      darkTheme: AppTheme.buildDarkThemeData(Colors.blue.toARGB32()),
      themeMode: themeMode,
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

typedef _FakeResponseFactory = Future<List<Repo>> Function();

class _FakeDemoListRepository extends DemoListRepository {
  _FakeDemoListRepository({required List<_FakeResponseFactory> responses})
    : _responses = Queue<_FakeResponseFactory>.from(responses);

  final Queue<_FakeResponseFactory> _responses;
  final List<_FetchRequest> requests = <_FetchRequest>[];

  /// 按预设响应返回仓库列表，并记录每次请求参数。
  ///
  /// [username] 表示当前请求使用的 GitHub 用户名。
  /// [page] 表示当前请求页码。
  /// [pageSize] 表示单页请求数量。
  ///
  /// 返回值：测试预设的仓库列表 Future；若未预设响应则抛出状态错误。
  @override
  Future<List<Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) {
    requests.add(
      _FetchRequest(username: username, page: page, pageSize: pageSize),
    );
    if (_responses.isEmpty) {
      throw StateError('No fake response queued for fetchRepos');
    }
    return _responses.removeFirst()();
  }
}

class _FetchRequest {
  const _FetchRequest({
    required this.username,
    required this.page,
    required this.pageSize,
  });

  final String username;
  final int page;
  final int pageSize;
}

/// 主动卸载 DemoListRoute，尽量清空第三方滚动组件残留的异步任务。
///
/// [tester] 表示当前 widget 测试驱动器。
///
/// 方法会把页面替换为空组件，并额外推进一小段时间让销毁回调完成。
Future<void> _disposeRoute(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

/// 构建用于测试的最小仓库对象。
///
/// [id] 表示仓库唯一标识。
/// [name] 表示仓库名称。
///
/// 返回值：满足当前列表展示所需字段的测试仓库对象。
Repo _buildRepo({required int id, required String name}) {
  final Repo repo = Repo();
  repo.id = id;
  repo.name = name;
  repo.full_name = 'tester/$name';
  repo.owner = _buildUser();
  repo.private = false;
  repo.html_url = 'https://example.com/$name';
  repo.description = 'desc-$name';
  repo.fork = false;
  repo.homepage = null;
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
  repo.license = null;
  return repo;
}

/// 构建用于测试的最小用户对象。
///
/// 返回值：满足仓库 owner 字段约束的测试用户对象。
User _buildUser() {
  final User user = User();
  user.login = 'tester';
  user.id = 1;
  user.avatar_url = 'https://example.com/avatar.png';
  user.url = 'https://example.com/users/tester';
  user.type = 'User';
  return user;
}
