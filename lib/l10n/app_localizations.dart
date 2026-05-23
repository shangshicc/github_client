import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Title for the Demo application
  ///
  /// In en, this message translates to:
  /// **'Flutter APP'**
  String get title;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Github'**
  String get home;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet !'**
  String get noDescription;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @userNameRequired.
  ///
  /// In en, this message translates to:
  /// **'User name required!'**
  String get userNameRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required!'**
  String get passwordRequired;

  /// No description provided for @userNameOrPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'User name or password is not correct!'**
  String get userNameOrPasswordWrong;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'logout'**
  String get logout;

  /// No description provided for @logoutTip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit your current account?'**
  String get logoutTip;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @repoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No repositories yet'**
  String get repoEmpty;

  /// Shown at the bottom of the list when more pages can still be loaded.
  ///
  /// In en, this message translates to:
  /// **'More data'**
  String get moreData;

  /// Shown at the bottom of the list when there is no more data to load.
  ///
  /// In en, this message translates to:
  /// **'No more data.'**
  String get noMoreData;

  /// Entry and title for the list demo page.
  ///
  /// In en, this message translates to:
  /// **'List Demo'**
  String get demoList;

  /// Shown while the list demo is loading data.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get demoListLoading;

  /// Shown when the list demo is loading the next page.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get demoListLoadingMore;

  /// Shown when the list demo request succeeds but returns no data.
  ///
  /// In en, this message translates to:
  /// **'No data currently'**
  String get demoListEmpty;

  /// Shown when the list demo request fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load. Please try again later.'**
  String get demoListLoadFailed;

  /// Button text for refreshing data in the list demo.
  ///
  /// In en, this message translates to:
  /// **'Refresh data'**
  String get demoListRefreshData;

  /// Entry and title for the NestedScrollView demo page.
  ///
  /// In en, this message translates to:
  /// **'NestedScrollView Demo'**
  String get demoNestedScroll;

  /// Profile bio shown in the NestedScrollView demo header.
  ///
  /// In en, this message translates to:
  /// **'Demonstrates the most common profile scrolling layout: collapse the header first, pin the TabBar, and keep each tab scrolling independently.'**
  String get demoNestedScrollProfileBio;

  /// Repository count label in the NestedScrollView demo header.
  ///
  /// In en, this message translates to:
  /// **'Repos'**
  String get demoNestedScrollStatsRepos;

  /// Followers count label in the NestedScrollView demo header.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get demoNestedScrollStatsFollowers;

  /// Following count label in the NestedScrollView demo header.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get demoNestedScrollStatsFollowing;

  /// Repositories tab label in the NestedScrollView demo.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get demoNestedScrollTabRepositories;

  /// Activity tab label in the NestedScrollView demo.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get demoNestedScrollTabActivity;

  /// Stars tab label in the NestedScrollView demo.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get demoNestedScrollTabStars;

  /// Subtitle shown for each list item in the NestedScrollView demo.
  ///
  /// In en, this message translates to:
  /// **'Item {index} · Used to demonstrate how {itemTitle} keeps scrolling independently inside the inner list'**
  String demoNestedScrollListItemSubtitle(int index, String itemTitle);

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'demo'**
  String get demo;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit the app.'**
  String get pressAgainToExit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
