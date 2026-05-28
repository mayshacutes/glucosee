import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class MedicChatPage extends StatefulWidget {
  const MedicChatPage({super.key});

  @override
  State<MedicChatPage> createState() => _MedicChatPageState();
}

class _MedicChatPageState extends State<MedicChatPage> {
  final List<Map<String, dynamic>> _patients = [
    {"name": "Emberlia T.P.", "lastMsg": "Dok, gula saya tinggi lagi", "time": "10:30", "unread": 2},
    {"name": "Ahmad Fauzi", "lastMsg": "Terima kasih dok 🙏", "time": "09:15", "unread": 0},
    {"name": "Siti Rahayu", "lastMsg": "Jadwal kontrol kapan ya?", "time": "Kemarin", "unread": 1},
  ];

  String? _selectedPatient;
  final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();

  void _openChat(String name) {
    setState(() {
      _selectedPatient = name;
      _messages.clear();
      _messages.addAll([
        {"text": "Dok, gula darah saya 164 mg/dL", "isMe": false},
        {"text": "Baik, apakah sudah minum obat hari ini?", "isMe": true},
        {"text": "Sudah dok, tapi masih tinggi", "isMe": false},
      ]);
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text, "isMe": true});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPatient != null) {
      return _buildChatDetail();
    }
    return _buildChatList();
  }

  Widget _buildChatList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Pasien"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryBlue,
                child: Text(patient["name"][0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text(patient["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(patient["lastMsg"], maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(patient["time"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (patient["unread"] > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${patient["unread"]}",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              onTap: () => _openChat(patient["name"]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatDetail() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPatient!),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedPatient = null),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryBlue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
