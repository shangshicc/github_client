import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/demo/list/data/demo_list_repository.dart';
import 'package:github_client_app/routes/demo/list/models/demo_list_item.dart';
import 'package:github_client_app/routes/demo/list/states/demo_list_provider.dart';

class _FakeDemoListRepository extends DemoListRepository {
  _FakeDemoListRepository(this._pages);

  final Map<int, Object> _pages;
  final List<int> requestedPages = <int>[];

  @override
  Future<List<Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    requestedPages.add(page);
    final result = _pages[page];
    if (result is Exception) {
      throw result;
    }
    return result as List<Repo>;
  }
}

void main() {
  group('DemoListProvider', () {
    test('首次加载成功后展示仓库并允许继续分页', () async {
      final repository = _FakeDemoListRepository({
        1: List<Repo>.generate(
          DemoListProvider.pageSize,
          (index) => _repo('repo-$index'),
        ),
      });
      final provider = DemoListProvider(repository: repository);

      final future = provider.loadInitialData();

      expect(provider.isInitialLoading, isTrue);
      expect(provider.isStateOnly, isTrue);
      expect(provider.items, hasLength(1));
      expect(provider.items.single, isA<DemoListStateItemData>());

      await future;

      expect(repository.requestedPages, <int>[1]);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isFalse);
      expect(provider.hasMore, isTrue);
      expect(provider.items, hasLength(DemoListProvider.pageSize * 2));
      for (var i = 0; i < DemoListProvider.pageSize; i++) {
        expect(provider.items[i * 2], isA<DemoListTitleItemData>());
        expect(provider.items[i * 2 + 1], isA<DemoListMetaItemData>());
      }
    });

    test('首次加载空列表后展示空态并停止加载更多', () async {
      final provider = DemoListProvider(
        repository: _FakeDemoListRepository({1: <Repo>[]}),
      );

      await provider.loadInitialData();

      expect(provider.isEmpty, isTrue);
      expect(provider.isStateOnly, isTrue);
      expect(provider.hasMore, isFalse);
      expect(provider.items, hasLength(1));
      expect(provider.items.single, isA<DemoListStateItemData>());
    });

    test('首次加载失败后保留错误信息并展示错误态', () async {
      final provider = DemoListProvider(
        repository: _FakeDemoListRepository({1: Exception('boom')}),
      );

      await provider.loadInitialData();

      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('boom'));
      expect(provider.isStateOnly, isTrue);
      expect(provider.hasMore, isFalse);
      expect(provider.items, hasLength(1));
      expect(provider.items.single, isA<DemoListStateItemData>());
    });

    test('加载更多会追加下一页仓库并在短页后关闭分页', () async {
      final repository = _FakeDemoListRepository({
        1: List<Repo>.generate(
          DemoListProvider.pageSize,
          (index) => _repo('repo-$index'),
        ),
        2: <Repo>[_repo('repo-next')],
      });
      final provider = DemoListProvider(repository: repository);

      await provider.loadInitialData();
      await provider.loadMoreData();

      expect(repository.requestedPages, <int>[1, 2]);
      expect(provider.items, hasLength((DemoListProvider.pageSize + 1) * 2));
      for (var i = 0; i < DemoListProvider.pageSize + 1; i++) {
        expect(provider.items[i * 2], isA<DemoListTitleItemData>());
        expect(provider.items[i * 2 + 1], isA<DemoListMetaItemData>());
      }
      expect(provider.hasMore, isFalse);
      expect(provider.isLoadingMore, isFalse);
    });
  });
}

Repo _repo(String name) {
  return Repo()
    ..name = name
    ..full_name = 'octocat/$name'
    ..fork = false
    ..description = 'description for $name'
    ..language = 'Dart'
    ..stargazers_count = 1
    ..forks_count = 2
    ..updated_at = '2026-05-09';
}
