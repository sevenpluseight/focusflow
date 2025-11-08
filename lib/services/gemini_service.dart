import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static late final GenerativeModel _model;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("❌ Missing GEMINI_API_KEY in .env file");
    }

    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    _initialized = true;
  }

  /// Sends a text prompt and returns the AI’s response.
  static Future<String> generateText(String prompt) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "⚠️ No response from Gemini.";
    } catch (e) {
      throw Exception("Gemini request failed: $e");
    }
  }

  static Future<String> testConnection() async {
    try {
      await initialize();
      const prompt = "Say Gemini is connected!";
      final result = await generateText(prompt);
      return "✅ Gemini connected: $result";
    } catch (e) {
      return "❌ Gemini connection failed: $e";
    }
  }
}
