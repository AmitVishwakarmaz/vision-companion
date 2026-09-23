import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/widgets/language_toggle_button.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/features/settings/widgets/language_selector_tile.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Text(
            l10n.profileSection,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String name = l10n.anonymousUser;
              String email = 'Not signed in';

              if (authState is Authenticated) {
                name = authState.displayName ?? 'User';
                email = authState.email ?? 'No email provided';
              }

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withAlpha(30),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(email),
                  trailing: authState is Authenticated
                      ? IconButton(
                          icon: const Icon(Icons.logout_rounded),
                          tooltip: l10n.signOutButton,
                          onPressed: () {
                            context.read<AuthCubit>().signOut();
                            context.go(AppConstants.routeLogin);
                          },
                        )
                      : TextButton(
                          onPressed: () => context.push(AppConstants.routeLogin),
                          child: Text(l10n.signInButton),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Language Section
          Text(
            l10n.languageSetting,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const LanguageSelectorTile(),
          const SizedBox(height: 24),

          // Theme Section
          Text(
            l10n.themeSetting,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.themeSetting,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownButton<ThemeMode>(
                        value: settingsState.themeMode,
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(l10n.themeSystem),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(l10n.themeLight),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(l10n.themeDark),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            context.read<SettingsCubit>().setThemeMode(mode);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
