import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppConstants.routeSettings),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      String greeting = l10n.welcomeMessage;
                      if (authState is Authenticated &&
                          authState.displayName != null &&
                          authState.displayName!.isNotEmpty) {
                        greeting = 'Hello, ${authState.displayName}!';
                      }
                      return Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subtitleAssistive,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Feature 1: TFLite Real-time Detection
            _FeatureCard(
              title: l10n.featureDetectorTitle,
              description: l10n.featureDetectorDesc,
              icon: Icons.camera_alt_rounded,
              color: theme.colorScheme.primary,
              onTap: () => context.push(AppConstants.routeDetector),
            ),
            const SizedBox(height: 16),

            // Feature 2: AI Scene & Image Analyzer
            _FeatureCard(
              title: l10n.featureAnalyzerTitle,
              description: l10n.featureAnalyzerDesc,
              icon: Icons.auto_awesome_rounded,
              color: theme.colorScheme.secondary,
              onTap: () => context.push(AppConstants.routeAnalyzer),
            ),
            const SizedBox(height: 16),

            // Feature 3: Settings & Preferences
            _FeatureCard(
              title: l10n.featureSettingsTitle,
              description: l10n.featureSettingsDesc,
              icon: Icons.tune_rounded,
              color: theme.colorScheme.tertiary,
              onTap: () => context.push(AppConstants.routeSettings),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
