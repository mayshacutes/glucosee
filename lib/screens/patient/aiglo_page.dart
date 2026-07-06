import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/patient_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiGloPage extends StatefulWidget {
  const AiGloPage({super.key});

  @override
  State<AiGloPage> createState() => _AiGloPageState();
}

class _AiGloPageState extends State<AiGloPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Message(
      text: 'Halo! Saya AiGlo 👋\n\nSaya asisten kesehatan AI yang siap membantu kamu seputar diabetes dan kesehatan umum. Kamu bisa tanya tentang:\n• Kadar gula darah & artinya\n• Pola makan untuk penderita diabetes\n• Gejala & komplikasi diabetes\n• Tips gaya hidup sehat\n• Pertanyaan kesehatan umum lainnya\n\nAda yang ingin ditanyakan?',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true, time: DateTime.now()));
      _loading = true;
      _ctrl.clear();
    });
    _scrollToBottom();

    try {
      final user = AuthService.currentUser;
      final latestGlucose = await PatientService.getLatestGlucose();

      // Build context pasien untuk AI
      String patientContext = '';
      if (user != null) {
        patientContext = 'Nama pasien: ${user.name}. Tipe diabetes: ${user.diabetesType ?? "belum diketahui"}.';
        if (latestGlucose != null) {
          patientContext += ' Hasil gula darah terakhir: ${latestGlucose['glucose_level']} mg/dL (${latestGlucose['condition_status']}).';
        }
      }

      final response = await fetch('https://api.anthropic.com/v1/messages',
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: {
            'model': 'claude-sonnet-4-6',
            'max_tokens': 1000,
            'system': '''Kamu adalah AiGlo, asisten kesehatan AI dalam aplikasi Glucosee yang dirancang untuk membantu penderita diabetes di Indonesia. 

Panduan:
- Jawab dalam Bahasa Indonesia yang ramah, hangat, dan mudah dipahami
- Fokus pada diabetes dan kesehatan umum
- Berikan saran yang praktis dan actionable
- Selalu ingatkan untuk konsultasi dokter untuk hal yang serius
- Gunakan emoji secukupnya agar terasa lebih personal
- Jangan memberikan diagnosis atau dosis obat yang spesifik
- Jika ada data gula darah pasien, gunakan sebagai konteks jawaban

${patientContext.isNotEmpty ? "Data pasien saat ini: $patientContext" : ""}''',
            'messages': [
              ..._messages
                  .where((m) => m.isUser || _messages.indexOf(m) > 0)
                  .take(_messages.length - 1)
                  .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
                  .toList(),
              {'role': 'user', 'content': text},
            ],
          });

      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: response, isUser: false, time: DateTime.now()));
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          text: 'Maaf, terjadi kesalahan. Silakan coba lagi. 🙏',
          isUser: false,
          time: DateTime.now(),
        ));
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AiGlo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Asisten Kesehatan AI', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus percakapan',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_Message(
                  text: 'Percakapan direset. Ada yang ingin ditanyakan? 😊',
                  isUser: false,
                  time: DateTime.now(),
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick questions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickBtn('Gula darahku tinggi, apa yang harus dilakukan?'),
                  _quickBtn('Makanan apa yang baik untuk penderita diabetes?'),
                  _quickBtn('Apa gejala hipoglikemia?'),
                  _quickBtn('Berapa kadar gula darah normal?'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _typingIndicator();
                return _bubble(_messages[i]);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _quickBtn(String text) {
    return GestureDetector(
      onTap: () {
        _ctrl.text = text;
        _send();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Text(
          text.length > 30 ? '${text.substring(0, 30)}...' : text,
          style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _bubble(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
              child: const Icon(Icons.smart_toy, size: 16, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(msg.time),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            child: const Icon(Icons.smart_toy, size: 16, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0), const SizedBox(width: 4),
                _dot(1), const SizedBox(width: 4),
                _dot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.3 + 0.7 * value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Tanya AiGlo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.bgLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _loading ? Colors.grey : AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _loading ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper untuk call Anthropic API
Future<String> fetch(String url, {
  required String method,
  required Map<String, String> headers,
  required Map<String, dynamic> body,
}) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        ...headers,
        'x-api-key': 'ANTHROPIC_API_KEY_KAMU',
        'anthropic-version': '2023-06-01',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      debugPrint('AiGlo API error ${response.statusCode}: ${response.body}');
      throw Exception('Status ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final content = data['content'] as List;
    return content.map((c) => c['text'] ?? '').join('');
  } catch (e) {
    debugPrint('AiGlo error: $e');
    rethrow;
  }
}

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;
  _Message({required this.text, required this.isUser, required this.time});
}