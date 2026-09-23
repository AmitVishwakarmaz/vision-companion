import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/widgets/language_toggle_button.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class DetectorPage extends StatelessWidget {
  const DetectorPage({super.key});

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
          l10n.detectorScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: LanguageToggleButton(),
          ),
        ],
      ),
      body: BlocBuilder<DetectorCubit, DetectorState>(
        builder: (context, state) {
          final isRunning = state is DetectorRunning;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Camera Feed Viewport Placeholder
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRunning
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withAlpha(80),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isRunning
                                  ? Icons.camera_rounded
                                  : Icons.videocam_outlined,
                              size: 64,
                              color: isRunning
                                  ? theme.colorScheme.primary
                                  : Colors.white54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.detectorPlaceholderMessage,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            if (isRunning) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(50),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                child: Text(
                                  'Live Inference Active',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Controls
                ElevatedButton.icon(
                  icon: Icon(
                    isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    isRunning ? l10n.stopDetection : l10n.startDetection,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    final cubit = context.read<DetectorCubit>();
                    if (isRunning) {
                      cubit.stopDetection();
                    } else {
                      cubit.startDetection();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
