import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/analyzer/services/groq_vision_service.dart';

class MockHttpClient implements HttpClient {
  int statusCode = 200;
  String responseBody = '';
  Exception? throwOnPost;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
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
  group('GroqVisionService', () {
    late MockHttpClient mockHttpClient;
    late GroqVisionService service;

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = GroqVisionService(customHttpClient: mockHttpClient);
    });

    test('throws GroqAuthException when apiKey is empty', () async {
      expect(
        () => service.analyzeImageBytes(
          base64Image: 'dGVzdA==',
          apiKey: '',
        ),
        throwsA(isA<GroqAuthException>()),
      );
    });

    test('successfully parses Groq Vision response on HTTP 200', () async {
      mockHttpClient.statusCode = 200;
      mockHttpClient.responseBody = jsonEncode({
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': 'A cup of green tea on a wooden saucer with steam rising.',
            },
          },
        ],
      });

      final description = await service.analyzeImageBytes(
        base64Image: 'dGVzdA==',
        apiKey: 'gsk_valid_key_123',
      );

      expect(description, equals('A cup of green tea on a wooden saucer with steam rising.'));
    });

    test('throws GroqAuthException on HTTP 401 Unauthorized', () async {
      mockHttpClient.statusCode = 401;
      mockHttpClient.responseBody = jsonEncode({'error': {'message': 'Invalid API Key'}});

      expect(
        () => service.analyzeImageBytes(
          base64Image: 'dGVzdA==',
          apiKey: 'gsk_invalid_key',
        ),
        throwsA(isA<GroqAuthException>()),
      );
    });

    test('throws GroqRateLimitException on HTTP 429 Rate Limit', () async {
      mockHttpClient.statusCode = 429;
      mockHttpClient.responseBody = jsonEncode({'error': {'message': 'Rate limit exceeded'}});

      expect(
        () => service.analyzeImageBytes(
          base64Image: 'dGVzdA==',
          apiKey: 'gsk_rate_limited_key',
        ),
        throwsA(isA<GroqRateLimitException>()),
      );
    });

    test('throws GroqNetworkException on SocketException', () async {
      mockHttpClient.throwOnPost = const SocketException('Connection refused');

      expect(
        () => service.analyzeImageBytes(
          base64Image: 'dGVzdA==',
          apiKey: 'gsk_valid_key',
        ),
        throwsA(isA<GroqNetworkException>()),
      );
    });
  });
}
