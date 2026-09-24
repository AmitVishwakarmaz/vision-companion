import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vision_companion/features/analyzer/services/vision_service.dart';

/// Exception thrown when Gemini authentication fails (e.g. invalid or expired API key).
class GeminiAuthException implements Exception {
  final String message;
  final int? statusCode;

  const GeminiAuthException([
    this.message = 'Invalid Gemini API key. Please check your GEMINI_API_KEY in .env.',
    this.statusCode,
  ]);

  @override
  String toString() => message;
}

/// Exception thrown when Gemini API rate limit or quota is exceeded.
class GeminiRateLimitException implements Exception {
  final String message;
  final int? statusCode;

  const GeminiRateLimitException([
    this.message = 'Gemini servers are currently experiencing high demand. Please tap Retry to try again.',
    this.statusCode,
  ]);

  @override
  String toString() => message;
}

/// Exception thrown when a network error occurs during a Gemini API call.
class GeminiNetworkException implements Exception {
  final String message;

  const GeminiNetworkException([
    this.message = 'Network error: Unable to reach Gemini AI. Please check your internet connection.',
  ]);

  @override
  String toString() => message;
}

/// Exception thrown when Gemini returns an API-level error.
class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;

  const GeminiApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Service that interfaces with Google Gemini Vision API
/// via REST to analyze images without uploading them to Firebase Storage.
/// Automatically handles high-demand 503/429 errors with model fallback.
class GeminiVisionService implements VisionService {
  static const String defaultModel = 'gemini-3.8-flash';
  static const List<String> candidateModels = [
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
  ];

  static const String baseEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final HttpClient? customHttpClient;
  final Duration timeout;

  GeminiVisionService({
    this.customHttpClient,
    this.timeout = const Duration(seconds: 25),
  });

