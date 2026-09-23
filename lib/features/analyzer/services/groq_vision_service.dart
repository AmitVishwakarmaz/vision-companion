import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vision_companion/features/analyzer/services/vision_service.dart';

/// Exception thrown when Groq authentication fails (e.g., 401 invalid API key).
class GroqAuthException implements Exception {
  final String message;
  const GroqAuthException([this.message = 'Invalid or unauthorized Groq API key. Please check your .env file.']);

  @override
  String toString() => message;
}

/// Exception thrown when Groq rate limit is exceeded (HTTP 429).
class GroqRateLimitException implements Exception {
  final String message;
  const GroqRateLimitException([this.message = 'Groq AI rate limit reached. Please wait a moment before trying again.']);

  @override
  String toString() => message;
}

/// Exception thrown when a network error occurs during Groq API call.
class GroqNetworkException implements Exception {
  final String message;
  const GroqNetworkException([this.message = 'Network error: Unable to connect to Groq AI service. Please check your internet connection.']);

  @override
  String toString() => message;
}

/// Exception thrown when Groq returns an API error response.
class GroqApiException implements Exception {
  final String message;
  final int statusCode;
  const GroqApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => message;
}

/// Service that interfaces with Groq's Vision API using meta-llama/llama-4-scout-17b-16e-instruct.
class GroqVisionService implements VisionService {
  static const String defaultModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  final HttpClient? customHttpClient;

  GroqVisionService({this.customHttpClient});

  /// Analyzes an image from local file path using Groq Vision API.
  /// Does NOT upload image to Firebase Storage.
  @override
  Future<String> analyzeImage({
    required String imagePath,
    required String apiKey,
    String? prompt,
    String? model,
    String languageCode = 'en',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const GroqAuthException('Groq API key not found. Please add GROQ_API_KEY to your .env file.');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw GroqApiException('Selected image file does not exist at path: $imagePath', statusCode: 400);
    }

    final Uint8List imageBytes = await file.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    // Determine mime type from extension
    final lower = imagePath.toLowerCase();
    final String mimeType = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';

    return analyzeImageBytes(
      imageBytes: imageBytes,
      base64Image: base64Image,
      mimeType: mimeType,
      apiKey: apiKey,
      prompt: prompt,
      model: model ?? defaultModel,
      languageCode: languageCode,
      timeout: timeout,
    );
  }

  /// Sends base64 image data to Groq Chat Completion API.
  Future<String> analyzeImageBytes({
    Uint8List? imageBytes,
    required String base64Image,
    String mimeType = 'image/jpeg',
    required String apiKey,
    String? prompt,
    String model = defaultModel,
    String languageCode = 'en',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const GroqAuthException('Groq API key not found. Please add GROQ_API_KEY to your .env file.');
    }

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
      'model': model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': effectivePrompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': 1024,
      'temperature': 0.3,
    };

    final client = customHttpClient ?? HttpClient();

    try {
      final request = await client.postUrl(Uri.parse(endpoint)).timeout(timeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${apiKey.trim()}');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      request.add(utf8.encode(jsonEncode(requestPayload)));

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final choices = jsonResponse['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw const GroqApiException('No description was generated by the AI model.');
        }

        final firstChoice = choices[0] as Map<String, dynamic>;
        final message = firstChoice['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;

        if (content == null || content.trim().isEmpty) {
          throw const GroqApiException('Empty response received from Groq Vision API.');
        }

        return content.trim();
      } else if (response.statusCode == 401) {
        throw const GroqAuthException('Invalid Groq API key. Please check your GROQ_API_KEY in .env.');
      } else if (response.statusCode == 429) {
        throw const GroqRateLimitException('Groq API rate limit reached. Please wait a moment before trying again.');
      } else {
        // Parse error message if available
        String errorMessage = 'Groq service error (Status ${response.statusCode})';
        try {
          final errorJson = jsonDecode(responseBody) as Map<String, dynamic>;
          if (errorJson['error'] is Map) {
            final errorMap = errorJson['error'] as Map<String, dynamic>;
            errorMessage = errorMap['message'] as String? ?? errorMessage;
          }
        } catch (_) {}
        throw GroqApiException(errorMessage, statusCode: response.statusCode);
      }
    } on SocketException {
      throw const GroqNetworkException('Network error: Unable to reach Groq AI. Please check your internet connection.');
    } on HttpException catch (e) {
      throw GroqNetworkException('HTTP connection error: ${e.message}');
    } on FormatException {
      throw const GroqApiException('Received invalid data format from AI service.');
    } catch (e) {
      if (e is GroqAuthException || e is GroqRateLimitException || e is GroqApiException || e is GroqNetworkException) {
        rethrow;
      }
      throw GroqNetworkException('Unable to complete AI analysis: $e');
    } finally {
      if (customHttpClient == null) {
        client.close();
      }
    }
  }
}
