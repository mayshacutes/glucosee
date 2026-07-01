import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/services/supabase_config.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  static UserModel? currentUser;

  /// Daftar akun baru. role hanya 'patient' atau 'medic' dari halaman Sign Up.
  static Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? address,
    String? profession,
    String? noStr,
    String? diabetesType,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role.name,
        'name': name,
        'phone': phone,
        'address': address,
        'profession': profession,
        'no_str': noStr,
        'diabetes_type': diabetesType,
      },
    );
    if (res.user == null) return null;
    // beri jeda kecil supaya trigger di Supabase sempat membuat row profile
    await Future.delayed(const Duration(milliseconds: 500));
    return fetchProfile(res.user!.id);
  }

  static Future<UserModel?> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) return null;
    final profile = await fetchProfile(res.user!.id);
    currentUser = profile;
    return profile;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
    currentUser = null;
  }

  /// Cek apakah ada sesi login aktif (dipakai splash screen)
  static Future<UserModel?> restoreSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    final profile = await fetchProfile(session.user.id);
    currentUser = profile;
    return profile;
  }

  static Future<UserModel?> fetchProfile(String userId) async {
    final profileRow = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (profileRow == null) return null;

    final role = profileRow['role'] as String;
    Map<String, dynamic>? medicRow;
    Map<String, dynamic>? patientRow;

    if (role == 'medic') {
      medicRow = await _client.from('medic_profiles').select().eq('user_id', userId).maybeSingle();
    } else if (role == 'patient') {
      patientRow = await _client.from('patient_profiles').select().eq('user_id', userId).maybeSingle();
    }

    return UserModel.fromMaps(profileRow, medicRow: medicRow, patientRow: patientRow);
  }

  static Future<void> updateUser(UserModel updated) async {
    await _client.from('profiles').update({
      'name': updated.name,
      'phone': updated.phone,
      'address': updated.address,
      'is_active': updated.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', updated.id);

    if (updated.role == UserRole.medic) {
      await _client.from('medic_profiles').update({
        'profession': updated.profession,
        'no_str': updated.noStr,
        'gender': updated.gender,
        if (updated.birthDate != null) 'birth_date': updated.birthDate!.toIso8601String().substring(0, 10),
      }).eq('user_id', updated.id);
    } else if (updated.role == UserRole.patient) {
      await _client.from('patient_profiles').update({
        'gender': updated.gender,
        if (updated.birthDate != null) 'birth_date': updated.birthDate!.toIso8601String().substring(0, 10),
      }).eq('user_id', updated.id);
    }

    currentUser = updated;
  }

  static Future<List<UserModel>> get pendingMedics async {
    final medicRows = await _client
        .from('medic_profiles')
        .select()
        .eq('medic_status', 'pending');

    final List<UserModel> result = [];
    for (final medicRow in (medicRows as List)) {
      final profileRow = await _client
          .from('profiles')
          .select()
          .eq('id', medicRow['user_id'])
          .maybeSingle();
      if (profileRow != null) {
        result.add(UserModel.fromMaps(profileRow, medicRow: medicRow));
      }
    }
    return result;
  }
  static Future<List<UserModel>> get allUsers async {
    final rows = await _client.from('profiles').select();
    final List<UserModel> result = [];
    for (final row in (rows as List)) {
      final role = row['role'] as String;
      Map<String, dynamic>? medicRow;
      Map<String, dynamic>? patientRow;
      if (role == 'medic') {
        medicRow = await _client
            .from('medic_profiles')
            .select()
            .eq('user_id', row['id'])
            .maybeSingle();
      } else if (role == 'patient') {
        patientRow = await _client
            .from('patient_profiles')
            .select()
            .eq('user_id', row['id'])
            .maybeSingle();
      }
      result.add(UserModel.fromMaps(row, medicRow: medicRow, patientRow: patientRow));
    }
    return result;
  }

  static Future<List<UserModel>> get patients async {
    final rows = await _client.from('profiles').select('*, patient_profiles(*)').eq('role', 'patient');
    return (rows as List).map((row) {
      final raw = row['patient_profiles'];
      final patientRow = raw is Map<String, dynamic> ? raw : null;
      return UserModel.fromMaps(row, patientRow: patientRow);
    }).toList();
  }

  static Future<List<UserModel>> get verifiedMedics async {
    final medicRows = await _client
        .from('medic_profiles')
        .select()
        .eq('medic_status', 'verified');

    final List<UserModel> result = [];
    for (final medicRow in (medicRows as List)) {
      final profileRow = await _client
          .from('profiles')
          .select()
          .eq('id', medicRow['user_id'])
          .maybeSingle();
      if (profileRow != null) {
        result.add(UserModel.fromMaps(profileRow, medicRow: medicRow));
      }
    }
    return result;
  }

  static Future<void> updateMedicStatus(String userId, MedicStatus status) async {
    await _client.from('medic_profiles').update({'medic_status': status.name}).eq('user_id', userId);
  }
  
}