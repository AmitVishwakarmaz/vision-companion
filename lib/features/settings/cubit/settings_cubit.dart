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
          themeMode: ThemeMode.system,
        )) {
    _loadPreferences();
  }

  void _loadPreferences() {
    if (prefs == null) return;

    final langCode = prefs!.getString(AppConstants.prefLanguageCode) ?? AppConstants.localeEn;
    final themeName = prefs!.getString(AppConstants.prefThemeMode);

    ThemeMode loadedMode = ThemeMode.system;
    if (themeName == ThemeMode.light.name) {
      loadedMode = ThemeMode.light;
    } else if (themeName == ThemeMode.dark.name) {
      loadedMode = ThemeMode.dark;
    }

    emit(SettingsState(
      locale: Locale(langCode),
      themeMode: loadedMode,
    ));
  }

  Future<void> setLocale(Locale newLocale) async {
    emit(state.copyWith(locale: newLocale));
    await prefs?.setString(AppConstants.prefLanguageCode, newLocale.languageCode);
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
