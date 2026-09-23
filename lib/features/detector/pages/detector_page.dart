import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/widgets/bounding_box_painter.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class DetectorPage extends StatefulWidget {
  const DetectorPage({super.key});

  @visibleForTesting
  static DateTime Function() nowProvider = DateTime.now;

  @override
  State<DetectorPage> createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraStreaming = false;
  bool _isCameraNotFound = false;
  String? _cameraRawError;
  CameraDescription? _cameraDescription;

  DateTime? _lastAnnouncementTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize model in cubit
    context.read<DetectorCubit>().initialize();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraNotFound = true;
          });
        }
        return;
      }

      // Pick rear back camera by default
      final rearCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraDescription = rearCamera;
      final controller = CameraController(
        rearCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _isCameraNotFound = false;
        _cameraRawError = null;
      });

      // Start stream once camera hardware is initialized
      _startCameraStream();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraRawError = e.toString();
        });
      }
    }
  }

  void _startCameraStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCameraStreaming) {
      return;
    }

    final cubit = context.read<DetectorCubit>();
    cubit.startDetection();

    try {
      _cameraController!.startImageStream((CameraImage image) {
        if (!mounted) return;
        final orientation = _cameraDescription?.sensorOrientation ?? 90;
        cubit.processCameraImage(image, sensorOrientation: orientation);
      });
      _isCameraStreaming = true;
    } catch (e) {
      debugPrint('Error starting camera stream: $e');
    }
  }

  void _stopCameraStream() {
    if (_cameraController != null && _isCameraStreaming) {
      try {
        _cameraController!.stopImageStream();
      } catch (_) {}
      _isCameraStreaming = false;
    }
  }

  /// Announces the top detected object using SemanticsService.announce.
  /// Throttled to at most once every 2 seconds.
  void _announceTopDetection(BuildContext context, List<Detection> detections) {
    if (detections.isEmpty || !mounted) return;

    final now = DetectorPage.nowProvider();
    if (_lastAnnouncementTime != null &&
        now.difference(_lastAnnouncementTime!).inMilliseconds < 2000) {
      return;
    }

    // Determine the top detected object with highest confidence
    final topDetection = detections.reduce(
      (max, d) => d.confidence >= max.confidence ? d : max,
    );

    _lastAnnouncementTime = now;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final langCode = Localizations.localeOf(context).languageCode;
    final localizedLabel = CocoLabels.getLocalizedLabel(topDetection.label, langCode);
    final announcement = l10n.detectedObjectAnnouncement(localizedLabel);

    // ignore: deprecated_member_use
    SemanticsService.announce(announcement, Directionality.of(context));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCameraStream();
      controller.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCameraStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String? cameraDisplayError = _isCameraNotFound
        ? l10n.cameraUnavailable
        : (_cameraRawError != null ? l10n.cameraErrorPrefix(_cameraRawError!) : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.detectorScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: BlocConsumer<DetectorCubit, DetectorState>(
        listener: (context, state) {
          if (state is DetectorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DetectorResults && state.detections.isNotEmpty) {
            _announceTopDetection(context, state.detections);
          }
        },
        builder: (context, state) {
          final isRunning = state is DetectorRunning || state is DetectorResults;
          final isPaused = state is DetectorPaused;
          final isIdle = state is DetectorInitial;

          final List<Detection> detections = state is DetectorResults
              ? state.detections
              : (state is DetectorPaused ? state.lastDetections : const []);
          final int inferenceTimeMs = state is DetectorResults ? state.inferenceTimeMs : 0;

          // Localized Button Text and Semantics Label
          final String buttonLabel = isRunning
              ? l10n.pauseDetection
              : (isPaused ? l10n.resumeDetection : l10n.startDetection);

          // Localized Status Badge Text
          final String statusText;
          if (isRunning) {
            statusText = inferenceTimeMs > 0
                ? l10n.detectorObjectsCountWithLatency(detections.length, inferenceTimeMs)
                : l10n.detectorObjectsCount(detections.length);
          } else if (isPaused) {
            statusText = l10n.detectorPausedWithCount(detections.length);
          } else if (isIdle) {
            statusText = l10n.detectorReadyStatus;
          } else {
            statusText = l10n.statusError;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Camera Viewport with Bounding Box Overlay & Semantics
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
                          if (_isCameraInitialized && _cameraController != null) ...[
                            // 1. Live Camera Preview with Localized Accessibility Label
                            Semantics(
                              label: l10n.cameraFeedSemantic,
                              container: true,
                              child: Center(
                                child: CameraPreview(_cameraController!),
                              ),
                            ),

                            // 2. Real-time Color-Coded Bounding Box Overlay (Exclude semantics to avoid focus traps)
                            ExcludeSemantics(
                              child: CustomPaint(
                                painter: BoundingBoxPainter(
                                  detections: detections,
                                  previewSize: _cameraController!.value.previewSize,
                                  languageCode: Localizations.localeOf(context).languageCode,
                                ),
                              ),
                            ),
                          ] else ...[
                            // Camera Placeholder / Error State
                            Semantics(
                              label: cameraDisplayError ?? l10n.detectorPlaceholderMessage,
                              container: true,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 64,
                                        color: Colors.white54,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        cameraDisplayError ?? l10n.detectorPlaceholderMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // HUD Status Badge (Driven by DetectorState with liveRegion semantics)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Semantics(
                              container: true,
                              liveRegion: true,
                              label: statusText,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(210),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isRunning
                                            ? Colors.greenAccent
                                            : (isPaused ? Colors.amberAccent : Colors.white54),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // State-Driven Controls: Pause / Resume Button with localized Semantics
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Semantics(
                    button: true,
                    enabled: true,
                    label: buttonLabel,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        isRunning
                            ? Icons.pause_rounded
                            : (isPaused ? Icons.play_arrow_rounded : Icons.videocam_rounded),
                        color: isRunning ? Colors.black : Colors.white,
                      ),
                      label: Text(
                        buttonLabel,
                        style: TextStyle(
                          color: isRunning ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? Colors.white : Colors.black,
                        foregroundColor: isRunning ? Colors.black : Colors.white,
                        side: const BorderSide(color: Colors.black, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick().catchError((_) {});
                        final cubit = context.read<DetectorCubit>();
                        if (isRunning) {
                          cubit.pauseDetection();
                          // ignore: deprecated_member_use
                          SemanticsService.announce(l10n.pauseDetection, Directionality.of(context));
                        } else if (isPaused) {
                          cubit.resumeDetection();
                          // ignore: deprecated_member_use
                          SemanticsService.announce(l10n.resumeDetection, Directionality.of(context));
                        } else {
                          cubit.startDetection();
                          // ignore: deprecated_member_use
                          SemanticsService.announce(l10n.startDetection, Directionality.of(context));
                        }
                      },
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
