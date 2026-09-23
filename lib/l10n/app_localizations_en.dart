// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vision Companion';

  @override
  String get homeTitle => 'Home';

  @override
  String get welcomeMessage => 'Welcome to Vision Companion';

  @override
  String get subtitleAssistive => 'Empowering assistive visual intelligence';

  @override
  String get featureDetectorTitle => 'Live Object Detector';

  @override
  String get featureDetectorDesc =>
      'Real-time on-device object detection using TFLite';

  @override
  String get featureAnalyzerTitle => 'AI Image Analyzer';

  @override
  String get featureAnalyzerDesc =>
      'In-depth visual understanding and scene description via AI';

  @override
  String get featureSettingsTitle => 'Settings & Profile';

  @override
  String get featureSettingsDesc =>
      'Manage language preferences, theme, and profile';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Access your assistive vision assistant';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get detectorScreenTitle => 'Real-Time Object Detector';

  @override
  String get detectorPlaceholderMessage =>
      'TFLite Live Camera Feed will stream here';

  @override
  String get startDetection => 'Start Detection';

  @override
  String get stopDetection => 'Stop Detection';

  @override
  String get analyzerScreenTitle => 'AI Scene Analyzer';

  @override
  String get analyzerPlaceholderMessage =>
      'Capture or choose an image to analyze';

  @override
  String get pickImageButton => 'Pick from Gallery';

  @override
  String get captureImageButton => 'Capture Photo';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSetting => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी (Hindi)';

  @override
  String get themeSetting => 'Theme Mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get profileSection => 'User Profile';

  @override
  String get anonymousUser => 'Guest User';

  @override
  String get authErrorUserNotFound => 'No user found with this email address.';

  @override
  String get authErrorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorTooManyRequests =>
      'Too many failed attempts. Please try again later.';

  @override
  String get authErrorNetworkFailed =>
      'Network error. Please check your internet connection.';

  @override
  String get authErrorGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authErrorGeneric =>
      'Authentication failed. Please check your credentials.';

  @override
  String greetingWithName(String name) {
    return 'Hello, $name!';
  }

  @override
  String profileSemanticLabel(String name) {
    return 'Profile: $name, tap to open menu';
  }

  @override
  String get profileMenuTitle => 'Account Profile';

  @override
  String get profileMenuClose => 'Close profile menu';

  @override
  String get startFeatureButton => 'Start';

  @override
  String get detectorCardSemantic =>
      'Live Object Detector: Real-time on-device object detection using TFLite. Double tap to start.';

  @override
  String get analyzerCardSemantic =>
      'AI Image Analyzer: In-depth visual understanding and scene description via AI. Double tap to start.';

  @override
  String get emailNotProvided => 'No email provided';

  @override
  String get loginHeaderSemantic => 'Vision Companion logo';

  @override
  String get passwordVisibilityToggleSemantic => 'Toggle password visibility';
}
