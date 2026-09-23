import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/settings/widgets/language_selector_tile.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final AnalyticsService? analyticsService;

  const SettingsPage({
    super.key,
    this.analyticsService,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AnalyticsService? _analyticsService;

  @override
  void initState() {
    super.initState();
    _analyticsService = widget.analyticsService ??
        (sl.isRegistered<AnalyticsService>() ? sl<AnalyticsService>() : null);
    _analyticsService?.logFeatureOpened('settings');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            l10n.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section Header
          Semantics(
            header: true,
            child: Text(
              l10n.profileSection,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Profile Info Card
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String name = l10n.anonymousUser;
              String email = l10n.notSignedIn;
              bool isAuthenticated = authState is Authenticated;
              String? uid;

              if (authState is Authenticated) {
                name = authState.displayName ?? l10n.anonymousUser;
                email = authState.email ?? l10n.emailNotProvided;
                uid = authState.uid;
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User identity row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primary.withAlpha(30),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Account Status and Action row
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAuthenticated
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isAuthenticated
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAuthenticated
                                      ? Icons.check_circle_rounded
                                      : Icons.account_circle_outlined,
                                  size: 16,
                                  color: isAuthenticated
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isAuthenticated
                                      ? l10n.signedInStatus
                                      : l10n.guestStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAuthenticated
                                        ? Colors.green.shade800
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Sign In / Sign Out Button with >= 48dp touch target
                          if (isAuthenticated)
                            Semantics(
                              button: true,
                              label: l10n.signOutButton,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                child: TextButton.icon(
                                  onPressed: () {
                                    context.read<AuthCubit>().signOut();
                                    context.go(AppConstants.routeLogin);
                                  },
                                  icon: const Icon(Icons.logout_rounded, size: 20),
                                  label: Text(l10n.signOutButton),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            )
                          else
                            Semantics(
                              button: true,
                              label: l10n.signInButton,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                child: ElevatedButton.icon(
                                  onPressed: () => context.push(AppConstants.routeLogin),
                                  icon: const Icon(Icons.login_rounded, size: 20),
                                  label: Text(l10n.signInButton),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // User UID display (if signed in)
                      if (isAuthenticated && uid != null) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          label: '${l10n.userIdLabel}: $uid',
                          child: Text(
                            '${l10n.userIdLabel}: ${uid.length > 12 ? "${uid.substring(0, 10)}..." : uid}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Language Section Header
          Semantics(
            header: true,
            child: Text(
              l10n.languageSetting,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const LanguageSelectorTile(),
          const SizedBox(height: 24),

          // About Section Header
          Semantics(
            header: true,
            child: Text(
              l10n.aboutSectionTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // About / Crashlytics Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.appVersionLabel} • ${l10n.crashReportingActive}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
