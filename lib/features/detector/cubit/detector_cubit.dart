import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'detector_state.dart';

class DetectorCubit extends Cubit<DetectorState> {
  final HistoryRepository? historyRepository;

  DetectorCubit({this.historyRepository})
      : super(const DetectorInitial());

  void startDetection() {
    emit(const DetectorRunning(detectedObjects: []));
  }

  void stopDetection() {
    emit(const DetectorStopped());
  }

  void updateDetectedObjects(List<String> objects) {
    if (state is DetectorRunning) {
      emit(DetectorRunning(detectedObjects: objects));
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
