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
  String get noMoreData => '没有更多数据了';

  @override
  String get demo => '样例';
}
