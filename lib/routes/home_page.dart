import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, ConsumerWidget, WidgetRef;
import 'package:github_client_app/l10n/app_localizations.dart';
import 'package:github_client_app/common/funs.dart';
import 'package:github_client_app/common/git_api.dart';
import 'package:github_client_app/models/index.dart';
import 'package:github_client_app/router/app_route_paths.dart';
import 'package:github_client_app/states/riverpod/counter_provider.dart';
import 'package:github_client_app/states/profile_state.dart';
import '../common/home_back_guard.dart';
import '../widgets/repo_item.dart';
import '../common/logger.dart';

final _log = createLogger('HomeRoute');

class HomeRoute extends ConsumerStatefulWidget {
  const HomeRoute({Key? key, HomeBackGuard? backGuard})
    : _backGuard = backGuard,
      super(key: key);

  final HomeBackGuard? _backGuard;

  @override
  ConsumerState<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends ConsumerState<HomeRoute> {
  static const loadingTag = "##loading##"; //表尾标记
  final _items = <Repo>[Repo()..name = loadingTag];
  late final HomeBackGuard _backGuard;
  bool hasMore = true; //是否还有数据
  int page = 1; //当前请求的是第几页

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
        body: _buildBody(), // 构建主页面
        drawer: const MyDrawer(), //构建抽屉组件
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

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    final bool login = ref.watch(isLoginProvider);
    final User? currentUser = ref.watch(userProvider);
    if (!login) {
      return Center(
        child: ElevatedButton(
          child: Text(l10n.login),
          onPressed: () => context.push(AppRoutePaths.login),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          if (_items[index].name == loadingTag) {
            if (hasMore) {
              // 获取数据
              _retrieveDate(currentUser?.login ?? "_retriieveDate login");
              // 加载时显示loading
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            } else {
              // 没有更多数据，不再加载数据
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.noMoreData,
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
          }
          //显示单词列表项
          return GestureDetector(
            onTap: () {
              context.push(AppRoutePaths.detail);
            },
            child: RepoItem(_items[index]),
          );
        },
      );
    }
  }

  // 请求数据
  void _retrieveDate(String username) async {
    try {
      var data = await Git().getRepos(
        queryParmeters: {'username': username, 'page': page, 'page_size': 20},
      );
      //如果返回的数据小于指定的条数，则表示没有更多数据，反之则否
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
          children: [
            _buildHeader(), // 构建抽屉菜单头部
            Expanded(child: _buildMenus()), //构建功能菜单
          ],
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
    final MaterialColor themeColor = ref.watch(themeProvider);
    _log.i(
      'Drawer header build, login=$login, user=${user?.login ?? "null"}, '
      'providerTheme=${themeColor.toARGB32()}',
    );
    return GestureDetector(
      child: Container(
        color: themeColor,
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipOval(
                // 如果已登录，则显示用户头像；若未登录，则显示默认头像
                child:
                    login
                        ? gmAvatar(user?.avatar_url ?? "", width: 80)
                        : Image.asset("imgs/avatar-default.png", width: 80),
              ),
            ),
            Text(
              login ? user?.login ?? "isLogined" : l10n.login,
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
                          // 该赋值语法会重新触发MaterialApp rebuild
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
