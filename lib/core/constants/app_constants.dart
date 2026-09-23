class AppConstants {
  AppConstants._();

  static const String appName = 'Vision Companion';

  // Navigation Routes
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeDetector = '/detector';
  static const String routeAnalyzer = '/analyzer';
  static const String routeSettings = '/settings';

  // SharedPreferences Keys
  static const String prefLanguageCode = 'pref_language_code';
  static const String prefThemeMode = 'pref_theme_mode';

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeHi = 'hi';

  // Environment Variable Keys
  static const String envGeminiApiKey = 'GEMINI_API_KEY';
}
