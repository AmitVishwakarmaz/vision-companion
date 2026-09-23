import 'package:flutter_bloc/flutter_bloc.dart';
import 'analyzer_state.dart';

class AnalyzerCubit extends Cubit<AnalyzerState> {
  AnalyzerCubit() : super(const AnalyzerInitial());

  Future<void> analyzeImage(String imagePath) async {
    emit(const AnalyzerLoading());
    try {
      // Feature implementation placeholder (will connect to AI Image API)
      await Future.delayed(const Duration(milliseconds: 600));
      emit(AnalyzerSuccess(
        imagePath: imagePath,
        description: 'AI Image Analysis feature placeholder ready for API integration.',
      ));
    } catch (e) {
      emit(AnalyzerError(e.toString()));
    }
  }

  void reset() {
    emit(const AnalyzerInitial());
  }
}
