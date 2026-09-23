import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'detector_state.dart';

class DetectorCubit extends Cubit<DetectorState> {
  final HistoryRepository? historyRepository;

  DetectorCubit({this.historyRepository})
      : super(const DetectorInitial());

  Future<void> startDetection({Map<String, dynamic>? metadata}) async {
    emit(const DetectorRunning(detectedObjects: []));
    try {
      await historyRepository?.logDetection(
        resultSummary: 'Live object detection session active: scanning for objects.',
        metadata: metadata ?? {
          'source': 'detector_camera',
          'status': 'running',
        },
      );
    } catch (_) {}
  }

  void stopDetection() {
    emit(const DetectorStopped());
  }

  Future<void> updateDetectedObjects(List<String> objects) async {
    if (state is DetectorRunning) {
      emit(DetectorRunning(detectedObjects: objects));
      if (objects.isNotEmpty) {
        try {
          await historyRepository?.logDetection(
            resultSummary: 'Detected: ${objects.join(', ')}',
            metadata: {
              'source': 'detector_inference',
              'objects': objects,
              'count': objects.length,
            },
          );
        } catch (_) {}
      }
    }
  }

  /// Logs a detection summary to Firestore history under users/{uid}/history/{docId}.
  Future<String?> logDetectionResult(String summary, {Map<String, dynamic>? metadata}) async {
    if (historyRepository == null) return null;
    return historyRepository!.logDetection(
      resultSummary: summary,
      metadata: metadata,
    );
  }
}
