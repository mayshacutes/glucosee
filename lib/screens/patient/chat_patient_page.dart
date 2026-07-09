import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<ChatRoomModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _rooms
          : _rooms.where((r) => r.otherUserName.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getChatRooms();
    if (!mounted) return;
    setState(() {
      _rooms = data;
      _loading = false;
    });
    _filter();
  }

  List<ChatRoomModel> get _familyChats => _filtered.where((r) => r.isFamily).toList();
  List<ChatRoomModel> get _medicChats => _filtered.where((r) => !r.isFamily).toList();

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
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari percakapan...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.bgLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                _searchCtrl.text.isNotEmpty
                                    ? "Tidak ditemukan"
                                    : "Belum ada percakapan",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                              if (_searchCtrl.text.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Chat akan muncul setelah appointment disetujui",
                                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            children: [
                              if (_medicChats.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                  child: Text(
                                    "Tenaga Medis",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                ..._medicChats.map((room) => _buildRoomTile(room)),
                              ],
                              if (_familyChats.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                  child: Text(
                                    "Keluarga",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                ..._familyChats.map((room) => _buildRoomTile(room)),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoomTile(ChatRoomModel room) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 2)],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: room.isFamily
                ? Colors.orange.withValues(alpha: 0.15)
                : Colors.green.withValues(alpha: 0.15),
            child: Text(room.otherUserName[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: room.isFamily ? Colors.orange : Colors.green,
                )),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  room.otherUserName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (room.isFamily && room.relationship != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    room.relationship!,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            room.lastMessage ?? "Mulai percakapan...",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: room.hasUnread ? Colors.black87 : Colors.grey,
              fontSize: 12,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (room.lastMessageAt != null)
                Text(
                  DateFormat('HH:mm').format(room.lastMessageAt!),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
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
            final apt = await PatientService.getAppointmentByRoomParticipant(room.otherUserId);
            if (apt != null && !PatientService.isChatActive(apt)) {
              final paymentStatus = apt['payment_status'] as String?;
              String msg;
              if (paymentStatus == null || paymentStatus == 'unpaid') {
                msg = 'Silakan lakukan pembayaran terlebih dahulu';
              } else if (paymentStatus == 'pending_verification') {
                msg = 'Menunggu verifikasi pembayaran oleh admin';
              } else {
                msg = 'Sesi chat hanya aktif selama jam appointment';
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                backgroundColor: Colors.orange,
              ));
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientChatDetailPage(
                  roomId: room.roomId,
                  otherUserId: room.otherUserId,
                  otherUserName: room.otherUserName,
                ),
              ),
            ).then((_) => _load());
          },
        ),
      ),
    );
  }
}

// ── CHAT DETAIL ───────────────────────────────────────────

class PatientChatDetailPage extends StatefulWidget {
  final String roomId;
  final String otherUserId;
  final String otherUserName;

  const PatientChatDetailPage({
    super.key,
    required this.roomId,
    required this.otherUserId,
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
  bool _chatActive = true;

  @override
  void initState() {
    super.initState();
    _stream = PatientService.messagesStream(widget.roomId);
    PatientService.markRoomAsRead(widget.roomId);
    _checkChatActive();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkChatActive() async {
    final apt = await PatientService.getAppointmentByRoomParticipant(widget.otherUserId);
    if (!mounted) return;
    setState(() {
      _chatActive = apt == null || PatientService.isChatActive(apt);
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
    await PatientService.sendMessage(widget.roomId, text);
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
                  itemBuilder: (context, i) =>
                      _bubble(messages[i], messages[i].senderId == myId),
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
              enabled: _chatActive,
              decoration: InputDecoration(
                hintText: _chatActive ? "Tulis pesan..." : "Chat belum aktif",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: _chatActive ? AppColors.bgLight : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
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
