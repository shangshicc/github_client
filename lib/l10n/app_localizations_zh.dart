// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get title => 'Github客户端';

  @override
  String get home => 'Github客户端';

  @override
  String get language => '语言';

  @override
  String get login => '登录';

  @override
  String get auto => '跟随系统';

  @override
  String get setting => '设置';

  @override
  String get theme => '换肤';

  @override
  String get noDescription => '暂无描述!';

  @override
  String get userName => '用户名';

  @override
  String get userNameRequired => '用户名不能为空';

  @override
  String get password => '密码';

  @override
  String get passwordRequired => '密码不能为空';

  @override
  String get userNameOrPasswordWrong => '用户名或密码不正确';

  @override
  String get logout => '注销';

  @override
  String get logoutTip => '确定要退出当前账号吗?';

  @override
  String get yes => '确定';

  @override
  String get cancel => '取消';

  @override
  String get retry => '重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String get repoEmpty => '暂无仓库数据';

  @override
  String get moreData => '更多数据';

  @override
  String get noMoreData => '没有更多数据了';

  @override
  String get demoList => '列表 Demo';

  @override
  String get demoListLoading => '加载中...';

  @override
  String get demoListLoadingMore => '加载更多...';

  @override
  String get demoListEmpty => '当前无数据';

  @override
  String get demoListLoadFailed => '获取失败，请稍候重试';

  @override
  String get demoListRefreshData => '刷新数据';

  @override
  String get demoNestedScroll => 'NestedScrollView Demo';

  @override
  String get demoNestedScrollProfileBio =>
      '演示个人主页中最常见的滚动结构：头部区域先折叠，TabBar 吸顶后，每个标签页继续独立滚动。';

  @override
  String get demoNestedScrollStatsRepos => '仓库';

  @override
  String get demoNestedScrollStatsFollowers => '关注者';

  @override
  String get demoNestedScrollStatsFollowing => '正在关注';

  @override
  String get demoNestedScrollTabRepositories => 'Repositories';

  @override
  String get demoNestedScrollTabActivity => 'Activity';

  @override
  String get demoNestedScrollTabStars => 'Stars';

  @override
  String demoNestedScrollListItemSubtitle(int index, String itemTitle) {
    return '第$index项 · 用于演示 $itemTitle 在内层列表中的独立滚动效果';
  }

  @override
  String get demo => '样例';

  @override
  String get pressAgainToExit => '再按一次退出程序';
}
