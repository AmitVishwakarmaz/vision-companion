import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'analyzer_state.dart';

class AnalyzerCubit extends Cubit<AnalyzerState> {
  final HistoryRepository? historyRepository;

  AnalyzerCubit({this.historyRepository})
      : super(const AnalyzerInitial());

  Future<void> analyzeImage(String imagePath) async {
    emit(const AnalyzerLoading());
    try {
      // Feature implementation placeholder (will connect to AI Image API)
      await Future.delayed(const Duration(milliseconds: 600));
      const description = 'AI Image Analysis feature placeholder ready for API integration.';

      // Log result to Firestore history under users/{uid}/history/{docId}
      await historyRepository?.logAnalysis(
        resultSummary: description,
        metadata: {'imagePath': imagePath},
      );

      emit(AnalyzerSuccess(
        imagePath: imagePath,
        description: description,
      ));
    } catch (e) {
      emit(AnalyzerError(e.toString()));
    }
  }

  /// Explicitly logs an analysis result to Firestore history under users/{uid}/history/{docId}.
  Future<String?> logAnalysisResult(String summary, {Map<String, dynamic>? metadata}) async {
    if (historyRepository == null) return null;
    return historyRepository!.logAnalysis(
      resultSummary: summary,
      metadata: metadata,
    );
  }

  void reset() {
    emit(const AnalyzerInitial());
  }
}
