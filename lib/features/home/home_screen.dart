import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showProfileBottomSheet(BuildContext context, String displayName, String email) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Row with Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.profileMenuTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Semantics(
                      label: l10n.profileMenuClose,
                      button: true,
                      child: IconButton(
                        iconSize: 24,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile Info Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primary.withAlpha(40),
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email.isNotEmpty ? email : l10n.emailNotProvided,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out Button
                Semantics(
                  button: true,
                  label: l10n.signOutButton,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        l10n.signOutButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        context.read<AuthCubit>().signOut();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String displayName = l10n.anonymousUser;
        String email = '';

        if (authState is Authenticated) {
          if (authState.displayName != null && authState.displayName!.isNotEmpty) {
            displayName = authState.displayName!;
          } else if (authState.email != null && authState.email!.isNotEmpty) {
            displayName = authState.email!.split('@').first;
          }
          email = authState.email ?? '';
        }

        final profileSemantic = l10n.profileSemanticLabel(displayName);

        return Scaffold(
          appBar: AppBar(
            title: Semantics(
              header: true,
              child: Text(l10n.appTitle),
            ),
            actions: [
              // Profile Avatar Button
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Semantics(
                  label: profileSemantic,
                  button: true,
                  child: InkWell(
                    onTap: () => _showProfileBottomSheet(context, displayName, email),
                    borderRadius: BorderRadius.circular(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      child: Center(
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary.withAlpha(35),
                          child: Icon(
                            Icons.person_rounded,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Welcome Greeting Card
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
                      Semantics(
                        header: true,
                        child: Text(
                          authState is Authenticated
                              ? l10n.greetingWithName(displayName)
                              : l10n.welcomeMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

                // Exactly Two Feature Cards:
                // Feature 1: Live Object Detector
                _HomeFeatureCard(
                  title: l10n.featureDetectorTitle,
                  description: l10n.featureDetectorDesc,
                  semanticLabel: l10n.detectorCardSemantic,
                  buttonLabel: '${l10n.startFeatureButton} ${l10n.featureDetectorTitle}',
                  icon: Icons.camera_alt_rounded,
                  color: theme.colorScheme.primary,
                  onTap: () => context.push(AppConstants.routeDetector),
                ),
                const SizedBox(height: 20),

                // Feature 2: AI Image Analyzer
                _HomeFeatureCard(
                  title: l10n.featureAnalyzerTitle,
                  description: l10n.featureAnalyzerDesc,
                  semanticLabel: l10n.analyzerCardSemantic,
                  buttonLabel: '${l10n.startFeatureButton} ${l10n.featureAnalyzerTitle}',
                  icon: Icons.auto_awesome_rounded,
                  color: theme.colorScheme.secondary,
                  onTap: () => context.push(AppConstants.routeAnalyzer),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String semanticLabel;
  final String buttonLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeFeatureCard({
    required this.title,
    required this.description,
    required this.semanticLabel,
    required this.buttonLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: color.withAlpha(60),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon badge + Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Start Button with minimum 48x48 dp touch target
                Semantics(
                  button: true,
                  label: buttonLabel,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(
                        l10n.startFeatureButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: onTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
