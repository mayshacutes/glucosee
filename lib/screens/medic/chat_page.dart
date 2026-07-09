import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:glucosee/services/auth_service.dart';

// ─── CHAT LIST ────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatRoomModel> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await MedicService.getChatRooms();
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
        title: const Text("Chat"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(
                  child: Text("Belum ada percakapan",
                      style: TextStyle(color: Colors.grey)))
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
                              AppColors.primaryBlue.withValues(alpha: 0.2),
                          child: Text(room.otherUserName[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue)),
                        ),
                        title: Text(room.otherUserName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        onTap: () async {
                          final apt = await MedicService
                              .getAppointmentByRoomParticipant(room.otherUserId);
                          if (apt != null && !MedicService.isChatActive(apt)) {
                            if (!mounted) return;
                            final paymentStatus = apt['payment_status'] as String?;
                            String msg;
                            if (paymentStatus != 'paid') {
                              msg = 'Menunggu pasien menyelesaikan pembayaran';
                            } else {
                              msg = 'Sesi chat hanya aktif selama jam appointment';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(msg),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                roomId: room.roomId,
                                otherUserId: room.otherUserId,
                                otherUserName: room.otherUserName,
                              ),
                            ),
                          ).then((_) => _load());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── CHAT DETAIL ─────────────────────────────────────────

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  final String otherUserId;
  final String otherUserName;

  const ChatDetailPage({
    super.key,
    required this.roomId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late Stream<List<MessageModel>> _stream;
  bool _chatActive = true;

  @override
  void initState() {
    super.initState();
    _stream = MedicService.messagesStream(widget.roomId);
    MedicService.markRoomAsRead(widget.roomId);
    _checkChatActive();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkChatActive() async {
    final apt = await MedicService.getAppointmentByRoomParticipant(widget.otherUserId);
    if (!mounted) return;
    setState(() {
      _chatActive = apt == null || MedicService.isChatActive(apt);
    });
  }

  Future<void> _send() async {
    if (!_chatActive) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sesi chat hanya aktif selama jam appointment'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await MedicService.sendMessage(widget.roomId, text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
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
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == myId;
                    return _bubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          if (!_chatActive)
            Container(
              width: double.infinity,
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Chat akan aktif setelah pembayaran diverifikasi & jam appointment tiba',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                textAlign: TextAlign.center,
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
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
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
                  Text(
                    DateFormat('HH:mm').format(msg.sentAt),
                    style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white70
                            : Colors.grey),
                  ),
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
              enabled: _chatActive,
              decoration: InputDecoration(
                hintText: _chatActive ? "Tulis pesan..." : "Chat belum aktif",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: _chatActive ? AppColors.bgLight : Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _chatActive ? _send : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _chatActive ? AppColors.primaryBlue : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: _chatActive ? Colors.white : Colors.grey, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}