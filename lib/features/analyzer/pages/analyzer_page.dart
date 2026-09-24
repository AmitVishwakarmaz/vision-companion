import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class AnalyzerPage extends StatefulWidget {
  const AnalyzerPage({super.key});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraErrorMessage;
  final FocusNode _resultFocusNode = FocusNode();
  final FocusNode _errorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AnalyzerCubit>().init();
      }
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraErrorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      final rearCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        rearCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      final oldController = _cameraController;
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _cameraErrorMessage = null;
        });
      }
      oldController?.dispose();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorMessage = 'Camera unavailable: $e';
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      final controller = _cameraController;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _cameraController = null;
        });
      }
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (mounted && (_cameraController == null || !_cameraController!.value.isInitialized)) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _resultFocusNode.dispose();
    _errorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (context.read<AnalyzerCubit>().state is AnalyzerProcessing) return;
    HapticFeedback.selectionClick().catchError((_) {});
    final cubit = context.read<AnalyzerCubit>();
    final langCode = Localizations.localeOf(context).languageCode;

    final l10n = AppLocalizations.of(context)!;

    // After capture announce: "Analyzing image, please wait"
    // ignore: deprecated_member_use
    SemanticsService.announce(l10n.analyzingImagePleaseWait, Directionality.of(context));

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        if (!mounted) return;
        await cubit.analyzeImage(photo.path, languageCode: langCode);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToCapturePhoto(e.toString()))),
        );
      }
    } else {
      // Fallback for emulators/environments without camera hardware
      await cubit.analyzeImage('placeholder_camera_image.jpg', languageCode: langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.analyzerScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: BlocConsumer<AnalyzerCubit, AnalyzerState>(
        listener: (context, state) {
          if (state is AnalyzerProcessing) {
            // TalkBack announcement when processing begins
            // ignore: deprecated_member_use
            SemanticsService.announce(l10n.processingAnnouncement, Directionality.of(context));
          } else if (state is AnalyzerError) {
            HapticFeedback.heavyImpact().catchError((_) {});
            final localizedMsg = state.getLocalizedMessage(l10n);
            final direction = Directionality.of(context);
            final announcement =
                '${l10n.errorDialogTitle}: $localizedMsg. ${l10n.retryButton} or ${l10n.captureAnotherButton}.';
            // Settle post-frame, request focus on error node, and announce cleanly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _errorFocusNode.requestFocus();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                // ignore: deprecated_member_use
                SemanticsService.announce(announcement, direction);
              });
            });
          } else if (state is AnalyzerResult) {
            HapticFeedback.lightImpact().catchError((_) {});
            final direction = Directionality.of(context);
            final tagsText = state.data.tags.isNotEmpty
                ? ' ${state.data.tags.map((t) => l10n.analyzerTagSemantic(t.label, t.formattedConfidence)).join('. ')}.'
                : '';
            final announcement =
                '${l10n.analysisResultTitle}: ${state.description}.$tagsText ${l10n.captureAnotherButton}.';
            // Settle post-frame, request focus on result node, and announce full description + action
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _resultFocusNode.requestFocus();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                // ignore: deprecated_member_use
                SemanticsService.announce(announcement, direction);
              });
            });
          }
        },
        builder: (context, state) {
          final isProcessing = state is AnalyzerProcessing;
          final isResult = state is AnalyzerResult;
          final isError = state is AnalyzerError;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Viewport Container: Camera / Processing / Result / Error
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 1. Live Camera Preview (when idle and camera available)
                          if (!isResult &&
                              !isError &&
                              _isCameraInitialized &&
                              _cameraController != null &&
                              _cameraController!.value.isInitialized)
                            Semantics(
                              label: l10n.analyzerCameraFeedSemantic,
                              child: KeyedSubtree(
                                key: ValueKey(_cameraController),
                                child: CameraPreview(_cameraController!),
                              ),
                            ),

                          // 2. Uninitialized / Error Camera Placeholder
                          if (!isResult && !isError && (!_isCameraInitialized || _cameraController == null))
                            Container(
                              color: Colors.black87,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 48,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _cameraErrorMessage ?? l10n.analyzerCameraFeedSemantic,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // 3. Spinning Progress Indicator while Processing
                          if (isProcessing)
                            Semantics(
                              container: true,
                              liveRegion: true,
                              label: l10n.processingSemanticLabel,
                              child: Container(
                                color: Colors.black.withAlpha(200),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 3.5,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        l10n.analyzingProgress,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // 4. Analysis Result Display
                          if (isResult)
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Optional thumbnail preview if local image file exists
                                  if (File(state.data.imagePath).existsSync())
                                    ExcludeSemantics(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          height: 160,
                                          width: double.infinity,
                                          child: Image.file(
                                            File(state.data.imagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),

                                  // Header with Model Badge & full description in semantics
                                  Focus(
                                    focusNode: _resultFocusNode,
                                    child: Semantics(
                                      header: true,
                                      liveRegion: true,
                                      label: '${l10n.analysisResultTitle}: ${state.data.description}',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.analysisResultTitle,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Scrollable AI Description (visual presentation)
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: ExcludeSemantics(
                                        child: Text(
                                          state.data.description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Result Chips (Tags with confidence, e.g. "Tag: cat, 94% confidence")
                                  if (state.data.tags.isNotEmpty) ...[
                                    const Divider(height: 16, thickness: 1),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: state.data.tags.map((tag) {
                                        return Semantics(
                                          label: l10n.analyzerTagSemantic(tag.label, tag.formattedConfidence),
                                          child: Chip(
                                            backgroundColor: Colors.grey.shade100,
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              side: const BorderSide(color: Colors.black12),
                                            ),
                                            avatar: const Icon(
                                              Icons.label_outline_rounded,
                                              size: 16,
                                              color: Colors.black87,
                                            ),
                                            label: Text(
                                              '${tag.label} • ${tag.formattedConfidence}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          // 5. Friendly Error Display (No Raw Stack Traces, Screen Reader Live Region)
                          if (isError)
                            Focus(
                              focusNode: _errorFocusNode,
                              child: Semantics(
                                container: true,
                                liveRegion: true,
                                label: '${l10n.errorDialogTitle}: ${state.getLocalizedMessage(l10n)}',
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          size: 56,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          state.getLocalizedMessage(l10n),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Controls Section
                if (isError)
                  // Error Controls: Retry and Take Another Photo
                  Row(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Semantics(
                            button: true,
                            label: l10n.retryButtonSemantic,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: Text(
                                l10n.retryButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick().catchError((_) {});
                                context.read<AnalyzerCubit>().retry(languageCode: langCode);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Semantics(
                            button: true,
                            label: l10n.captureAnotherButton,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.black, width: 1.5),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick().catchError((_) {});
                                context.read<AnalyzerCubit>().reset();
                              },
                              label: Text(
                                l10n.captureAnotherButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (isResult)
                  // Result Controls: Take Another Photo
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Semantics(
                      button: true,
                      label: l10n.captureAnotherButton,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                        label: Text(
                          l10n.captureAnotherButton,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick().catchError((_) {});
                          context.read<AnalyzerCubit>().reset();
                        },
                      ),
                    ),
                  )
                else
                  // Idle & Processing Controls: Capture Button (Disabled while processing)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Semantics(
                      button: true,
                      enabled: !isProcessing,
                      label: l10n.captureButtonSemantic,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text(
                          l10n.captureImageButton,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isProcessing ? Colors.grey : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // Explicit requirement: Disable camera/capture button during processing
                        onPressed: isProcessing ? null : _captureAndAnalyze,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
