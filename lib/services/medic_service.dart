import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';

// ─── MODEL ───────────────────────────────────────────────

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime date;
  final String timeRange;
  String status; // pending, approved, declined

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.timeRange,
    required this.status,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> row, String patientName) {
    return AppointmentModel(
      id: row['id'],
      patientId: row['patient_id'],
      patientName: patientName,
      date: DateTime.parse(row['appointment_date']),
      timeRange: row['time_range'] ?? '-',
      status: row['status'] ?? 'pending',
    );
  }
}

class PrescriptionModel {
  final String id;
  final String medicId;
  final String? patientId;
  String patientName;
  String patientIdNumber;
  String usia;
  String beratBadan;
  String jenisKelamin;
  String diagnosis;
  String alergi;
  String namaObat;
  String dosis;
  String frekuensi;
  String aturanPakai;
  String catatan;
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.medicId,
    this.patientId,
    required this.patientName,
    this.patientIdNumber = '',
    this.usia = '',
    this.beratBadan = '',
    this.jenisKelamin = '',
    this.diagnosis = '',
    this.alergi = '',
    required this.namaObat,
    required this.dosis,
    this.frekuensi = '',
    this.aturanPakai = '',
    this.catatan = '',
    required this.createdAt,
  });

  factory PrescriptionModel.fromMap(Map<String, dynamic> row) {
    return PrescriptionModel(
      id: row['id'],
      medicId: row['medic_id'],
      patientId: row['patient_id'],
      patientName: row['patient_name'] ?? '',
      patientIdNumber: row['patient_id_number'] ?? '',
      usia: row['usia'] ?? '',
      beratBadan: row['berat_badan'] ?? '',
      jenisKelamin: row['jenis_kelamin'] ?? '',
      diagnosis: row['diagnosis'] ?? '',
      alergi: row['alergi'] ?? '',
      namaObat: row['nama_obat'] ?? '',
      dosis: row['dosis'] ?? '',
      frekuensi: row['frekuensi'] ?? '',
      aturanPakai: row['aturan_pakai'] ?? '',
      catatan: row['catatan'] ?? '',
      createdAt: DateTime.parse(row['created_at']),
    );
  }
}

class ChatRoomModel {
  final String roomId;
  final String otherUserId;
  final String otherUserName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool hasUnread;

  ChatRoomModel({
    required this.roomId,
    required this.otherUserId,
    required this.otherUserName,
    this.lastMessage,
    this.lastMessageAt,
    this.hasUnread = false,
  });
}

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool readStatus;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.readStatus,
  });

  factory MessageModel.fromMap(Map<String, dynamic> row) {
    return MessageModel(
      id: row['id'],
      roomId: row['room_id'],
      senderId: row['sender_id'],
      text: row['message_text'] ?? '',
      sentAt: DateTime.parse(row['sent_at']),
      readStatus: row['read_status'] ?? false,
    );
  }
}

// ─── SERVICE ─────────────────────────────────────────────

class MedicService {
  static final _client = SupabaseConfig.client;

  static String get _medicId => AuthService.currentUser!.id;

  // ── APPOINTMENTS ──────────────────────────────────────

  static Future<List<AppointmentModel>> getAppointments() async {
    final rows = await _client
        .from('appointments')
        .select()
        .eq('medic_id', _medicId)
        .order('appointment_date', ascending: true);

    final List<AppointmentModel> result = [];
    for (final row in (rows as List)) {
      final profile = await _client
          .from('profiles')
          .select('name')
          .eq('id', row['patient_id'])
          .maybeSingle();
      final name = profile?['name'] ?? 'Pasien';
      result.add(AppointmentModel.fromMap(row, name));
    }
    return result;
  }

  static Future<void> updateAppointmentStatus(String id, String status) async {
    await _client.from('appointments').update({'status': status}).eq('id', id);
  }

  static List<AppointmentModel> appointmentsOn(
      List<AppointmentModel> list, DateTime day) {
    return list.where((a) {
      return a.date.year == day.year &&
          a.date.month == day.month &&
          a.date.day == day.day;
    }).toList();
  }

  // ── UNAVAILABLE DATES ─────────────────────────────────

  static Future<List<DateTime>> getUnavailableDates() async {
    final rows = await _client
        .from('medic_unavailable_dates')
        .select('unavailable_date')
        .eq('medic_id', _medicId);
    return (rows as List)
        .map((r) => DateTime.parse(r['unavailable_date']))
        .toList();
  }

