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
  String get retry => 'Retry';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get repoEmpty => 'No repositories yet';

  @override
  String get moreData => 'More data';

  @override
  String get noMoreData => 'No more data.';

  @override
  String get demoList => 'List Demo';

  @override
  String get demoListLoading => 'Loading...';

  @override
  String get demoListLoadingMore => 'Loading more...';

  @override
  String get demoListEmpty => 'No data currently';

  @override
  String get demoListLoadFailed => 'Failed to load. Please try again later.';

  @override
  String get demoListRefreshData => 'Refresh data';

  @override
  String get demoNestedScroll => 'NestedScrollView Demo';

  @override
  String get demoNestedScrollProfileBio =>
      'Demonstrates the most common profile scrolling layout: collapse the header first, pin the TabBar, and keep each tab scrolling independently.';

  @override
  String get demoNestedScrollStatsRepos => 'Repos';

  @override
  String get demoNestedScrollStatsFollowers => 'Followers';

  @override
  String get demoNestedScrollStatsFollowing => 'Following';

  @override
  String get demoNestedScrollTabRepositories => 'Repositories';

  @override
  String get demoNestedScrollTabActivity => 'Activity';

  @override
  String get demoNestedScrollTabStars => 'Stars';

  @override
  String demoNestedScrollListItemSubtitle(int index, String itemTitle) {
    return 'Item $index · Used to demonstrate how $itemTitle keeps scrolling independently inside the inner list';
  }

  @override
  String get demo => 'demo';
}
