import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/services/detector_service.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies({
  SharedPreferences? sharedPreferences,
  FirebaseAuth? firebaseAuth,
  FirebaseFirestore? firestore,
  GoogleSignIn? googleSignIn,
  AuthRepository? authRepository,
  HistoryRepository? historyRepository,
  DetectorService? detectorService,
  AnalyticsService? analyticsService,
}) async {
  // External: SharedPreferences
  final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // External: Firebase
  FirebaseAuth? auth = firebaseAuth;
  if (auth == null) {
    try {
      auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint('FirebaseAuth not available or not initialized: $e');
    }
  }
  if (auth != null) {
    sl.registerLazySingleton<FirebaseAuth>(() => auth!);
  }

  FirebaseFirestore? db = firestore;
  if (db == null) {
    try {
      db = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('FirebaseFirestore not available or not initialized: $e');
    }
  }
  if (db != null) {
    sl.registerLazySingleton<FirebaseFirestore>(() => db!);
  }

  // External: GoogleSignIn
  final google = googleSignIn ?? GoogleSignIn.instance;
  if (googleSignIn == null) {
    try {
      await google
          .initialize(serverClientId: AppConstants.googleServerClientId)
          .catchError((_) {});
    } catch (_) {}
  }
  sl.registerLazySingleton<GoogleSignIn>(() => google);

  // Repositories
  final repository = authRepository ??
      FirebaseAuthRepository(
        firebaseAuth: sl.isRegistered<FirebaseAuth>() ? sl<FirebaseAuth>() : null,
        googleSignIn: sl<GoogleSignIn>(),
      );
  sl.registerLazySingleton<AuthRepository>(() => repository);

  final history = historyRepository ??
      FirestoreHistoryRepository(
        firestore: sl.isRegistered<FirebaseFirestore>() ? sl<FirebaseFirestore>() : null,
        firebaseAuth: sl.isRegistered<FirebaseAuth>() ? sl<FirebaseAuth>() : null,
      );
  sl.registerLazySingleton<HistoryRepository>(() => history);

  // Analytics Service
  final analytics = analyticsService ?? FirebaseAnalyticsService();
  sl.registerLazySingleton<AnalyticsService>(() => analytics);

  // Detector Service
  final detector = detectorService ?? LiveDetectorService();
  sl.registerLazySingleton<DetectorService>(() => detector);

  // Feature Cubits
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(prefs: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<DetectorCubit>(
    () => DetectorCubit(
      detectorService: sl<DetectorService>(),
      historyRepository: sl<HistoryRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
  );

  sl.registerFactory<AnalyzerCubit>(
    () => AnalyzerCubit(historyRepository: sl<HistoryRepository>()),
  );
}
