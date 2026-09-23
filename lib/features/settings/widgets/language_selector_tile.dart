import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  void _onLanguageSelected(BuildContext context, String code, AppLocalizations l10n) {
    HapticFeedback.selectionClick().catchError((_) {});
    context.read<SettingsCubit>().setLocale(Locale(code));

    final langName = code == AppConstants.localeHi
        ? l10n.languageHindi
        : l10n.languageEnglish;
    final announcement = l10n.languageSelectedSemantic(langName);

    // Announce to TalkBack screen reader
    // ignore: deprecated_member_use
    SemanticsService.announce(announcement, Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;
        final isEnglish = currentCode == AppConstants.localeEn;
        final isHindi = currentCode == AppConstants.localeHi;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon and current language
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.translate_rounded,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageSetting,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isHindi ? l10n.languageHindi : l10n.languageEnglish,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(160),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // English Option Tile (Meets 48x48 tap target constraints)
                _LanguageOptionItem(
                  title: l10n.languageEnglish,
                  subtitle: l10n.englishLanguageSubtitle,
                  isSelected: isEnglish,
                  semanticLabel: isEnglish
                      ? l10n.languageSelectedSemantic(l10n.languageEnglish)
                      : l10n.selectEnglishSemantic,
                  onTap: () => _onLanguageSelected(context, AppConstants.localeEn, l10n),
                ),
                const SizedBox(height: 10),

                // Hindi Option Tile (Meets 48x48 tap target constraints)
                _LanguageOptionItem(
                  title: l10n.languageHindi,
                  subtitle: l10n.hindiLanguageSubtitle,
                  isSelected: isHindi,
                  semanticLabel: isHindi
                      ? l10n.languageSelectedSemantic(l10n.languageHindi)
                      : l10n.selectHindiSemantic,
                  onTap: () => _onLanguageSelected(context, AppConstants.localeHi, l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOptionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  const _LanguageOptionItem({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(20)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? theme.colorScheme.primary : Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                          color: isSelected ? theme.colorScheme.primary : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
