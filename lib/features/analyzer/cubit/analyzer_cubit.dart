import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/features/analyzer/models/analysis_data.dart';
import 'package:vision_companion/features/analyzer/services/gemini_vision_service.dart';
import 'package:vision_companion/features/analyzer/services/groq_vision_service.dart';
import 'package:vision_companion/features/analyzer/services/vision_service.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'analyzer_state.dart';

class AnalyzerCubit extends Cubit<AnalyzerState> {
  final VisionService visionService;
  final HistoryRepository? historyRepository;
  final AnalyticsService? analyticsService;
  final String Function()? apiKeyProvider;

  AnalyzerCubit({
    VisionService? visionService,
    GroqVisionService? groqService,
    this.historyRepository,
    this.analyticsService,
    this.apiKeyProvider,
  })  : visionService = visionService ?? groqService ?? GeminiVisionService(),
        super(const AnalyzerIdle());

  /// Analyzes an image using Gemini (or Groq) Vision API.
  /// Never uploads or stores image in Firebase Storage.
  Future<void> analyzeImage(
    String imagePath, {
    String? prompt,
    String? apiKeyOverride,
    String languageCode = 'en',
    String? model,
  }) async {
    emit(AnalyzerProcessing(imagePath: imagePath));

    final stopwatch = Stopwatch()..start();

    // 1. Obtain API key safely from .env (checks GEMINI_API_KEY first, then GROQ_API_KEY)
    final rawKey = apiKeyOverride ??
        (apiKeyProvider != null ? apiKeyProvider!() : null) ??
        dotenv.env['GEMINI_API_KEY'] ??
        dotenv.env['GROQ_API_KEY'] ??
        '';

    final apiKey = _sanitizeApiKey(rawKey);

    if (apiKey.isEmpty) {
      emit(AnalyzerError(
        'Gemini API key not found. Please add GEMINI_API_KEY to your .env file.',
        failedImagePath: imagePath,
      ));
      return;
    }

    try {
      // 2. Perform AI Vision inference
      final String rawDescription = await visionService.analyzeImage(
        imagePath: imagePath,
        apiKey: apiKey,
        prompt: prompt,
        languageCode: languageCode,
        model: model,
      );

      stopwatch.stop();

      final parsed = AnalysisData.parseWithTags(rawDescription);

      final isGroq = visionService is GroqVisionService;
      final defaultModelName = isGroq
          ? GroqVisionService.defaultModel
          : GeminiVisionService.defaultModel;

      final analysisData = AnalysisData(
        description: parsed.cleanDescription,
        imagePath: imagePath,
        model: model ?? defaultModelName,
        latencyMs: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
        tags: parsed.tags,
      );

      // 3. Save text result to Firestore history (WITHOUT uploading image to Firebase Storage)
      // Path: users/{uid}/history/{docId} (with timestamp, featureType, resultSummary)
      try {
        await historyRepository?.logAnalysis(
          resultSummary: analysisData.description,
          metadata: {
            'source': isGroq ? 'groq_vision' : 'gemini_vision',
            'model': model ?? defaultModelName,
            'latencyMs': stopwatch.elapsedMilliseconds,
            'tags': analysisData.tags.map((t) => t.toMap()).toList(),
            'imagePath': File(imagePath).uri.pathSegments.isNotEmpty
                ? File(imagePath).uri.pathSegments.last
                : 'captured_photo.jpg',
          },
          timestamp: analysisData.timestamp,
        );
      } catch (err) {
        debugPrint('Notice: History log failed (non-critical): $err');
      }

      // 4. Log completion to analytics (event: image_analyzed)
      analyticsService?.logImageAnalyzed(
        model: analysisData.model,
        latencyMs: analysisData.latencyMs,
        tagsCount: analysisData.tags.length,
      );
      analyticsService?.logCustomEvent('image_analyzed', parameters: {
        'model': analysisData.model,
        'latency_ms': analysisData.latencyMs,
      });

      emit(AnalyzerResult(analysisData));
    } on GeminiAuthException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GeminiRateLimitException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GeminiNetworkException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GeminiApiException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GroqAuthException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GroqRateLimitException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GroqNetworkException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } on GroqApiException catch (e) {
      emit(AnalyzerError(e.message, failedImagePath: imagePath));
    } catch (e) {
      // Friendly user message with NO raw stack traces or technical details
      final friendlyMessage = (e is SocketException || e.toString().toLowerCase().contains('timeout'))
          ? 'Unable to analyze image. Please check your internet connection and try again.'
          : 'Unable to analyze image. Please try again.';
      emit(AnalyzerError(friendlyMessage, failedImagePath: imagePath));
    }
  }

  /// Retries analysis for the last failed image.
  Future<void> retry({String? apiKeyOverride, String languageCode = 'en'}) async {
    final currentState = state;
    if (currentState is AnalyzerError && currentState.failedImagePath != null) {
      await analyzeImage(
        currentState.failedImagePath!,
        apiKeyOverride: apiKeyOverride,
        languageCode: languageCode,
      );
    }
  }

  /// Direct helper to log an analysis result (retained for backward compatibility).
  Future<String?> logAnalysisResult(String summary, {Map<String, dynamic>? metadata}) async {
    if (historyRepository == null) return null;
    return historyRepository!.logAnalysis(
      resultSummary: summary,
      metadata: metadata,
    );
  }

  /// Resets state back to Idle.
  void reset() {
    emit(const AnalyzerIdle());
  }

  String _sanitizeApiKey(String key) {
    var k = key.trim();
    if ((k.startsWith('"') && k.endsWith('"')) || (k.startsWith("'") && k.endsWith("'"))) {
      k = k.substring(1, k.length - 1).trim();
    }
    return k;
  }
}
