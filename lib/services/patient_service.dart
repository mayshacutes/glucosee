import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientService {
  static final _client = SupabaseConfig.client;
  static String get _patientId => AuthService.currentUser!.id;
  // ── FAMILY ACCEPT / REJECT ────────────────────────────

  static Future<List<Map<String, dynamic>>> getPendingFamilyRequests() async {
    final rows = await _client
        .from('family_connections')
        .select()
        .eq('family_id', _patientId)
        .eq('status', 'pending');

    final List<Map<String, dynamic>> result = [];
    for (final row in (rows as List)) {
      final profile = await _client
          .from('profiles')
          .select('name, email')
          .eq('id', row['patient_id'])
          .maybeSingle();
      result.add({
        'id': row['id'],
        'patient_id': row['patient_id'],
        'relationship': row['relationship'],
        'name': profile?['name'] ?? '-',
        'email': profile?['email'] ?? '-',
      });
    }
    return result;
  }

  static Future<Map<String, dynamic>?> getAppointmentByRoomParticipant(String otherUserId) async {
    return await _client
        .from('appointments')
        .select()
        .eq('patient_id', _patientId)
        .eq('medic_id', otherUserId)
        .eq('status', 'approved')
        .order('appointment_date', ascending: false)
        .limit(1)
        .maybeSingle();
  }
  
  static Future<void> respondFamilyRequest(String connectionId, String patientId, bool accept) async {
    if (accept) {
      await _client
          .from('family_connections')
          .update({'status': 'accepted'})
          .eq('id', connectionId);

      // buat chat room antar keduanya
      final existing = await _client
          .from('chat_rooms')
          .select()
          .or('and(user_a.eq.$_patientId,user_b.eq.$patientId),and(user_a.eq.$patientId,user_b.eq.$_patientId)')
          .maybeSingle();

      if (existing == null) {
        await _client.from('chat_rooms').insert({
          'user_a': _patientId,
          'user_b': patientId,
        });
      }

      // notifikasi ke pengirim request
      final myProfile = await _client
          .from('profiles')
          .select('name')
          .eq('id', _patientId)
          .maybeSingle();
      await _client.from('notifications').insert({
        'receiver_id': patientId,
        'sender_id': _patientId,
        'title': 'Permintaan Diterima',
        'message': '${myProfile?['name'] ?? 'Pengguna'} menerima permintaan pemantauan kamu.',
      });
    } else {
      await _client
          .from('family_connections')
          .update({'status': 'rejected'})
          .eq('id', connectionId);
    }
  }

  // ── PAYMENT ───────────────────────────────────────────

  static Future<String?> submitBpjs({
    required String appointmentId,
    required String bpjsNumber,
    required DateTime appointmentDate,
    required String timeStart,
  }) async {
    try {
      await _client.from('appointments').update({
        'payment_method': 'bpjs',
        'payment_status': 'pending_verification',
        'bpjs_number': bpjsNumber,
        'time_start': timeStart,
      }).eq('id', appointmentId);

      await _client.from('payment_verifications').upsert({
        'appointment_id': appointmentId,
        'patient_id': _patientId,
        'payment_method': 'bpjs',
        'bpjs_number': bpjsNumber,
        'amount': 0,
        'status': 'pending',
      });

      // notifikasi admin
      final admins = await _client.from('profiles').select('id').eq('role', 'admin');
      for (final a in (admins as List)) {
        await _client.from('notifications').insert({
          'receiver_id': a['id'],
          'sender_id': _patientId,
          'title': 'Verifikasi BPJS Baru',
          'message': 'Ada permintaan konsultasi dengan BPJS yang perlu diverifikasi.',
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> submitMandiriPayment({
    required String appointmentId,
    required String proofLocalPath,
    required DateTime appointmentDate,
    required String timeStart,
  }) async {
    try {
      final bytes = await XFile(proofLocalPath).readAsBytes();
      final ext = proofLocalPath.split('.').last;
      final fileName = '${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _client.storage.from('payment_proofs').uploadBinary(
        fileName, bytes,
        fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
      );

      final proofUrl = _client.storage.from('payment_proofs').getPublicUrl(fileName);

      await _client.from('appointments').update({
        'payment_method': 'mandiri',
        'payment_status': 'pending_verification',
        'payment_proof_url': proofUrl,
        'time_start': timeStart,
      }).eq('id', appointmentId);

      await _client.from('payment_verifications').upsert({
        'appointment_id': appointmentId,
        'patient_id': _patientId,
        'payment_method': 'mandiri',
        'proof_url': proofUrl,
        'amount': 50000,
        'status': 'pending',
      });

      final admins = await _client.from('profiles').select('id').eq('role', 'admin');
      for (final a in (admins as List)) {
        await _client.from('notifications').insert({
          'receiver_id': a['id'],
          'sender_id': _patientId,
          'title': 'Bukti Pembayaran Baru',
          'message': 'Ada bukti pembayaran mandiri yang perlu diverifikasi.',
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<Map<String, dynamic>?> getPaymentStatus(String appointmentId) async {
    return await _client
        .from('payment_verifications')
        .select()
        .eq('appointment_id', appointmentId)
        .maybeSingle();
  }

  // ── CEK CHAT AKTIF ────────────────────────────────────

  static bool isChatActive(Map<String, dynamic> appointment) {
    final chatExpiresAt = appointment['chat_expires_at'];
    if (chatExpiresAt == null) return false;

    final now = DateTime.now();
    if (!now.isBefore(DateTime.parse(chatExpiresAt))) return false;

    // hitung start time dari appointment_date + time_range
    final aptDate = DateTime.parse(appointment['appointment_date']);
    final timeRange = appointment['time_range'] as String?;
    if (timeRange == null) return false;

    final parts = timeRange.split('-');
    final startParts = parts[0].trim().replaceAll('.', ':').split(':');
    final startsAt = DateTime(aptDate.year, aptDate.month, aptDate.day,
        int.parse(startParts[0]), int.parse(startParts[1]));

    return now.isAfter(startsAt);
  }

  // ── DAFTAR NAKES TERVERIFIKASI ────────────────────────

  static Future<List<Map<String, dynamic>>> getVerifiedMedics() async {
    final medicRows = await _client
        .from('medic_profiles')
        .select()
        .eq('medic_status', 'verified');

    final List<Map<String, dynamic>> result = [];
    for (final mRow in (medicRows as List)) {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', mRow['user_id'])
          .maybeSingle();
      if (profile != null) {
        result.add({
          'id': profile['id'],
          'name': profile['name'],
          'address': profile['address'] ?? '-',
          'profession': mRow['profession'] ?? '-',
          'no_str': mRow['no_str'] ?? '-',
          'rating': mRow['rating'] ?? 0,
          'is_active': profile['is_active'] ?? true,
        });
      }
    }
    return result;
  }

  // ── UNAVAILABLE DATES NAKES ───────────────────────────

  static Future<List<DateTime>> getMedicUnavailableDates(String medicId) async {
    final rows = await _client
        .from('medic_unavailable_dates')
        .select('unavailable_date')
        .eq('medic_id', medicId);
    return (rows as List)
        .map((r) => DateTime.parse(r['unavailable_date']))
        .toList();
  }

  // ── APPOINTMENT PASIEN ────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMyAppointments() async {
    final rows = await _client
        .from('appointments')
        .select()
        .eq('patient_id', _patientId)
        .order('appointment_date', ascending: false);

    final List<Map<String, dynamic>> result = [];
    for (final row in (rows as List)) {
      final profile = await _client
          .from('profiles')
          .select('name')
          .eq('id', row['medic_id'])
          .maybeSingle();
      result.add({
        ...row,
        'medic_name': profile?['name'] ?? 'Dokter',
      });
    }
    return result;
  }

  static Future<void> createAppointment({
    required String medicId,
    required DateTime date,
    required String timeRange,
  }) async {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _client.from('appointments').insert({
      'medic_id': medicId,
      'patient_id': _patientId,
      'appointment_date': dateStr,
      'time_range': timeRange,
      'status': 'pending',
    });
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await _client
        .from('appointments')
        .delete()
        .eq('id', appointmentId)
        .eq('patient_id', _patientId);
  }

  // ── CHAT ──────────────────────────────────────────────

  static Future<List<ChatRoomModel>> getChatRooms() async {
    final rows = await _client
        .from('chat_rooms')
        .select()
        .or('user_a.eq.$_patientId,user_b.eq.$_patientId')
        .order('created_at', ascending: false);

    // ambil semua family connections sekali
    final familyRows = await _client
        .from('family_connections')
        .select('family_id, relationship')
        .eq('patient_id', _patientId);
    final familyMap = <String, String>{};
    for (final f in (familyRows as List)) {
      familyMap[f['family_id'] as String] = f['relationship'] as String? ?? '';
    }

    final List<ChatRoomModel> result = [];
    for (final row in (rows as List)) {
      final otherId =
          row['user_a'] == _patientId ? row['user_b'] : row['user_a'];
      final profile = await _client
          .from('profiles')
          .select('name')
          .eq('id', otherId)
          .maybeSingle();
      final otherName = profile?['name'] ?? 'Nakes';

      final isFamily = familyMap.containsKey(otherId);
      final relationship = familyMap[otherId];

      final lastMsgRows = await _client
          .from('messages')
          .select()
          .eq('room_id', row['id'])
          .order('sent_at', ascending: false)
          .limit(1);
      final lastMsg =
          (lastMsgRows as List).isNotEmpty ? lastMsgRows[0] : null;

      final unreadRows = await _client
          .from('messages')
          .select()
          .eq('room_id', row['id'])
          .eq('read_status', false)
          .neq('sender_id', _patientId);
      final hasUnread = (unreadRows as List).isNotEmpty;

      result.add(ChatRoomModel(
        roomId: row['id'],
        otherUserId: otherId,
        otherUserName: otherName,
        relationship: relationship,
        isFamily: isFamily,
        lastMessage: lastMsg?['message_text'],
        lastMessageAt:
            lastMsg != null ? DateTime.parse(lastMsg['sent_at']).toLocal() : null,
        hasUnread: hasUnread,
      ));
    }
    return result;
  }

  static Future<String> getOrCreateRoom(String medicId) async {
    final existing = await _client
        .from('chat_rooms')
        .select()
        .or('and(user_a.eq.$_patientId,user_b.eq.$medicId),and(user_a.eq.$medicId,user_b.eq.$_patientId)')
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final newRoom = await _client.from('chat_rooms').insert({
      'user_a': _patientId,
      'user_b': medicId,
    }).select().single();

    return newRoom['id'] as String;
  }
  // ── MEDICATION REMINDERS ──────────────────────────────

  static Future<List<Map<String, dynamic>>> getMedicationReminders() async {
    final rows = await _client
        .from('medication_reminders')
        .select()
        .eq('patient_id', _patientId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  static Future<void> addMedicationReminder({
    required String medicationName,
    required String dosage,
    required String frequency,
    required List<String> times,
  }) async {
    await _client.from('medication_reminders').insert({
      'patient_id': _patientId,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
    });
  }

  static Future<void> deleteMedicationReminder(String id) async {
    await _client.from('medication_reminders').update({'is_active': false}).eq('id', id);
  }
  static Stream<List<MessageModel>> messagesStream(String roomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('sent_at', ascending: true)   // ← pastikan true
        .map((rows) => rows.map(MessageModel.fromMap).toList());
  }

  static Future<void> sendMessage(String roomId, String text) async {
    await _client.from('messages').insert({
      'room_id': roomId,
      'sender_id': _patientId,
      'message_text': text,
    });
  }

  static Future<void> markRoomAsRead(String roomId) async {
    await _client
        .from('messages')
        .update({'read_status': true})
        .eq('room_id', roomId)
        .neq('sender_id', _patientId);
  }
  // ── GLUCOSE HISTORY ───────────────────────────────────

  static Future<List<Map<String, dynamic>>> getGlucoseHistory() async {
    final rows = await _client
        .from('glucose_records')
        .select()
        .eq('patient_id', _patientId)
        .order('check_time', ascending: false)
        .limit(20);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>?> getLatestGlucose() async {
    return await _client
        .from('glucose_records')
        .select()
        .eq('patient_id', _patientId)
        .order('check_time', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // ── FAMILY CONNECTION ─────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFamilyConnections() async {
    final rows = await _client
        .from('family_connections')
        .select()
        .eq('patient_id', _patientId);

    final List<Map<String, dynamic>> result = [];
    for (final row in (rows as List)) {
      final profile = await _client
          .from('profiles')
          .select('name, email')
          .eq('id', row['family_id'])
          .maybeSingle();
      result.add({
        'id': row['id'],
        'family_id': row['family_id'],
        'relationship': row['relationship'],
        'name': profile?['name'] ?? '-',
        'email': profile?['email'] ?? '-',
      });
    }
    return result;
  }

  static Future<String?> addFamilyByEmail(String email, String relationship) async {
    // cari user berdasarkan email
    final profile = await _client
        .from('profiles')
        .select('id, name, role')
        .eq('email', email.trim())
        .maybeSingle();

    if (profile == null) return 'Email tidak ditemukan. Pastikan orang ini sudah punya akun Glucosee.';
    if (profile['id'] == _patientId) return 'Tidak bisa menambahkan diri sendiri.';

    // cek sudah terhubung?
    final existing = await _client
        .from('family_connections')
        .select()
        .eq('patient_id', _patientId)
        .eq('family_id', profile['id'])
        .maybeSingle();
    if (existing != null) return 'Pengguna ini sudah terhubung sebagai pemantau.';

    await _client.from('family_connections').insert({
      'patient_id': _patientId,
      'family_id': profile['id'],
      'relationship': relationship,
    });

    // kirim notifikasi ke anggota keluarga
    final patientProfile = await _client
        .from('profiles')
        .select('name')
        .eq('id', _patientId)
        .maybeSingle();
    await _client.from('notifications').insert({
      'receiver_id': profile['id'],
      'sender_id': _patientId,
      'title': 'Permintaan Pemantauan',
      'message':
          '${patientProfile?['name'] ?? 'Seseorang'} menambahkan kamu sebagai pemantau ($relationship).',
    });

    return null; // null = sukses
  }

  static Future<void> removeFamilyConnection(String connectionId) async {
    await _client
        .from('family_connections')
        .delete()
        .eq('id', connectionId)
        .eq('patient_id', _patientId);
  }

  // ── NOTIFICATIONS ──────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> notificationsStream() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', _patientId)
        .order('created_at', ascending: false)
        .map((rows) => rows.cast<Map<String, dynamic>>());
  }

  static Future<void> markNotificationRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }

  static Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('receiver_id', _patientId)
        .eq('is_read', false);
  }

  // ── RATING ────────────────────────────────────────────

  static Future<String?> submitRating({
    required String appointmentId,
    required String medicId,
    required int rating,
    String review = '',
  }) async {
    try {
      final existing = await _client
          .from('ratings')
          .select()
          .eq('appointment_id', appointmentId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('ratings').update({
          'rating': rating,
          'review': review,
        }).eq('appointment_id', appointmentId);
      } else {
        await _client.from('ratings').insert({
          'appointment_id': appointmentId,
          'patient_id': _patientId,
          'medic_id': medicId,
          'rating': rating,
          'review': review,
        });
      }

      final allRatings = await _client
          .from('ratings')
          .select('rating')
          .eq('medic_id', medicId);
      final distinctPatients = await _client
          .from('ratings')
          .select('patient_id')
          .eq('medic_id', medicId);
      final patientSet = <String>{};
      for (final r in (distinctPatients as List)) {
        patientSet.add(r['patient_id'] as String);
      }
      if ((allRatings as List).isNotEmpty) {
        final total = allRatings.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
        final avg = total / allRatings.length;
        await _client.from('medic_profiles').update({
          'rating': double.parse(avg.toStringAsFixed(1)),
          'patient_count': patientSet.length,
        }).eq('user_id', medicId);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<Map<String, dynamic>?> getRating(String appointmentId) async {
    return await _client
        .from('ratings')
        .select()
        .eq('appointment_id', appointmentId)
        .maybeSingle();
  }

  // ── ARTICLES (untuk pasien baca) ──────────────────────

  static Future<List<Map<String, dynamic>>> getPublishedArticles() async {
    final rows = await _client
        .from('articles')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  // ── PHOTO UPLOAD ──────────────────────────────────────

  static Future<String?> uploadAvatar(String userId) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last;
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _client.storage.from('avatars').uploadBinary(fileName, bytes,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true));

      final url = _client.storage.from('avatars').getPublicUrl(fileName);
      await _client.from('profiles').update({'photo_url': url}).eq('id', userId);
      return url;
    } catch (e) {
      return null;
    }
  }

  static Future<int> getNotificationsUnreadCount() async {
    final rows = await _client
        .from('notifications')
        .select()
        .eq('receiver_id', _patientId)
        .eq('is_read', false);
    return (rows as List).length;
  }
}