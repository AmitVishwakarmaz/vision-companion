import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/widgets/app_logo.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logCardClick({
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
  }) {
    try {
      if (sl.isRegistered<HistoryRepository>()) {
        sl<HistoryRepository>().logHistory(
          featureType: featureType,
          resultSummary: resultSummary,
          metadata: metadata,
        ).catchError((_) => '');
      }
    } catch (_) {}
  }

  void _showProfileBottomSheet(BuildContext context, String displayName, String email) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Announce Profile Section so TalkBack speaks "Profile Section" rather than "dialog"
    // ignore: deprecated_member_use
    SemanticsService.announce(l10n.profileDialogSemantic, Directionality.of(context));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierLabel: l10n.profileDialogSemantic,
      routeSettings: RouteSettings(name: l10n.profileDialogSemantic),
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          label: l10n.profileDialogSemantic,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Drag Handle (Excluded from semantics to avoid barrier noise)
                  ExcludeSemantics(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withAlpha(50),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row with Title & Accessible Close Button
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
                        button: true,
                        label: l10n.closeButton,
                        excludeSemantics: true,
                        child: IconButton(
                          iconSize: 24,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: l10n.closeButton,
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Profile Info Card (Unified semantics so TalkBack speaks name and email cleanly)
                Semantics(
                  container: true,
                  label: '${l10n.profileSection}: $displayName, ${email.isNotEmpty ? email : l10n.emailNotProvided}',
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ExcludeSemantics(
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
                  ),
                ),
                const SizedBox(height: 20),

                // Settings Button
                Semantics(
                  button: true,
                  label: l10n.settingsTitle,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 20),
                      label: Text(
                        l10n.settingsTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        context.push(AppConstants.routeSettings);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(
                  size: 28,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(width: 10),
                Semantics(
                  header: true,
                  child: Text(l10n.appTitle),
                ),
              ],
            ),
            actions: [
              // Settings Button
              Semantics(
                label: l10n.settingsTitle,
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.settingsTitle,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  onPressed: () => context.push(AppConstants.routeSettings),
                ),
              ),
              const SizedBox(width: 4),
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
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
                        style: const TextStyle(
                          color: Color(0xFFE0E0E0),
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
                  actionPrompt: l10n.clickToStart,
                  semanticLabel: l10n.detectorCardSemantic,
                  icon: Icons.camera_alt_rounded,
                  onTap: () {
                    _logCardClick(
                      featureType: AppConstants.featureTypeDetector,
                      resultSummary: 'Live object detection session initiated.',
                      metadata: {
                        'source': 'home_feature_card',
                        'action': 'start_detector',
                      },
                    );
                    context.push(AppConstants.routeDetector);
                  },
                ),
                const SizedBox(height: 20),

                // Feature 2: AI Image Analyzer
                _HomeFeatureCard(
                  title: l10n.featureAnalyzerTitle,
                  description: l10n.featureAnalyzerDesc,
                  actionPrompt: l10n.clickToStart,
                  semanticLabel: l10n.analyzerCardSemantic,
                  icon: Icons.auto_awesome_rounded,
                  onTap: () {
                    _logCardClick(
                      featureType: AppConstants.featureTypeAnalyzer,
                      resultSummary: 'AI Image Analysis feature placeholder ready for API integration.',
                      metadata: {
                        'source': 'home_feature_card',
                        'action': 'open_analyzer',
                        'imagePath': 'placeholder_gallery_image.jpg',
                      },
                    );
                    context.push(AppConstants.routeAnalyzer);
                  },
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
  final String actionPrompt;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeFeatureCard({
    required this.title,
    required this.description,
    required this.actionPrompt,
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Colors.black,
            width: 2,
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
                // Top Row: Icon badge + Title + Arrow indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Simple Description (No TFLite / technical jargon)
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF424242),
                    height: 1.4,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                // Click / Tap To Start Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actionPrompt,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
