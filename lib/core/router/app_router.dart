import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/pages/analyzer_page.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/auth/pages/login_page.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/pages/detector_page.dart';
import 'package:vision_companion/features/home/home_screen.dart';
import 'package:vision_companion/features/settings/pages/settings_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static GoRouter? _router;

  static GoRouter get router => _router ??= createRouter(sl<AuthCubit>());

  static void reset() {
    _router = null;
  }

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: AppConstants.routeHome,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final bool isAuthenticated = authState is Authenticated;
        final bool isGoingToLogin = state.matchedLocation == AppConstants.routeLogin;

        // Unauthenticated users trying to access protected routes -> redirect to login
        if (!isAuthenticated && !isGoingToLogin) {
          return AppConstants.routeLogin;
        }

        // Authenticated users trying to access login -> redirect to home
        if (isAuthenticated && isGoingToLogin) {
          return AppConstants.routeHome;
        }

        return null;
      },
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
}
