import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/analyzer/services/gemini_vision_service.dart';

class MockHttpClient implements HttpClient {
  int statusCode = 200;
  String responseBody = '';
  Exception? throwOnPost;
  Uri? lastUri;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    lastUri = url;
    if (throwOnPost != null) {
      throw throwOnPost!;
    }
    return MockHttpClientRequest(statusCode: statusCode, responseBody: responseBody);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final String responseBody;
  @override
  final HttpHeaders headers = MockHttpHeaders();

  MockHttpClientRequest({required this.statusCode, required this.responseBody});

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse(statusCode: statusCode, responseBody: responseBody);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientResponse extends StreamView<List<int>> implements HttpClientResponse {
  @override
  final int statusCode;
  final String responseBody;

  MockHttpClientResponse({required this.statusCode, required this.responseBody})
      : super(Stream<List<int>>.fromIterable([utf8.encode(responseBody)]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpHeaders implements HttpHeaders {
  final Map<String, Object> _headers = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GeminiVisionService', () {
    late MockHttpClient mockHttpClient;
    late GeminiVisionService service;
    late File tempFile;

    setUp(() async {
      mockHttpClient = MockHttpClient();
      service = GeminiVisionService(customHttpClient: mockHttpClient);

      final tempDir = await Directory.systemTemp.createTemp('gemini_test_');
      tempFile = File('${tempDir.path}/test_image.jpg');
      await tempFile.writeAsBytes(utf8.encode('dummy-image-bytes'));
    });

    tearDown(() async {
      try {
        if (await tempFile.exists()) {
          await tempFile.parent.delete(recursive: true);
        }
      } catch (_) {}
    });

    test('throws GeminiAuthException when apiKey is empty', () async {
      expect(
        () => service.analyzeImage(
          imagePath: tempFile.path,
          apiKey: '',
        ),
        throwsA(isA<GeminiAuthException>()),
      );
    });

    test('successfully parses Gemini Vision response on HTTP 200', () async {
      mockHttpClient.statusCode = 200;
      mockHttpClient.responseBody = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'A brightly lit room with a wooden table and a white mug.'}
              ],
              'role': 'model'
            },
            'finishReason': 'STOP'
          }
        ]
      });

      final result = await service.analyzeImage(
        imagePath: tempFile.path,
        apiKey: 'AIzaSy_mock_gemini_key_123',
      );

      expect(result, equals('A brightly lit room with a wooden table and a white mug.'));
      expect(mockHttpClient.lastUri.toString(), contains('key=AIzaSy_mock_gemini_key_123'));
      expect(mockHttpClient.lastUri.toString(), contains('${GeminiVisionService.defaultModel}:generateContent'));
    });

    test('sanitizes quotes from apiKey before calling endpoint', () async {
      mockHttpClient.statusCode = 200;
      mockHttpClient.responseBody = jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Sanitized test pass.'}
              ]
            }
          }
        ]
      });

      await service.analyzeImage(
        imagePath: tempFile.path,
        apiKey: '"AIzaSy_quoted_key"',
      );

      expect(mockHttpClient.lastUri.toString(), contains('key=AIzaSy_quoted_key'));
      expect(mockHttpClient.lastUri.toString(), isNot(contains('%22')));
    });

    test('throws GeminiAuthException on HTTP 400 with invalid API key message', () async {
      mockHttpClient.statusCode = 400;
      mockHttpClient.responseBody = jsonEncode({
        'error': {
          'code': 400,
          'message': 'API key not valid. Please pass a valid API key.',
          'status': 'INVALID_ARGUMENT'
        }
      });

      expect(
        () => service.analyzeImage(
          imagePath: tempFile.path,
          apiKey: 'invalid_key',
        ),
        throwsA(isA<GeminiAuthException>()),
      );
    });

    test('throws GeminiRateLimitException on HTTP 429 Resource Exhausted', () async {
      mockHttpClient.statusCode = 429;
      mockHttpClient.responseBody = jsonEncode({
        'error': {
          'code': 429,
          'message': 'Resource has been exhausted (e.g. check quota).',
          'status': 'RESOURCE_EXHAUSTED'
        }
      });

      expect(
        () => service.analyzeImage(
          imagePath: tempFile.path,
          apiKey: 'rate_limited_key',
        ),
        throwsA(isA<GeminiRateLimitException>()),
      );
    });

    test('throws GeminiNetworkException on SocketException', () async {
      mockHttpClient.throwOnPost = const SocketException('Failed to resolve host');

      expect(
        () => service.analyzeImage(
          imagePath: tempFile.path,
          apiKey: 'valid_key',
        ),
        throwsA(isA<GeminiNetworkException>()),
      );
    });

    test('throws GeminiNetworkException on TimeoutException with user-friendly message', () async {
      mockHttpClient.throwOnPost = TimeoutException('Request timed out after 25s');

      expect(
        () => service.analyzeImage(
          imagePath: tempFile.path,
          apiKey: 'valid_key',
        ),
        throwsA(
          isA<GeminiNetworkException>().having(
            (e) => e.message,
            'message',
            isNot(contains('TimeoutException')),
          ),
        ),
      );
    });

    test('throws GeminiApiException when image file does not exist', () async {
      expect(
        () => service.analyzeImage(
          imagePath: '/non/existent/path/photo.jpg',
          apiKey: 'valid_key',
        ),
        throwsA(isA<GeminiApiException>()),
      );
    });
  });
}
