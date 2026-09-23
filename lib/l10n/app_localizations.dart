import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Vision Companion'**
  String get appTitle;

  /// Title for home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Welcome message displayed on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vision Companion'**
  String get welcomeMessage;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Empowering assistive visual intelligence'**
  String get subtitleAssistive;

  /// Title for feature 1
  ///
  /// In en, this message translates to:
  /// **'Live Object Detector'**
  String get featureDetectorTitle;

  /// Description for feature 1
  ///
  /// In en, this message translates to:
  /// **'Real-time on-device object detection using TFLite'**
  String get featureDetectorDesc;

  /// Title for feature 2
  ///
  /// In en, this message translates to:
  /// **'AI Image Analyzer'**
  String get featureAnalyzerTitle;

  /// Description for feature 2
  ///
  /// In en, this message translates to:
  /// **'In-depth visual understanding and scene description via AI'**
  String get featureAnalyzerDesc;

  /// Title for settings feature
  ///
  /// In en, this message translates to:
  /// **'Settings & Profile'**
  String get featureSettingsTitle;

  /// Description for settings feature
  ///
  /// In en, this message translates to:
  /// **'Manage language preferences, theme, and profile'**
  String get featureSettingsDesc;

  /// Title for login screen
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// Subtitle for login screen
  ///
  /// In en, this message translates to:
  /// **'Access your assistive vision assistant'**
  String get loginSubtitle;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Hint for email field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// Hint for password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Validation error for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// Validation error for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// Text for sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// Text for Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Text for sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// Title for detector screen
  ///
  /// In en, this message translates to:
  /// **'Real-Time Object Detector'**
  String get detectorScreenTitle;

  /// Placeholder message for detector screen
  ///
  /// In en, this message translates to:
  /// **'TFLite Live Camera Feed will stream here'**
  String get detectorPlaceholderMessage;

  /// Button to start detection
  ///
  /// In en, this message translates to:
  /// **'Start Detection'**
  String get startDetection;

  /// Button to stop detection
  ///
  /// In en, this message translates to:
  /// **'Stop Detection'**
  String get stopDetection;

  /// Title for analyzer screen
  ///
  /// In en, this message translates to:
  /// **'AI Scene Analyzer'**
  String get analyzerScreenTitle;

  /// Placeholder message for analyzer screen
  ///
  /// In en, this message translates to:
  /// **'Capture or choose an image to analyze'**
  String get analyzerPlaceholderMessage;

  /// Button to pick image from gallery
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickImageButton;

  /// Button to capture image with camera
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get captureImageButton;

  /// Title for settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language setting section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'हिंदी (Hindi)'**
  String get languageHindi;

  /// Theme setting section title
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeSetting;

  /// Light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme mode
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileSection;

  /// Label for unauthenticated or guest user
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get anonymousUser;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
