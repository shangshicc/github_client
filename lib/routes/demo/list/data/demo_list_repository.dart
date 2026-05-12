import 'package:github_client_app/common/git_api.dart';
import 'package:github_client_app/common/logger.dart';
import 'package:github_client_app/models/index.dart';

final _log = createLogger('[DemoListRepository]');

/// Demo 列表仓储类。
///
/// 负责封装仓库数据获取逻辑，避免页面层直接依赖接口细节。
class DemoListRepository {
  /// 创建 Demo 列表仓储。
  ///
  /// [git] 表示 GitHub API 客户端实例，由上层注入，避免仓储层依赖 BuildContext。
  DemoListRepository({
    Git? git,
  }) : _git = git ?? Git();

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
    _log.d('请求仓库列表，username: $username, page: $page, pageSize: $pageSize');
    return _git.getRepos(
      queryParmeters: {
        'username': username,
        'page': page,
        'per_page': pageSize,
      },
    );
  }
}
