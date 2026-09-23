import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/widgets/language_toggle_button.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/widgets/bounding_box_painter.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class DetectorPage extends StatefulWidget {
  const DetectorPage({super.key});

  @override
  State<DetectorPage> createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraStreaming = false;
  String? _cameraErrorMessage;
  CameraDescription? _cameraDescription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize model and camera
    context.read<DetectorCubit>().initialize();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraErrorMessage = 'No camera available on this device.';
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
      });

      // Start detection automatically when camera is ready
      _startStreaming();
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorMessage = 'Camera error: $e';
        });
      }
    }
  }

  void _startStreaming() {
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

  void _stopStreaming() {
    if (_cameraController != null && _isCameraStreaming) {
      try {
        _cameraController!.stopImageStream();
      } catch (_) {}
      _isCameraStreaming = false;
    }
    context.read<DetectorCubit>().stopDetection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopStreaming();
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
    if (_isCameraStreaming && _cameraController != null) {
      try {
        _cameraController!.stopImageStream();
      } catch (_) {}
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
      body: BlocConsumer<DetectorCubit, DetectorState>(
        listener: (context, state) {
          if (state is DetectorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isRunning = state is DetectorRunning || state is DetectorResults;
          final List<Detection> detections = state is DetectorResults ? state.detections : const [];
          final int inferenceTimeMs = state is DetectorResults ? state.inferenceTimeMs : 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Camera Viewport with Bounding Box Overlay
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
                            // 1. Live Camera Preview
                            Center(
                              child: CameraPreview(_cameraController!),
                            ),

                            // 2. Real-time Bounding Box Overlay
                            CustomPaint(
                              painter: BoundingBoxPainter(
                                detections: detections,
                                previewSize: _cameraController!.value.previewSize,
                              ),
                            ),
                          ] else ...[
                            // Camera Placeholder / Error State
                            Center(
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
                                      _cameraErrorMessage ?? l10n.detectorPlaceholderMessage,
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
                          ],

                          // HUD Status Badge (Inference Time & Detections Count)
                          if (isRunning) ...[
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(200),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      inferenceTimeMs > 0
                                          ? '${detections.length} objects | ${inferenceTimeMs}ms'
                                          : '${detections.length} objects detected',
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
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Controls: Start / Pause Detection (Min 48x48 dp touch target)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isRunning ? Colors.black : Colors.white,
                    ),
                    label: Text(
                      isRunning ? l10n.stopDetection : l10n.startDetection,
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
                      if (isRunning) {
                        _stopStreaming();
                      } else {
                        _startStreaming();
                      }
                    },
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
