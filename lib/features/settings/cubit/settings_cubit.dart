import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences? prefs;

  SettingsCubit({this.prefs})
      : super(const SettingsState(
          locale: Locale(AppConstants.localeEn),
          themeMode: ThemeMode.light,
        )) {
    _loadPreferences();
  }

  bool get hasSelectedLanguage =>
      prefs?.getBool(AppConstants.prefHasSelectedLanguage) ?? false;

  void _loadPreferences() {
    if (prefs == null) return;

    final langCode = prefs!.getString(AppConstants.prefLanguageCode) ?? AppConstants.localeEn;
    final themeName = prefs!.getString(AppConstants.prefThemeMode);
    final themeMode = themeName != null
        ? ThemeMode.values.firstWhere((t) => t.name == themeName, orElse: () => ThemeMode.light)
        : ThemeMode.light;

    emit(SettingsState(
      locale: Locale(langCode),
      themeMode: themeMode,
    ));
  }

  Future<void> confirmLanguageSelection() async {
    await prefs?.setBool(AppConstants.prefHasSelectedLanguage, true);
  }

  Future<void> setLocale(Locale newLocale) async {
    emit(state.copyWith(locale: newLocale));
    await prefs?.setString(AppConstants.prefLanguageCode, newLocale.languageCode);
    await prefs?.setBool(AppConstants.prefHasSelectedLanguage, true);
  }

  Future<void> toggleLanguage() async {
    final nextCode = state.locale.languageCode == AppConstants.localeEn
        ? AppConstants.localeHi
        : AppConstants.localeEn;
    await setLocale(Locale(nextCode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await prefs?.setString(AppConstants.prefThemeMode, mode.name);
  }
}
