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
    this.message = 'Gemini API quota or rate limit exceeded. Please wait a moment before trying again.',
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

/// Service that interfaces with Google Gemini Vision API (`gemini-1.5-flash`)
/// via REST to analyze images without uploading them to Firebase Storage.
class GeminiVisionService implements VisionService {
  static const String defaultModel = 'gemini-3.6-flash';
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
    final String activeModel = model ?? defaultModel;

    // Localized prompt tailored for assistive visual perception
    final effectivePrompt = prompt ??
        (languageCode == 'hi'
            ? 'आप दृष्टिबाधित उपयोगकर्ताओं के लिए एक सहायक विज़न साथी हैं।\n'
              'सामने क्या है, इसका स्पष्ट, उपयोगी और सटीक विवरण दें:\n'
              '1. प्राथमिक पहचान: सबसे पहले मुख्य वस्तु या दृश्य का नाम बताएं। यदि यह मुद्रा (नोट या सिक्का) है, तो मुद्रा और उसका मूल्य स्पष्ट बताएं (जैसे "यह भारतीय 500 रुपये का नोट है")।\n'
              '2. आवश्यक विवरण: रंग, छपे हुए प्रमुख शब्द या अंक, और आसपास का वातावरण बताएं।\n'
              '3. केवल वास्तविक दुनिया का विवरण: कैमरे के ओरिएंटेशन, फोटो के घूमने (जैसे "rotated 90 degrees") या तकनीकी पहलुओं का उल्लेख बिल्कुल न करें। सीधे सामने रखी वस्तु का वर्णन करें।\n'
              '4. संपूर्णता: 2 से 3 पूरे और स्वाभाविक वाक्यों में जानकारी दें जो स्क्रीन रीडर द्वारा सुनने में सहज लगें। कभी भी वाक्य को अधूरा न छोड़ें।'
            : 'You are an assistive vision companion helping a visually impaired user understand what is in front of them.\n'
              'Provide a clear, practical, and informative description:\n'
              '1. Primary identification: Immediately announce the main object or subject. If it is currency or money, clearly identify the currency name and denomination first (e.g. "An Indian 500-rupee banknote").\n'
              '2. Essential details: Mention key visual features, prominent colors, readable text or numbers, and the immediate background or surface.\n'
              '3. Avoid camera meta-commentary: Do NOT mention camera orientation, rotation angles (such as "rotated 90 degrees" or "vertical orientation"), or image framing. Focus purely on the actual physical object and scene.\n'
              '4. Completeness: Provide 2 to 3 complete, natural, and helpful sentences suitable for text-to-speech announcement. Never end mid-sentence.');

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
    final uri = Uri.parse('$baseEndpoint/$activeModel:generateContent?key=$sanitizedKey');

    try {
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
      } else {
        // Parse error message
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
        } else if (response.statusCode == 429 || errorStatus == 'RESOURCE_EXHAUSTED') {
          throw GeminiRateLimitException(
            'Gemini API quota or rate limit exceeded. Please wait a moment before trying again.',
            response.statusCode,
          );
        } else {
          throw GeminiApiException(errorMessage, statusCode: response.statusCode);
        }
      }
    } on TimeoutException {
      throw const GeminiNetworkException(
        'Unable to analyze image. Please check your internet connection and try again.',
      );
    } on SocketException {
      throw const GeminiNetworkException(
        'Unable to reach AI service. Please check your internet connection and try again.',
      );
    } on HttpException {
      throw const GeminiNetworkException('Connection error. Please try again.');
    } on FormatException {
      throw const GeminiApiException('Failed to parse AI response. Please try again.');
    } catch (e) {
      if (e is GeminiAuthException ||
          e is GeminiRateLimitException ||
          e is GeminiNetworkException ||
          e is GeminiApiException) {
        rethrow;
      }
      debugPrint('Unexpected GeminiVisionService error: $e');
      throw const GeminiApiException('Unable to analyze image. Please try again.');
    } finally {
      if (customHttpClient == null) {
        client.close(force: true);
      }
    }
  }

  String _sanitizeApiKey(String key) {
    var k = key.trim();
    if ((k.startsWith('"') && k.endsWith('"')) || (k.startsWith("'") && k.endsWith("'"))) {
      k = k.substring(1, k.length - 1).trim();
    }
    return k;
  }

  String _determineMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
