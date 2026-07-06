import 'package:flutter_dotenv/flutter_dotenv.dart';

class AigloConfig {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';
  static String get fullUrl => '$apiUrl?key=$apiKey';
  static const String model = 'gemini-2.0-flash-lite';
}
