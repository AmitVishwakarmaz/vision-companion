import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isHindi = state.locale.languageCode == AppConstants.localeHi;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.languageSetting,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isHindi ? l10n.languageHindi : l10n.languageEnglish,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: AppConstants.localeEn,
                      label: Text('EN'),
                    ),
                    ButtonSegment<String>(
                      value: AppConstants.localeHi,
                      label: Text('HI'),
                    ),
                  ],
                  selected: {state.locale.languageCode},
                  onSelectionChanged: (newSelection) {
                    final selectedCode = newSelection.first;
                    context.read<SettingsCubit>().setLocale(Locale(selectedCode));
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
