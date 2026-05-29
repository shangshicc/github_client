import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, ConsumerWidget, WidgetRef;
import 'package:go_router/go_router.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/routes/home/data/home_repository.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/states/profile_state.dart';
import 'package:github_client_app/states/riverpod/counter_provider.dart';

import '../common/home_back_guard.dart';
import '../common/logger.dart';
import '../widgets/repo_item.dart';

final _log = createLogger('HomeRoute');

class HomeRoute extends ConsumerStatefulWidget {
  /// 创建首页路由。
  ///
  /// [backGuard] 表示首页返回防误触守卫。
  const HomeRoute({Key? key, HomeBackGuard? backGuard})
    : _backGuard = backGuard,
      super(key: key);

  /// 未登录场景下用于展示首页演示数据的默认用户名。
  static const String defaultUsername = 'octocat';

  final HomeBackGuard? _backGuard;

  @override
  ConsumerState<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends ConsumerState<HomeRoute> {
  static const String loadingTag = '##loading##'; //表尾标记
  final List<Repo> _items = <Repo>[Repo()..name = loadingTag];
  late final HomeBackGuard _backGuard;
  bool hasMore = true; //是否还有数据
  int page = 1; //当前请求的是第几页
  String? _activeUsername;

  @override
  void initState() {
    super.initState();
    _backGuard = widget._backGuard ?? HomeBackGuard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int counter = ref.watch(counterProvider);
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _handleBackPress(l10n.pressAgainToExit);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.home),
          actions: [
            Text(
              'click  $counter',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        body: _buildBody(),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => context.push(AppRoutePaths.selector),
        ),
      ),
    );
  }

  /// 处理首页返回动作：首次提示，窗口内二次触发时退出应用。
  Future<void> _handleBackPress(String message) async {
    final HomeBackDecision decision = _backGuard.registerBackAttempt();
    if (decision == HomeBackDecision.exitApp) {
      _log.i('HomeRoute back pressed twice within 2 seconds, exiting app');
      await SystemNavigator.pop();
      return;
    }
    _log.i('HomeRoute intercepted first back press, showing exit hint');
    showToast(message);
  }

  /// 构建首页主体列表。
  ///
  /// 未登录时仍展示默认演示账号的数据，避免首页退化为纯登录入口。
  Widget _buildBody() {
    final bool login = ref.watch(isLoginProvider);
    final User? currentUser = ref.watch(userProvider);
    final String displayUsername = _resolveDisplayUsername(
      login: login,
      currentUser: currentUser,
    );
    _ensureActiveUsername(displayUsername);

    final Widget listView = ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        if (_items[index].name == loadingTag) {
          if (hasMore) {
            _retrieveDate(displayUsername);
            return Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            );
          }
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context).noMoreData,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return GestureDetector(
          onTap: () {
            context.push(AppRoutePaths.detail);
          },
          child: RepoItem(_items[index]),
        );
      },
    );
    if (login) {
      return listView;
    }
    return Column(
      children: [_buildGuestHint(displayUsername), Expanded(child: listView)],
    );
  }

  /// 构建未登录首页的演示账号提示条。
  ///
  /// [username] 表示当前展示的演示账号名。
  ///
  /// 返回值：包含演示账号说明与登录入口的提示组件。
  Widget _buildGuestHint(String username) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Material(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Demo account: $username',
                key: const ValueKey<String>('home-guest-hint-text'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey<String>('home-guest-login-button'),
              onPressed: () => context.push(AppRoutePaths.login),
              child: Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }

  /// 解析首页当前应该展示哪个用户名的数据。
  ///
  /// [login] 表示当前是否已登录。
  /// [currentUser] 表示当前登录用户。
  ///
  /// 返回值：已登录时返回当前用户登录名，否则返回演示用户名。
  String _resolveDisplayUsername({
    required bool login,
    required User? currentUser,
  }) {
    if (login && (currentUser?.login.isNotEmpty == true)) {
      return currentUser!.login;
    }
    return HomeRoute.defaultUsername;
  }

  /// 当首页数据源用户名发生变化时，重置分页并触发重新加载。
  ///
  /// [nextUsername] 表示当前应展示的目标用户名。
  ///
  /// 副作用：会清空现有列表并把分页状态恢复为初始值。
  void _ensureActiveUsername(String nextUsername) {
    if (_activeUsername == nextUsername) {
      return;
    }
    _log.i(
      'HomeRoute data source changed, previous=${_activeUsername ?? "null"}, next=$nextUsername',
    );
    _activeUsername = nextUsername;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..add(Repo()..name = loadingTag);
        hasMore = true;
        page = 1;
      });
    });
  }

  /// 根据用户名分页拉取首页仓库列表。
  ///
  /// [username] 表示本次请求的 GitHub 用户名。
  ///
  /// 副作用：会发起网络请求，并在成功后更新首页分页列表。
  void _retrieveDate(String username) async {
    try {
      final HomeRepository repository = ref.read(homeRepositoryProvider);
      final List<Repo> data = await repository.fetchRepos(
        username: username,
        page: page,
        pageSize: 20,
      );
      hasMore = data.isNotEmpty && data.length % 20 == 0;
      setState(() {
        _items.insertAll(_items.length - 1, data);
        page++;
      });
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? -1) != 200) {
        showToast(e.toString());
      }
    }
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(), Expanded(child: _buildMenus())],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const _DrawerHeaderSection();
  }

  Widget _buildMenus() {
    return const _DrawerMenusSection();
  }
}

/// 抽屉头部区域，统一使用 Riverpod ConsumerWidget 消费用户与主题状态。
class _DrawerHeaderSection extends ConsumerWidget {
  const _DrawerHeaderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final bool login = ref.watch(isLoginProvider);
    final User? user = ref.watch(userProvider);
    final Color headerColor = Theme.of(context).colorScheme.primary;
    _log.i(
      'Drawer header build, login=$login, user=${user?.login ?? "null"}, '
      'headerColor=${headerColor.toARGB32()}',
    );
    return GestureDetector(
      child: Container(
        color: headerColor,
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipOval(
                child:
                    login
                        ? gmAvatar(user?.avatar_url ?? '', width: 80)
                        : Image.asset('imgs/avatar-default.png', width: 80),
              ),
            ),
            Text(
              login ? user?.login ?? 'isLogined' : l10n.login,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (!login) {
          context.push(AppRoutePaths.login);
        }
      },
    );
  }
}

/// 抽屉菜单区域，统一使用 Riverpod ConsumerWidget 消费登录状态。
class _DrawerMenusSection extends ConsumerWidget {
  const _DrawerMenusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool login = ref.watch(isLoginProvider);
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: Text(l10n.theme),
          onTap: () => context.push(AppRoutePaths.themes),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          onTap: () => context.push(AppRoutePaths.language),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(l10n.demo),
          onTap: () => context.push(AppRoutePaths.demo),
        ),
        if (login)
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: Text(l10n.logout),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    content: Text(l10n.logoutTip),
                    actions: [
                      TextButton(
                        onPressed: () => dialogContext.pop(),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(profileProvider.notifier).updateUser(null);
                          dialogContext.pop();
                        },
                        child: Text(l10n.yes),
                      ),
                    ],
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