  @override
  Future<String> analyzeImage({
    required String imagePath,
    required String apiKey,
    String? prompt,
    String languageCode = 'en',
    String? model,
  }) async {
    final sanitizedKey = _sanitizeApiKey(apiKey);
    if (sanitizedKey.isEmpty) {
      throw const GeminiAuthException(
        'Gemini API key not found. Please add GEMINI_API_KEY to your .env file.',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw const GeminiApiException('Captured image file does not exist on device.');
    }

    // Read and encode image as base64
    final List<int> imageBytes = await file.readAsBytes();
    if (imageBytes.isEmpty) {
      throw const GeminiApiException('Captured image file is empty.');
    }

    final String base64Image = base64Encode(imageBytes);
    final String mimeType = _determineMimeType(imagePath);

    // Localized prompt tailored for assistive visual perception with explicit tag generation
    final effectivePrompt = prompt ??
        (languageCode == 'hi'
            ? 'आप दृष्टिबाधित उपयोगकर्ताओं के लिए एक सहायक विज़न साथी हैं।\n'
              'सामने क्या है, इसका स्पष्ट, उपयोगी और सटीक विवरण दें:\n'
              '1. प्राथमिक पहचान: सबसे पहले मुख्य वस्तु या दृश्य का नाम बताएं। यदि यह मुद्रा (नोट या सिक्का) है, तो मुद्रा और उसका मूल्य स्पष्ट बताएं (जैसे "यह भारतीय 500 रुपये का नोट है")।\n'
              '2. आवश्यक विवरण: रंग, छपे हुए प्रमुख शब्द या अंक, और आसपास का वातावरण बताएं।\n'
              '3. केवल वास्तविक दुनिया का विवरण: कैमरे के ओरिएंटेशन, फोटो के घूमने (जैसे "rotated 90 degrees") या तकनीकी पहलुओं का उल्लेख बिल्कुल न करें। सीधे सामने रखी वस्तु का वर्णन करें।\n'
              '4. संपूर्णता: 2 से 3 पूरे और स्वाभाविक वाक्यों में जानकारी दें जो स्क्रीन रीडर द्वारा सुनने में सहज लगें। कभी भी वाक्य को अधूरा न छोड़ें।\n'
              '5. मुख्य वस्तु टैग: विवरण के अंत में एक नई पंक्ति पर मुख्य पहचानी गई वस्तु और श्रेणी इस प्रारूप में अवश्य लिखें:\n'
              'Tags: <मुख्य वस्तु का नाम> (95%), <श्रेणी> (90%)'
            : 'You are an assistive vision companion helping a visually impaired user understand what is in front of them.\n'
              'Provide a clear, practical, and informative description:\n'
              '1. Primary identification: Immediately announce the main object or subject. If it is currency or money, clearly identify the currency name and denomination first (e.g. "An Indian 500-rupee banknote").\n'
              '2. Essential details: Mention key visual features, prominent colors, readable text or numbers, and the immediate background or surface.\n'
              '3. Avoid camera meta-commentary: Do NOT mention camera orientation, rotation angles (such as "rotated 90 degrees" or "vertical orientation"), or image framing. Focus purely on the actual physical object and scene.\n'
              '4. Completeness: Provide 2 to 3 complete, natural, and helpful sentences suitable for text-to-speech announcement. Never end mid-sentence.\n'
              '5. Object tags: At the very end of your response on a new line, always provide the primary identified object and category in this format:\n'
              'Tags: <primary_object_name> (95%), <category> (90%)');

    final requestPayload = {
      'contents': [
        {
          'parts': [
            {
              'text': effectivePrompt,
            },
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 1024,
      },
    };

    final client = customHttpClient ?? HttpClient();

    // Ordered candidate models for automatic failover when high demand occurs
    final modelsToTry = <String>{
      model ?? defaultModel,
      ...candidateModels,
    }.toList();

    String lastErrorMessage = 'Unable to analyze image. Please try again.';
    int? lastStatusCode;

    try {
      for (final candidate in modelsToTry) {
        // Try up to 2 attempts per candidate model for momentary spikes
        for (int attempt = 0; attempt < 2; attempt++) {
          try {
            final uri = Uri.parse('$baseEndpoint/$candidate:generateContent?key=$sanitizedKey');
            final request = await client.postUrl(uri).timeout(timeout);
            request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
            request.add(utf8.encode(jsonEncode(requestPayload)));

            final response = await request.close().timeout(timeout);
            final responseBody = await response.transform(utf8.decoder).join();

            if (response.statusCode == 200) {
              final Map<String, dynamic> jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
              final candidates = jsonResponse['candidates'] as List<dynamic>?;
              if (candidates == null || candidates.isEmpty) {
                throw const GeminiApiException('No description was generated by Gemini AI.');
              }

              final firstCandidate = candidates[0] as Map<String, dynamic>;
              final content = firstCandidate['content'] as Map<String, dynamic>?;
              final parts = content?['parts'] as List<dynamic>?;

              if (parts == null || parts.isEmpty) {
                throw const GeminiApiException('Empty response received from Gemini Vision API.');
              }

              final firstPart = parts[0] as Map<String, dynamic>;
              final text = firstPart['text'] as String?;

              if (text == null || text.trim().isEmpty) {
                throw const GeminiApiException('Empty description received from Gemini Vision API.');
              }

              return text.trim();
            }

            // Parse error response
            lastStatusCode = response.statusCode;
            String errorMessage = 'Gemini service error (Status ${response.statusCode})';
            String errorStatus = '';
            try {
              final errorJson = jsonDecode(responseBody) as Map<String, dynamic>;
              if (errorJson['error'] is Map) {
                final errorMap = errorJson['error'] as Map<String, dynamic>;
                errorMessage = errorMap['message'] as String? ?? errorMessage;
                errorStatus = errorMap['status'] as String? ?? '';
              }
            } catch (_) {}

            lastErrorMessage = errorMessage;

            // If authentication error, fail immediately without trying other models
            final isAuthError = response.statusCode == 401 ||
                response.statusCode == 403 ||
                (response.statusCode == 400 &&
                    (errorMessage.toLowerCase().contains('api key') ||
                        errorStatus == 'INVALID_ARGUMENT'));

            if (isAuthError) {
              throw GeminiAuthException(
                'Invalid Gemini API key. Please check your GEMINI_API_KEY in .env.',
                response.statusCode,
              );
            }

            // High demand / rate limit check
            final isOverloaded = response.statusCode == 503 ||
                response.statusCode == 429 ||
                errorStatus == 'RESOURCE_EXHAUSTED' ||
                errorStatus == 'UNAVAILABLE' ||
                errorMessage.toLowerCase().contains('overloaded') ||
                errorMessage.toLowerCase().contains('demand');

            if (isOverloaded) {
              debugPrint('Notice: Gemini model $candidate high demand (status ${response.statusCode}), attempt $attempt. Trying next candidate...');
              if (attempt == 0) {
                await Future.delayed(const Duration(milliseconds: 600));
                continue;
              } else {
                break; // break to next model in modelsToTry
              }
            }

            // If 404 (model not found), immediately move to next model
            if (response.statusCode == 404) {
              break;
            }
          } on TimeoutException {
            debugPrint('Notice: Timeout on $candidate, falling back to next candidate model...');
            if (customHttpClient != null) {
              throw const GeminiNetworkException(
                'Unable to analyze image. Please check your internet connection and try again.',
              );
            }
            break;
          } on SocketException {
            throw const GeminiNetworkException(
              'Unable to reach AI service. Please check your internet connection and try again.',
            );
          } catch (e) {
            if (e is GeminiAuthException || e is GeminiNetworkException) {
              rethrow;
            }
            debugPrint('Notice: Error on $candidate: $e');
            break;
          }
        }
      }

      // If all models in the fallback pipeline were exhausted
      if (lastStatusCode == 503 ||
          lastStatusCode == 429 ||
          lastErrorMessage.toLowerCase().contains('overloaded') ||
          lastErrorMessage.toLowerCase().contains('demand')) {
        throw const GeminiRateLimitException(
          'Gemini servers are currently experiencing high demand across all models. Please tap Retry in a few moments.',
          503,
        );
      }

      if (lastStatusCode == null) {
        throw const GeminiNetworkException(
          'Unable to analyze image. Please check your internet connection and try again.',
        );
      }

      throw GeminiApiException(lastErrorMessage, statusCode: lastStatusCode);
    } finally {
      if (customHttpClient == null) {
        client.close(force: true);
      }
    }
  }

  /// Sanitizes API key by removing whitespace, quotes, or accidental invisible characters.
  String _sanitizeApiKey(String key) {
    return key.trim().replaceAll('"', '').replaceAll("'", '');
  }

  /// Infers image MIME type from the file path.
  String _determineMimeType(String imagePath) {
    final lower = imagePath.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
