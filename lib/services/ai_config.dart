import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi untuk fitur AiGlo (asisten kesehatan AI).
///
/// AiGlo menggunakan Groq API karena gratis 100%, tidak butuh kartu kredit.
///
/// CARA MENDAPATKAN API KEY (gratis, ± 1 menit, TANPA kartu kredit):
/// 1. Buka https://console.groq.com/keys
/// 2. Login dengan email atau akun Google kamu
/// 3. Klik "Create API Key"
/// 4. Copy API key (diawali "gsk_..."), lalu tempel di file .env:
///    GROQ_API_KEY=gsk_xxxxxxxxxxxx
///
class AiConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  /// Model gratis di Groq. llama-3.3-70b-versatile itu paling seimbang
  /// antara kualitas jawaban & kecepatan, cocok untuk chatbot seperti AiGlo.
  static const String groqModel = 'llama-3.3-70b-versatile';

  static const String groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

  static bool get isConfigured => groqApiKey.isNotEmpty;
}