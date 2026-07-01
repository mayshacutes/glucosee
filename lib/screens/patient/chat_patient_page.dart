import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:glucosee/services/auth_service.dart';

class ChatPatientPage extends StatefulWidget {
  const ChatPatientPage({super.key});

  @override
  State<ChatPatientPage> createState() => _ChatPatientPageState();
}

class _ChatPatientPageState extends State<ChatPatientPage> {
  List<ChatRoomModel> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getChatRooms();
    if (!mounted) return;
    setState(() {
      _rooms = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Pesan"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text("Belum ada percakapan",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text(
                          "Chat akan muncul setelah appointment disetujui",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _rooms.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 70),
                    itemBuilder: (context, i) {
                      final room = _rooms[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Colors.green.withValues(alpha: 0.15),
                          child: Text(room.otherUserName[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ),
                        title: Text(room.otherUserName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          room.lastMessage ?? "Mulai percakapan...",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: room.hasUnread
                                  ? Colors.black87
                                  : Colors.grey),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (room.lastMessageAt != null)
                              Text(
                                DateFormat('HH:mm')
                                    .format(room.lastMessageAt!),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            if (room.hasUnread)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientChatDetailPage(
                              roomId: room.roomId,
                              otherUserName: room.otherUserName,
                            ),
                          ),
                        ).then((_) => _load()),
                      );
                    },
                  ),
                ),
    );
  }
}

// ── CHAT DETAIL ───────────────────────────────────────────

class PatientChatDetailPage extends StatefulWidget {
  final String roomId;
  final String otherUserName;

  const PatientChatDetailPage({
    super.key,
    required this.roomId,
    required this.otherUserName,
  });

  @override
  State<PatientChatDetailPage> createState() =>
      _PatientChatDetailPageState();
}

class _PatientChatDetailPageState extends State<PatientChatDetailPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late Stream<List<MessageModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = PatientService.messagesStream(widget.roomId);
    PatientService.markRoomAsRead(widget.roomId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await PatientService.sendMessage(widget.roomId, text);
    _scrollToBottom();
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
    final myId = AuthService.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                      child: Text("Belum ada pesan",
                          style: TextStyle(color: Colors.grey)));
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) =>
                      _bubble(messages[i], messages[i].senderId == myId),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _bubble(MessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.green.withValues(alpha: 0.2),
              child: Text(widget.otherUserName[0],
                  style: const TextStyle(fontSize: 12)),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4)
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(msg.text,
                      style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(DateFormat('HH:mm').format(msg.sentAt),
                      style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: "Tulis pesan...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.bgLight,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}