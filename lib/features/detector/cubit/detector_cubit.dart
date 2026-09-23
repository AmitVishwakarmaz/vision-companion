import 'package:flutter_bloc/flutter_bloc.dart';
import 'detector_state.dart';

class DetectorCubit extends Cubit<DetectorState> {
  DetectorCubit() : super(const DetectorInitial());

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
}
