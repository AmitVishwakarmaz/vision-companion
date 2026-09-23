import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsCubit? cubit;
    try {
      cubit = context.read<SettingsCubit>();
    } catch (_) {
      if (sl.isRegistered<SettingsCubit>()) {
        cubit = sl<SettingsCubit>();
      }
    }

    if (cubit == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: cubit,
      builder: (context, state) {
        final isEnglish = state.locale.languageCode == AppConstants.localeEn;
        final currentCode = isEnglish ? 'EN' : 'हिन्दी';
        final semanticLabel = isEnglish
            ? 'Switch language to Hindi. Currently English'
            : 'भाषा अंग्रेजी में बदलें। वर्तमान में हिन्दी';

        return Semantics(
          button: true,
          label: semanticLabel,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                final view = View.of(context);
                await cubit!.toggleLanguage();
                final newLang = isEnglish ? 'Hindi' : 'English';
                SemanticsService.sendAnnouncement(view, 'Language changed to $newLang', TextDirection.ltr);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language_rounded,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
