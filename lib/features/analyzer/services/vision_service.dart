abstract class VisionService {
  /// Analyzes an image file at [imagePath] with the given [apiKey] and returns the generated description.
  Future<String> analyzeImage({
    required String imagePath,
    required String apiKey,
    String? prompt,
    String languageCode = 'en',
    String? model,
  });
}
