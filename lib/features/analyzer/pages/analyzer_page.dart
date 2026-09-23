import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class AnalyzerPage extends StatelessWidget {
  const AnalyzerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyzerScreenTitle),
      ),
      body: BlocConsumer<AnalyzerCubit, AnalyzerState>(
        listener: (context, state) {
          if (state is AnalyzerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AnalyzerLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(60),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Analyzing with AI...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : state is AnalyzerSuccess
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 48,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        state.description,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_search_rounded,
                                      size: 64,
                                      color: theme.colorScheme.primary.withAlpha(180),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.analyzerPlaceholderMessage,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withAlpha(160),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l10n.pickImageButton),
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AnalyzerCubit>()
                                .analyzeImage('placeholder_gallery_image.jpg'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(l10n.captureImageButton),
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AnalyzerCubit>()
                                .analyzeImage('placeholder_camera_image.jpg'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
