class AppConstants {
  AppConstants._();

  static const String appName = 'Vision Companion';

  // Navigation Routes
  static const String routeSplash = '/splash';
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeDetector = '/detector';
  static const String routeAnalyzer = '/analyzer';
  static const String routeSettings = '/settings';

  // SharedPreferences Keys
  static const String prefLanguageCode = 'pref_language_code';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefHasSelectedLanguage = 'pref_has_selected_language';

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeHi = 'hi';

  // Feature Types for History Logging
  static const String featureTypeDetector = 'detector';
  static const String featureTypeAnalyzer = 'analyzer';
  static const int maxHistoryEntries = 20;

  // OAuth / Google Sign-In
  static const String googleServerClientId =
      '736888497416-s2fblaetmvrm3lma45a1sf5bh9pb0mjp.apps.googleusercontent.com';

  // Environment Variable Keys
  static const String envGeminiApiKey = 'GEMINI_API_KEY';
}
