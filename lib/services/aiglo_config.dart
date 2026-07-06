import 'package:flutter_dotenv/flutter_dotenv.dart';

class AigloConfig {
  static String get apiKey => dotenv.env['AIGLO_API_KEY'] ?? 'AIGLO_API_KEY_NOT_SET';
  static const String apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String model = 'claude-sonnet-4-6';
  static const String anthropicVersion = '2023-06-01';
}
