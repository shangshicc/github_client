import 'package:flutter_test/flutter_test.dart';
import 'package:github_client_app/common/git_api.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/home/data/home_repository.dart';

void main() {
  test(
    'HomeRepository maps username/page/pageSize to Git.getRepos queryParmeters',
    () async {
      final List<Repo> expectedRepos = <Repo>[Repo()..name = 'repo-1'];
      final _RecordingGit git = _RecordingGit(result: expectedRepos);
      final HomeRepository repository = HomeRepository(git: git);

      final List<Repo> repos = await repository.fetchRepos(
        username: 'octocat',
        page: 3,
        pageSize: 20,
      );

      expect(repos, same(expectedRepos));
      expect(git.capturedQueryParameters, isNotNull);
      expect(git.capturedQueryParameters!['username'], 'octocat');
      expect(git.capturedQueryParameters!['page'], 3);
      expect(git.capturedQueryParameters!['page_size'], 20);
      expect(git.capturedRefresh, isFalse);
    },
  );
}

class _RecordingGit extends Git {
  _RecordingGit({required List<Repo> result}) : _result = result;

  final List<Repo> _result;
  Map<String, dynamic>? capturedQueryParameters;
  bool capturedRefresh = false;

  @override
  Future<List<Repo>> getRepos({
    Map<String, dynamic>? queryParmeters,
    refresh = false,
  }) async {
    capturedQueryParameters = queryParmeters;
    capturedRefresh = refresh as bool;
    return _result;
  }
}
