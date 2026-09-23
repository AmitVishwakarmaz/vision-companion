import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/features/settings/pages/settings_page.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit([AuthState? initial]) : super(initial ?? const Unauthenticated());

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signUpWithEmail(String email, String password, {String? displayName}) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings & Localization Persistence Tests', () {
    test('SettingsCubit persists language and restores selected language after restart', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // 1. Initial cubit defaults to English
      final cubit1 = SettingsCubit(prefs: prefs);
      expect(cubit1.state.locale.languageCode, equals(AppConstants.localeEn));
      expect(cubit1.hasSelectedLanguage, isFalse);

      // 2. Select Hindi
      await cubit1.setLocale(const Locale(AppConstants.localeHi));
      expect(cubit1.state.locale.languageCode, equals(AppConstants.localeHi));
      expect(prefs.getString(AppConstants.prefLanguageCode), equals(AppConstants.localeHi));
      expect(cubit1.hasSelectedLanguage, isTrue);

      // 3. Recreate cubit (simulating app restart)
      final cubit2 = SettingsCubit(prefs: prefs);
      expect(cubit2.state.locale.languageCode, equals(AppConstants.localeHi));
      expect(cubit2.hasSelectedLanguage, isTrue);

      // 4. Toggle back to English
      await cubit2.toggleLanguage();
      expect(cubit2.state.locale.languageCode, equals(AppConstants.localeEn));
      expect(prefs.getString(AppConstants.prefLanguageCode), equals(AppConstants.localeEn));
    });
  });

  group('ICU Plural and Select Syntax Tests', () {
    testWidgets('ICU Plural formats object counts correctly in English and Hindi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l10nEn = AppLocalizations.of(context)!;
              expect(l10nEn.detectorObjectsCount(0), equals('No objects detected'));
              expect(l10nEn.detectorObjectsCount(1), equals('1 object detected'));
              expect(l10nEn.detectorObjectsCount(4), equals('4 objects detected'));
              expect(l10nEn.themeModeSelect('light'), equals('Light'));
              expect(l10nEn.themeModeSelect('dark'), equals('Dark'));
              expect(l10nEn.themeModeSelect('system'), equals('System Default'));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('hi'),
          home: Builder(
            builder: (context) {
              final l10nHi = AppLocalizations.of(context)!;
              expect(l10nHi.detectorObjectsCount(0), equals('कोई वस्तु संसूचित नहीं'));
              expect(l10nHi.detectorObjectsCount(1), equals('1 वस्तु संसूचित'));
              expect(l10nHi.detectorObjectsCount(4), equals('4 वस्तुएं संसूचित'));
              expect(l10nHi.themeModeSelect('light'), equals('लाइट'));
              expect(l10nHi.themeModeSelect('dark'), equals('डार्क'));
              expect(l10nHi.themeModeSelect('system'), equals('सिस्टम डिफ़ॉल्ट'));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  group('SettingsPage & LanguageSelectorTile Widget Tests', () {
    late SharedPreferences prefs;
    late SettingsCubit settingsCubit;
    late MockAuthCubit authCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsCubit = SettingsCubit(prefs: prefs);
      authCubit = MockAuthCubit();
    });

    Widget buildTestWidget({Locale locale = const Locale('en')}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              locale: state.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SettingsPage(),
            );
          },
        ),
      );
    }

    testWidgets('Renders accessible LanguageSelectorTile with minimum 48x48 tap targets', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify title and language section
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsWidgets);
      expect(find.text('English'), findsWidgets);
      expect(find.text('हिन्दी (Hindi)'), findsOneWidget);

      // Verify touch targets for language option items >= 48dp
      final englishCard = tester.getRect(find.widgetWithText(InkWell, 'English'));
      expect(englishCard.height, greaterThanOrEqualTo(48.0));

      final hindiCard = tester.getRect(find.widgetWithText(InkWell, 'हिन्दी (Hindi)'));
      expect(hindiCard.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Tapping Hindi updates language dynamically and reflects complete Hindi UI without English fallback', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Hindi option
      await tester.tap(find.text('हिन्दी (Hindi)'));
      await tester.pumpAndSettle();

      // Verify cubit state changed
      expect(settingsCubit.state.locale.languageCode, equals('hi'));
      expect(prefs.getString(AppConstants.prefLanguageCode), equals('hi'));

      // Verify complete Hindi strings in UI
      expect(find.text('सेटिंग्स'), findsOneWidget);
      expect(find.text('भाषा'), findsWidgets);
      expect(find.text('उपयोगकर्ता प्रोफ़ाइल'), findsOneWidget);
      expect(find.text('अतिथि उपयोगकर्ता'), findsOneWidget);
      expect(find.text('साइन इन नहीं किया गया'), findsOneWidget);
    });
  });
}
