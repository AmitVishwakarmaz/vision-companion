import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/core/router/app_router.dart';
import 'package:vision_companion/core/theme/app_theme.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/firebase_options.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Optional .env configuration not loaded or empty: $e');
  }

  // Initialize Firebase across supported platforms
  try {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize Dependency Injection
  await initDependencies();

  runApp(const VisionCompanionApp());
}

class VisionCompanionApp extends StatelessWidget {
  const VisionCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => sl<SettingsCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,
            locale: settingsState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
