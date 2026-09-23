import 'package:equatable/equatable.dart';
import 'package:vision_companion/features/analyzer/models/analysis_data.dart';

abstract class AnalyzerState extends Equatable {
  const AnalyzerState();

  @override
  List<Object?> get props => [];
}

/// Idle state when the analyzer is ready for image capture.
class AnalyzerIdle extends AnalyzerState {
  const AnalyzerIdle();
}

/// Alias for AnalyzerIdle for backward compatibility.
typedef AnalyzerInitial = AnalyzerIdle;

/// Processing state while image is being analyzed by Groq AI.
class AnalyzerProcessing extends AnalyzerState {
  final String? imagePath;

  const AnalyzerProcessing({this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// Alias for AnalyzerProcessing for backward compatibility.
typedef AnalyzerLoading = AnalyzerProcessing;

/// Result state carrying the AnalysisData from Groq Vision API.
class AnalyzerResult extends AnalyzerState {
  final AnalysisData data;

  const AnalyzerResult(this.data);

  /// Convenience getters for direct access and backward compatibility
  String get description => data.description;
  String get imagePath => data.imagePath;
  int get latencyMs => data.latencyMs;

  @override
  List<Object?> get props => [data];
}

/// Alias for AnalyzerResult for backward compatibility.
typedef AnalyzerSuccess = AnalyzerResult;

/// Error state when network, API key, or processing fails.
class AnalyzerError extends AnalyzerState {
  final String message;
  final String? failedImagePath;

  const AnalyzerError(this.message, {this.failedImagePath});

  @override
  List<Object?> get props => [message, failedImagePath];
}