  static Future<void> toggleUnavailableDate(DateTime day) async {
    final dateStr =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final existing = await _client
        .from('medic_unavailable_dates')
        .select()
        .eq('medic_id', _medicId)
        .eq('unavailable_date', dateStr)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('medic_unavailable_dates')
          .delete()
          .eq('medic_id', _medicId)
          .eq('unavailable_date', dateStr);
    } else {
      await _client.from('medic_unavailable_dates').insert({
        'medic_id': _medicId,
        'unavailable_date': dateStr,
      });
    }
  }

  // ── PRESCRIPTIONS ─────────────────────────────────────

  static Future<List<PrescriptionModel>> getPrescriptions() async {
  final List<Map<String, dynamic>> rows =
      await _client
          .from('prescriptions')
          .select()
          .eq('medic_id', _medicId)
          .order('created_at', ascending: false);

  return rows
      .map((row) => PrescriptionModel.fromMap(row))
      .toList();
}

  static Future<void> addPrescription({
    required String patientName,
    String? patientId,
    String patientIdNumber = '',
    String usia = '',
    String beratBadan = '',
    String jenisKelamin = '',
    String diagnosis = '',
    String alergi = '',
    required String namaObat,
    required String dosis,
    String frekuensi = '',
    String aturanPakai = '',
    String catatan = '',
  }) async {
    await _client.from('prescriptions').insert({
      'medic_id': _medicId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_id_number': patientIdNumber,
      'usia': usia,
      'berat_badan': beratBadan,
      'jenis_kelamin': jenisKelamin,
      'diagnosis': diagnosis,
      'alergi': alergi,
      'nama_obat': namaObat,
      'dosis': dosis,
      'frekuensi': frekuensi,
      'aturan_pakai': aturanPakai,
      'catatan': catatan,
    });
  }

  // ── CHAT ──────────────────────────────────────────────

  static Future<List<ChatRoomModel>> getChatRooms() async {
    final rows = await _client
        .from('chat_rooms')
        .select()
        .or('user_a.eq.$_medicId,user_b.eq.$_medicId')
        .order('created_at', ascending: false);

    final List<ChatRoomModel> result = [];
    for (final row in (rows as List)) {
      final otherId =
          row['user_a'] == _medicId ? row['user_b'] : row['user_a'];
      final profile = await _client
          .from('profiles')
          .select('name')
          .eq('id', otherId)
          .maybeSingle();
      final otherName = profile?['name'] ?? 'Pengguna';

      // ambil pesan terakhir
      final lastMsgRows = await _client
          .from('messages')
          .select()
          .eq('room_id', row['id'])
          .order('sent_at', ascending: false)
          .limit(1);
      final lastMsg = (lastMsgRows as List).isNotEmpty ? lastMsgRows[0] : null;

      // cek unread
      final unreadRows = await _client
          .from('messages')
          .select()
          .eq('room_id', row['id'])
          .eq('read_status', false)
          .neq('sender_id', _medicId);
      final hasUnread = (unreadRows as List).isNotEmpty;

      result.add(ChatRoomModel(
        roomId: row['id'],
        otherUserId: otherId,
        otherUserName: otherName,
        lastMessage: lastMsg?['message_text'],
        lastMessageAt:
            lastMsg != null ? DateTime.parse(lastMsg['sent_at']) : null,
        hasUnread: hasUnread,
      ));
    }
    return result;
  }

  static Future<String> getOrCreateRoom(String patientId) async {
    // cek apakah room sudah ada
    final existing = await _client
        .from('chat_rooms')
        .select()
        .or('and(user_a.eq.$_medicId,user_b.eq.$patientId),and(user_a.eq.$patientId,user_b.eq.$_medicId)')
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // buat room baru
    final newRoom = await _client.from('chat_rooms').insert({
      'user_a': _medicId,
      'user_b': patientId,
    }).select().single();

    return newRoom['id'] as String;
  }

  static Stream<List<MessageModel>> messagesStream(String roomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('sent_at')
        .map((rows) => rows.map(MessageModel.fromMap).toList());
  }

  static Future<void> sendMessage(String roomId, String text) async {
    await _client.from('messages').insert({
      'room_id': roomId,
      'sender_id': _medicId,
      'message_text': text,
    });
  }

  static Future<void> markRoomAsRead(String roomId) async {
    await _client
        .from('messages')
        .update({'read_status': true})
        .eq('room_id', roomId)
        .neq('sender_id', _medicId);
  }

  // ── PATIENTS (untuk picker di resep) ─────────────────

  /// Daftar pasien unik dari appointment yang sudah approved
  static Future<List<Map<String, String>>> getMyPatients() async {
    final rows = await _client
        .from('appointments')
        .select('patient_id')
        .eq('medic_id', _medicId)
        .eq('status', 'approved');

    final Set<String> ids = {};
    final List<Map<String, String>> result = [];
    for (final row in (rows as List)) {
      final pid = row['patient_id'] as String;
      if (ids.contains(pid)) continue;
      ids.add(pid);
      final profile = await _client
          .from('profiles')
          .select('id, name')
          .eq('id', pid)
          .maybeSingle();
      if (profile != null) {
        result.add({'id': profile['id'], 'name': profile['name']});
      }
    }
    return result;
  }
  // ── GLUCOSE INPUT OLEH NAKES ──────────────────────────

  static String _conditionFromLevel(double level) {
    if (level < 70) return 'rendah';
    if (level > 140) return 'tinggi';
    return 'normal';
  }

  static Future<List<Map<String, String>>> getApprovedPatients() async {
    final rows = await _client
        .from('appointments')
        .select('patient_id')
        .eq('medic_id', _medicId)
        .eq('status', 'approved');

    final Set<String> ids = {};
    final List<Map<String, String>> result = [];
    for (final row in (rows as List)) {
      final pid = row['patient_id'] as String;
      if (ids.contains(pid)) continue;
      ids.add(pid);
      final profile = await _client
          .from('profiles')
          .select('id, name')
          .eq('id', pid)
          .maybeSingle();
      if (profile != null) {
        result.add({'id': profile['id'], 'name': profile['name']});
      }
    }
    return result;
  }

  static Future<void> inputGlucoseRecord({
    required String patientId,
    required double glucoseLevel,
    String? notes,
  }) async {
    final condition = _conditionFromLevel(glucoseLevel);
    await _client.from('glucose_records').insert({
      'patient_id': patientId,
      'glucose_level': glucoseLevel,
      'condition_status': condition,
      'notes': notes ?? '',
      'recorded_by': _medicId,
      'check_time': DateTime.now().toIso8601String(),
    });

    // kirim notifikasi ke semua anggota keluarga pasien
    await _sendGlucoseNotificationToFamily(patientId, glucoseLevel, condition);
  }

  static Future<void> _sendGlucoseNotificationToFamily(
      String patientId, double level, String condition) async {
    final families = await _client
        .from('family_connections')
        .select('family_id')
        .eq('patient_id', patientId);

    final patientProfile = await _client
        .from('profiles')
        .select('name')
        .eq('id', patientId)
        .maybeSingle();
    final patientName = patientProfile?['name'] ?? 'Pasien';

    String conditionText;
    switch (condition) {
      case 'tinggi': conditionText = '⚠️ Tinggi'; break;
      case 'rendah': conditionText = '⚠️ Rendah'; break;
      default: conditionText = '✅ Normal';
    }

    for (final row in (families as List)) {
      await _client.from('notifications').insert({
        'receiver_id': row['family_id'],
        'sender_id': _medicId,
        'title': 'Update Gula Darah - $patientName',
        'message': 'Hasil pemeriksaan: $level mg/dL ($conditionText)',
      });
    }

    // notifikasi ke pasien juga
    await _client.from('notifications').insert({
      'receiver_id': patientId,
      'sender_id': _medicId,
      'title': 'Hasil Pemeriksaan Gula Darah',
      'message': 'Kadar gula darah kamu: $level mg/dL ($conditionText)',
    });
  }

  // ── RATING ────────────────────────────────────────────

  static Future<double> getMedicRating(String medicId) async {
    final rows = await _client
        .from('ratings')
        .select('rating')
        .eq('medic_id', medicId);
    if ((rows as List).isEmpty) return 0;
    final total = rows.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
    final avg = total / rows.length;
    // update rating di medic_profiles
    await _client
        .from('medic_profiles')
        .update({'rating': double.parse(avg.toStringAsFixed(1)), 'patient_count': rows.length})
        .eq('user_id', medicId);
    return avg;
  }
}