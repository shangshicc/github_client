// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Flutter APP';

  @override
  String get home => 'Github';

  @override
  String get language => 'Language';

  @override
  String get login => 'Login';

  @override
  String get auto => 'Auto';

  @override
  String get setting => 'Setting';

  @override
  String get theme => 'Theme';

  @override
  String get noDescription => 'No description yet !';

  @override
  String get userName => 'User Name';

  @override
  String get userNameRequired => 'User name required!';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password required!';

  @override
  String get userNameOrPasswordWrong => 'User name or password is not correct!';

  @override
  String get logout => 'logout';

  @override
  String get logoutTip => 'Are you sure you want to quit your current account?';

  @override
  String get yes => 'yes';

  @override
  String get cancel => 'cancel';

  @override
  String get noMoreData => 'No more data.';
}
