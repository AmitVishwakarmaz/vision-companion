import 'package:equatable/equatable.dart';
import 'package:vision_companion/features/analyzer/models/analysis_data.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

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

  String getLocalizedMessage(AppLocalizations l10n) {
    final lower = message.toLowerCase();
    if (lower.contains('internet') || lower.contains('network') || lower.contains('socket') || lower.contains('timeout')) {
      return l10n.analyzerErrorNetwork;
    } else if (lower.contains('api key') || lower.contains('gemini_api_key') || lower.contains('not found')) {
      return l10n.analyzerErrorApiKey;
    } else if (lower.contains('unable to analyze')) {
      return l10n.analyzerErrorGeneric;
    }
    return message;
  }

  @override
  List<Object?> get props => [message, failedImagePath];
}
