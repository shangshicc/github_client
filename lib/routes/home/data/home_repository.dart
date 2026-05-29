import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:github_client_app/common/git_api.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart';

final _log = createLogger('[HomeRepository]');

final Provider<HomeRepository> homeRepositoryProvider =
    Provider<HomeRepository>((ref) => HomeRepository());

/// 首页仓储类。
///
/// 负责封装首页仓库数据获取逻辑，避免页面层直接依赖接口细节。
class HomeRepository {
  /// 创建首页仓储。
  ///
  /// [git] 表示 GitHub API 客户端实例，由上层注入以支持测试替换。
  HomeRepository({Git? git}) : _git = git ?? Git();

  final Git _git;

  /// 获取指定用户的仓库列表。
  ///
  /// [username] 表示目标 GitHub 用户名。
  /// [page] 表示分页页码，从 1 开始。
  /// [pageSize] 表示单页数量。
  Future<List<Repo>> fetchRepos({
    required String username,
    required int page,
    required int pageSize,
  }) async {
    _log.d('请求首页仓库列表，username: $username, page: $page, pageSize: $pageSize');
    return _git.getRepos(
      queryParmeters: {
        'username': username,
        'page': page,
        'page_size': pageSize,
      },
    );
  }
}
