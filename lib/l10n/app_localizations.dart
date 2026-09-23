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

  /// Simple description for feature 1
  ///
  /// In en, this message translates to:
  /// **'Point your camera to detect and hear objects around you in real time'**
  String get featureDetectorDesc;

  /// Title for feature 2
  ///
  /// In en, this message translates to:
  /// **'AI Image Analyzer'**
  String get featureAnalyzerTitle;

  /// Simple description for feature 2
  ///
  /// In en, this message translates to:
  /// **'Take or choose a photo to hear a detailed description of the scene'**
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
  /// **'Live camera feed will appear here'**
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

  /// Button and semantic label to pause detection
  ///
  /// In en, this message translates to:
  /// **'Pause detection'**
  String get pauseDetection;

  /// Button and semantic label to resume detection
  ///
  /// In en, this message translates to:
  /// **'Resume detection'**
  String get resumeDetection;

  /// Semantic accessibility label for live camera preview
  ///
  /// In en, this message translates to:
  /// **'Live camera feed for object detection'**
  String get cameraFeedSemantic;

  /// TalkBack announcement when an object is detected
  ///
  /// In en, this message translates to:
  /// **'{label} detected'**
  String detectedObjectAnnouncement(String label);

  /// Status text when detection is paused
  ///
  /// In en, this message translates to:
  /// **'Detection paused'**
  String get detectorPausedStatus;

  /// Status text when detection is ready
  ///
  /// In en, this message translates to:
  /// **'Ready to detect'**
  String get detectorReadyStatus;

  /// HUD count of detected objects with ICU plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No objects detected} =1{1 object detected} other{{count} objects detected}}'**
  String detectorObjectsCount(num count);

  /// HUD count with latency in milliseconds with ICU plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 object | {latency}ms} other{{count} objects | {latency}ms}}'**
  String detectorObjectsCountWithLatency(num count, int latency);

  /// HUD status text when detection is paused with saved count with ICU plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Detection paused (0 saved)} =1{Detection paused (1 saved)} other{Detection paused ({count} saved)}}'**
  String detectorPausedWithCount(num count);

  /// Action button text based on detector state with ICU select
  ///
  /// In en, this message translates to:
  /// **'{state, select, running{Pause detection} paused{Resume detection} other{Start Detection}}'**
  String detectorActionSelect(String state);

  /// Error message when no camera is found
  ///
  /// In en, this message translates to:
  /// **'No camera available on this device.'**
  String get cameraUnavailable;

  /// Error message prefix for camera issues
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraErrorPrefix(String error);

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

  /// Progress message while analyzing image
  ///
  /// In en, this message translates to:
  /// **'Analyzing image with AI...'**
  String get analyzingProgress;

  /// TalkBack announcement after photo capture
  ///
  /// In en, this message translates to:
  /// **'Analyzing image, please wait'**
  String get analyzingImagePleaseWait;

  /// TalkBack announcement when analyzer enters processing state
  ///
  /// In en, this message translates to:
  /// **'processing'**
  String get processingAnnouncement;

  /// Semantic accessibility label for processing live region
  ///
  /// In en, this message translates to:
  /// **'processing'**
  String get processingSemanticLabel;

  /// Button to retry a failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Button to clear result and take another photo
  ///
  /// In en, this message translates to:
  /// **'Take Another Photo'**
  String get captureAnotherButton;

  /// Header title for analysis result
  ///
  /// In en, this message translates to:
  /// **'Scene Description'**
  String get analysisResultTitle;

  /// Accessibility label for analyzer camera feed
  ///
  /// In en, this message translates to:
  /// **'Live camera view for image analysis'**
  String get analyzerCameraFeedSemantic;

  /// Accessibility label for capture button
  ///
  /// In en, this message translates to:
  /// **'Capture photo for AI analysis'**
  String get captureButtonSemantic;

  /// Accessibility label for retry button
  ///
  /// In en, this message translates to:
  /// **'Retry analyzing the photo'**
  String get retryButtonSemantic;

  /// Accessibility label for tag chip with confidence
  ///
  /// In en, this message translates to:
  /// **'Tag: {tag}, {confidence} confidence'**
  String analyzerTagSemantic(String tag, String confidence);

  /// Count of identified tags with ICU plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tags identified} =1{1 tag identified} other{{count} tags identified}}'**
  String analyzerTagsCount(num count);

  /// Title for accessible error popup dialog
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get errorDialogTitle;

  /// Button to dismiss the error dialog
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get errorDialogDismiss;

  /// Status text for error state
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// Error message when network is unreachable
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze image. Please check your internet connection and try again.'**
  String get analyzerErrorNetwork;

  /// Generic error message when analysis fails
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze image. Please try again.'**
  String get analyzerErrorGeneric;

  /// Error message when API key is missing
  ///
  /// In en, this message translates to:
  /// **'Gemini API key not found. Please add GEMINI_API_KEY to your .env file.'**
  String get analyzerErrorApiKey;

  /// Snackbar error message when camera capture fails
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo: {error}'**
  String failedToCapturePhoto(String error);

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
  /// **'हिन्दी (Hindi)'**
  String get languageHindi;

  /// Subtitle describing English language option
  ///
  /// In en, this message translates to:
  /// **'Default language'**
  String get englishLanguageSubtitle;

  /// Subtitle describing Hindi language option
  ///
  /// In en, this message translates to:
  /// **'National language of India'**
  String get hindiLanguageSubtitle;

  /// Accessibility hint to select English
  ///
  /// In en, this message translates to:
  /// **'English, tap to select English'**
  String get selectEnglishSemantic;

  /// Accessibility hint to select Hindi
  ///
  /// In en, this message translates to:
  /// **'Hindi, tap to select Hindi'**
  String get selectHindiSemantic;

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

  /// Theme mode label with ICU select
  ///
  /// In en, this message translates to:
  /// **'{mode, select, system{System Default} light{Light} dark{Dark} other{System Default}}'**
  String themeModeSelect(String mode);

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

  /// Label indicating user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// Error message when user is not found
  ///
  /// In en, this message translates to:
  /// **'No user found with this email address.'**
  String get authErrorUserNotFound;

  /// Error message for incorrect password
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get authErrorWrongPassword;

  /// Error message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// Error message when user account is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// Error message when requests are throttled
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Error message for network failure
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get authErrorNetworkFailed;

  /// Notice when Google sign-in is cancelled by user
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authErrorGoogleCancelled;

  /// Generic authentication failure message
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check your credentials.'**
  String get authErrorGeneric;

  /// Greeting with user display name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greetingWithName(String name);

  /// Accessibility semantic label for profile avatar
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}, tap to open menu'**
  String profileSemanticLabel(String name);

  /// Title for profile bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Account Profile'**
  String get profileMenuTitle;

  /// Accessibility label to close profile bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Close profile menu'**
  String get profileMenuClose;

  /// Button label to start a feature
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startFeatureButton;

  /// Text prompt on feature card indicating user can tap anywhere to start
  ///
  /// In en, this message translates to:
  /// **'Click to start'**
  String get clickToStart;

  /// Accessibility announcement for object detector card
  ///
  /// In en, this message translates to:
  /// **'Live Object Detector: Point your camera to detect and hear objects around you in real time. Click to start.'**
  String get detectorCardSemantic;

  /// Accessibility announcement for AI analyzer card
  ///
  /// In en, this message translates to:
  /// **'AI Image Analyzer: Take or choose a photo to hear a detailed description of the scene. Click to start.'**
  String get analyzerCardSemantic;

  /// Placeholder when user email is absent
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get emailNotProvided;

  /// Accessibility label for login logo
  ///
  /// In en, this message translates to:
  /// **'Vision Companion logo'**
  String get loginHeaderSemantic;

  /// Accessibility label for password toggle button
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get passwordVisibilityToggleSemantic;

  /// Title for sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpTitle;

  /// Subtitle for sign up screen
  ///
  /// In en, this message translates to:
  /// **'Join Vision Companion for assistive vision support'**
  String get signUpSubtitle;

  /// Text for create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpButton;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// Hint for name field
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// Validation error for empty name
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Hint for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// Validation error for empty confirm password
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// Validation error when passwords differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Validation error when password is under 6 characters
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Prompt to switch to sign in mode
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// Prompt to switch to sign up mode
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// Accessibility label to switch to sign up form
  ///
  /// In en, this message translates to:
  /// **'Switch to Sign Up form'**
  String get switchToSignUpSemantic;

  /// Accessibility label to switch to sign in form
  ///
  /// In en, this message translates to:
  /// **'Switch to Sign In form'**
  String get switchToSignInSemantic;

  /// Error message when email is already registered
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email address.'**
  String get authErrorEmailAlreadyInUse;

  /// Error message when password is too weak
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please use at least 6 characters.'**
  String get authErrorWeakPassword;

  /// App title on splash screen
  ///
  /// In en, this message translates to:
  /// **'Vision Companion'**
  String get splashTitle;

  /// App subtitle on splash screen
  ///
  /// In en, this message translates to:
  /// **'AI Assistive Companion'**
  String get splashSubtitle;

  /// Prompt on splash screen to choose language
  ///
  /// In en, this message translates to:
  /// **'Welcome! Please choose your preferred language to continue.'**
  String get splashWelcomeText;

  /// Header for language selection
  ///
  /// In en, this message translates to:
  /// **'Choose Language / भाषा चुनें'**
  String get selectLanguagePrompt;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Semantic announcement for continue button
  ///
  /// In en, this message translates to:
  /// **'Continue to application'**
  String get continueButtonSemantic;

  /// Semantic announcement when language is selected
  ///
  /// In en, this message translates to:
  /// **'{language} selected'**
  String languageSelectedSemantic(String language);

  /// Label for account status in profile settings
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatusLabel;

  /// Status text for logged in user
  ///
  /// In en, this message translates to:
  /// **'Signed In'**
  String get signedInStatus;

  /// Status text for guest / unauthenticated user
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestStatus;

  /// Label for user ID in profile settings
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdLabel;

  /// Title for about section in settings
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSectionTitle;

  /// Label displaying application version
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersionLabel;

  /// Notice that Firebase Crashlytics is active for automatic crash reporting
  ///
  /// In en, this message translates to:
  /// **'Crash reporting active'**
  String get crashReportingActive;
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
