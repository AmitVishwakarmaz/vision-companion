import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/pages/analyzer_page.dart';
import 'package:vision_companion/features/auth/pages/login_page.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/pages/detector_page.dart';
import 'package:vision_companion/features/home/home_screen.dart';
import 'package:vision_companion/features/settings/pages/settings_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeHome,
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeDetector,
        builder: (context, state) => BlocProvider<DetectorCubit>(
          create: (_) => sl<DetectorCubit>(),
          child: const DetectorPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeAnalyzer,
        builder: (context, state) => BlocProvider<AnalyzerCubit>(
          create: (_) => sl<AnalyzerCubit>(),
          child: const AnalyzerPage(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page not found: ${state.uri.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
