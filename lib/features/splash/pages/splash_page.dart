import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void _onContinuePressed(BuildContext context) async {
    await context.read<SettingsCubit>().confirmLanguageSelection();
    if (!context.mounted) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.go(AppConstants.routeHome);
    } else {
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final currentLanguage = settingsState.locale.languageCode;
            final isEnglish = currentLanguage == AppConstants.localeEn;
            final isHindi = currentLanguage == AppConstants.localeHi;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vision Companion App Icon & Brand Badge
                    Center(
                      child: Semantics(
                        label: l10n.loginHeaderSemantic,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(
                            Icons.visibility_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.splashTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // App Subtitle / Tagline
                    Text(
                      l10n.splashSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF424242),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Language Selection Section Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.selectLanguagePrompt,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.splashWelcomeText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Option 1: English
                          _LanguageSelectionCard(
                            title: l10n.languageEnglish,
                            subtitle: l10n.englishLanguageSubtitle,
                            isSelected: isEnglish,
                            semanticLabel: isEnglish
                                ? l10n.languageSelectedSemantic(l10n.languageEnglish)
                                : l10n.selectEnglishSemantic,
                            onTap: () {
                              context
                                  .read<SettingsCubit>()
                                  .setLocale(const Locale(AppConstants.localeEn));
                            },
                          ),
                          const SizedBox(height: 12),

                          // Option 2: Hindi
                          _LanguageSelectionCard(
                            title: l10n.languageHindi,
                            subtitle: l10n.hindiLanguageSubtitle,
                            isSelected: isHindi,
                            semanticLabel: isHindi
                                ? l10n.languageSelectedSemantic(l10n.languageHindi)
                                : l10n.selectHindiSemantic,
                            onTap: () {
                              context
                                  .read<SettingsCubit>()
                                  .setLocale(const Locale(AppConstants.localeHi));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue Button
                    Semantics(
                      button: true,
                      label: l10n.continueButtonSemantic,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: ElevatedButton(
                          onPressed: () => _onContinuePressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.continueButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LanguageSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  const _LanguageSelectionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black,
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon Indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : const Color(0xFFF0F0F0),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.black,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.language_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),

              // Selected indicator badge
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
