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
      'Point your camera to detect and hear objects around you in real time';

  @override
  String get featureAnalyzerTitle => 'AI Image Analyzer';

  @override
  String get featureAnalyzerDesc =>
      'Take or choose a photo to hear a detailed description of the scene';

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
  String get detectorPlaceholderMessage => 'Live camera feed will appear here';

  @override
  String get startDetection => 'Start Detection';

  @override
  String get stopDetection => 'Stop Detection';

  @override
  String get pauseDetection => 'Pause detection';

  @override
  String get resumeDetection => 'Resume detection';

  @override
  String get cameraFeedSemantic => 'Live camera feed for object detection';

  @override
  String detectedObjectAnnouncement(String label) {
    return '$label detected';
  }

  @override
  String get detectorPausedStatus => 'Detection paused';

  @override
  String get detectorReadyStatus => 'Ready to detect';

  @override
  String detectorObjectsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objects detected',
      one: '1 object detected',
      zero: 'No objects detected',
    );
    return '$_temp0';
  }

  @override
  String detectorObjectsCountWithLatency(num count, int latency) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString objects | ${latency}ms',
      one: '1 object | ${latency}ms',
    );
    return '$_temp0';
  }

  @override
  String detectorPausedWithCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Detection paused ($countString saved)',
      one: 'Detection paused (1 saved)',
      zero: 'Detection paused (0 saved)',
    );
    return '$_temp0';
  }

  @override
  String detectorActionSelect(String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'running': 'Pause detection',
      'paused': 'Resume detection',
      'other': 'Start Detection',
    });
    return '$_temp0';
  }

  @override
  String get cameraUnavailable => 'No camera available on this device.';

  @override
  String cameraErrorPrefix(String error) {
    return 'Camera error: $error';
  }

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
  String get analyzingProgress => 'Analyzing image with AI...';

  @override
  String get analyzingImagePleaseWait => 'Analyzing image, please wait';

  @override
  String get processingAnnouncement => 'processing';

  @override
  String get processingSemanticLabel => 'processing';

  @override
  String get retryButton => 'Retry';

  @override
  String get captureAnotherButton => 'Take Another Photo';

  @override
  String get analysisResultTitle => 'Scene Description';

  @override
  String get analyzerCameraFeedSemantic =>
      'Live camera view for image analysis';

  @override
  String get captureButtonSemantic => 'Capture photo for AI analysis';

  @override
  String get retryButtonSemantic => 'Retry analyzing the photo';

  @override
  String analyzerTagSemantic(String tag, String confidence) {
    return 'Tag: $tag, $confidence confidence';
  }

  @override
  String analyzerTagsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tags identified',
      one: '1 tag identified',
      zero: 'No tags identified',
    );
    return '$_temp0';
  }

  @override
  String get errorDialogTitle => 'Notice';

  @override
  String get errorDialogDismiss => 'Dismiss';

  @override
  String get statusError => 'Error';

  @override
  String get analyzerErrorNetwork =>
      'Unable to analyze image. Please check your internet connection and try again.';

  @override
  String get analyzerErrorGeneric =>
      'Unable to recognize the scene. Please hold the camera steady and tap Retry.';

  @override
  String get analyzerErrorApiKey =>
      'Vision recognition service is currently unavailable. Please tap Retry or try again in a moment.';

  @override
  String failedToCapturePhoto(String error) {
    return 'Failed to capture photo: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSetting => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी (Hindi)';

  @override
  String get englishLanguageSubtitle => 'Default language';

  @override
  String get hindiLanguageSubtitle => 'National language of India';

  @override
  String get selectEnglishSemantic => 'English, tap to select English';

  @override
  String get selectHindiSemantic => 'Hindi, tap to select Hindi';

  @override
  String get themeSetting => 'Theme Mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String themeModeSelect(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'system': 'System Default',
      'light': 'Light',
      'dark': 'Dark',
      'other': 'System Default',
    });
    return '$_temp0';
  }

  @override
  String get profileSection => 'User Profile';

  @override
  String get profileDialogSemantic => 'Profile Section';

  @override
  String get closeButton => 'Close';

  @override
  String get anonymousUser => 'Guest User';

  @override
  String get notSignedIn => 'Not signed in';

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
  String get clickToStart => 'Click to start';

  @override
  String get detectorCardSemantic =>
      'Live Object Detector: Point your camera to detect and hear objects around you in real time. Click to start.';

  @override
  String get analyzerCardSemantic =>
      'AI Image Analyzer: Take or choose a photo to hear a detailed description of the scene. Click to start.';

  @override
  String get emailNotProvided => 'No email provided';

  @override
  String get loginHeaderSemantic => 'Vision Companion logo';

  @override
  String get passwordVisibilityToggleSemantic => 'Toggle password visibility';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get signUpSubtitle =>
      'Join Vision Companion for assistive vision support';

  @override
  String get signUpButton => 'Create Account';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get switchToSignUpSemantic => 'Switch to Sign Up form';

  @override
  String get switchToSignInSemantic => 'Switch to Sign In form';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account already exists with this email address.';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak. Please use at least 6 characters.';

  @override
  String get splashTitle => 'Vision Companion';

  @override
  String get splashSubtitle => 'AI Assistive Companion';

  @override
  String get splashWelcomeText =>
      'Welcome! Please choose your preferred language to continue.';

  @override
  String get selectLanguagePrompt => 'Choose Language / भाषा चुनें';

  @override
  String get continueButton => 'Continue';

  @override
  String get continueButtonSemantic => 'Continue to application';

  @override
  String languageSelectedSemantic(String language) {
    return '$language selected';
  }

  @override
  String get accountStatusLabel => 'Account Status';

  @override
  String get signedInStatus => 'Signed In';

  @override
  String get guestStatus => 'Guest Mode';

  @override
  String get userIdLabel => 'User ID';

  @override
  String get aboutSectionTitle => 'About';

  @override
  String get appVersionLabel => 'Version 1.0.0';

  @override
  String get crashReportingActive => 'Crash reporting active';
}
