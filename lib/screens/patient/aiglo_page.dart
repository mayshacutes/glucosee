import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class AiGloPage extends StatefulWidget {
  const AiGloPage({super.key});

  @override
  State<AiGloPage> createState() => _AiGloPageState();
}

class _AiGloPageState extends State<AiGloPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Halo! Saya AiGlo 👋\nAsisten AI pribadi kamu untuk manajemen diabetes.", "isUser": false},
    {"text": "Saya bisa membantu kamu dengan:\n• Rekomendasi pola makan\n• Pengingat obat\n• Edukasi diabetes\n• Respon keluhan awal\n\nAda yang bisa saya bantu?", "isUser": false},
  ];
  final ScrollController _scrollController = ScrollController();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    final userMsg = _controller.text.trim();
    setState(() {
      _messages.add({"text": userMsg, "isUser": true});
    });
    _controller.clear();

    // Simulated AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      String response = _generateResponse(userMsg);
      setState(() {
        _messages.add({"text": response, "isUser": false});
      });
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  String _generateResponse(String question) {
    final q = question.toLowerCase();
    if (q.contains('makan') || q.contains('diet') || q.contains('makanan')) {
      return "Untuk penderita diabetes, disarankan:\n• Konsumsi sayuran hijau\n• Hindari makanan tinggi gula\n• Perbanyak serat\n• Makan dalam porsi kecil tapi sering\n• Pilih karbohidrat kompleks";
    } else if (q.contains('obat') || q.contains('minum')) {
      return "Penting untuk minum obat secara teratur sesuai resep dokter. Jangan lupa atur pengingat minum obat di fitur Medication Reminder! ⏰";
    } else if (q.contains('gula') || q.contains('kadar')) {
      return "Kadar gula darah normal:\n• Puasa: 70-100 mg/dL\n• 2 jam setelah makan: <140 mg/dL\n• HbA1c: <5.7%\n\nJika kadar gula kamu di atas normal, segera konsultasikan ke dokter.";
    } else if (q.contains('olahraga') || q.contains('exercise')) {
      return "Olahraga yang direkomendasikan:\n• Jalan kaki 30 menit/hari\n• Berenang\n• Bersepeda\n• Yoga\n\nHindari olahraga berat tanpa konsultasi dokter terlebih dahulu.";
    } else {
      return "Terima kasih atas pertanyaannya! Untuk konsultasi lebih lanjut mengenai kondisi kesehatan kamu, saya sarankan untuk berkonsultasi langsung dengan dokter melalui fitur konsultasi online. 😊";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 16,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AiGlo", style: TextStyle(fontSize: 16)),
                Text("Online", style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          // Quick suggestions
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildSuggestion("Pola makan"),
                _buildSuggestion("Kadar gula normal"),
                _buildSuggestion("Tips olahraga"),
                _buildSuggestion("Pengingat obat"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] as bool;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg["text"],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestion(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _send();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
