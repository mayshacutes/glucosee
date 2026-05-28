import 'package:glucosee/models/user_model.dart';

class AuthService {
  // Simulated users for demo
  static final List<UserModel> _users = [
    UserModel(
      id: '1',
      name: 'Emberlia Trisnawati Putri',
      email: 'patient@glucosee.com',
      password: '123456',
      role: UserRole.patient,
      phone: '08123456789',
      address: 'Bligo, Sidoarjo',
      diabetesType: 'Tipe 2',
    ),
    UserModel(
      id: '2',
      name: 'Dr. Andi Pratama',
      email: 'medic@glucosee.com',
      password: '123456',
      role: UserRole.medic,
      profession: 'Dokter',
      noStr: 'STR-12345',
      medicStatus: MedicStatus.verified,
    ),
    UserModel(
      id: '3',
      name: 'Admin Glucosee',
      email: 'admin@glucosee.com',
      password: '123456',
      role: UserRole.admin,
    ),
    UserModel(
      id: '4',
      name: 'Dr. Siti Nurhaliza',
      email: 'medic2@glucosee.com',
      password: '123456',
      role: UserRole.medic,
      profession: 'Perawat',
      noStr: 'STR-67890',
      medicStatus: MedicStatus.pending,
    ),
  ];

  static List<UserModel> get allUsers => _users;

  static List<UserModel> get pendingMedics => _users
      .where((u) => u.role == UserRole.medic && u.medicStatus == MedicStatus.pending)
      .toList();

  static List<UserModel> get verifiedMedics => _users
      .where((u) => u.role == UserRole.medic && u.medicStatus == MedicStatus.verified)
      .toList();

  static List<UserModel> get patients =>
      _users.where((u) => u.role == UserRole.patient).toList();

  static UserModel? login(String email, String password) {
    try {
      return _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  static void register(UserModel user) {
    _users.add(user);
  }

  static UserModel? currentUser;
}
