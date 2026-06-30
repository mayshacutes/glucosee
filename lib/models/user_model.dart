enum UserRole { patient, medic, admin, family }

enum MedicStatus { pending, verified, rejected }

class UserModel {
  final String id;
  final UserRole role;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photoUrl;
  bool isActive;

  // khusus pasien
  final String? diabetesType;

  // khusus tenaga medis
  final String? profession;
  final String? noStr;
  final MedicStatus? medicStatus;
  final double? rating;
  final int? patientCount;
  final DateTime? joinDate;

  // bisa dipakai pasien maupun nakes
  final DateTime? birthDate;
  final String? gender;

  UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photoUrl,
    this.isActive = true,
    this.diabetesType,
    this.profession,
    this.noStr,
    this.medicStatus,
    this.rating,
    this.patientCount,
    this.joinDate,
    this.birthDate,
    this.gender,
  });

  factory UserModel.fromMaps(
    Map<String, dynamic> profileRow, {
    Map<String, dynamic>? medicRow,
    Map<String, dynamic>? patientRow,
  }) {
    final roleStr = profileRow['role'] as String;
    return UserModel(
      id: profileRow['id'] as String,
      role: UserRole.values.firstWhere((r) => r.name == roleStr, orElse: () => UserRole.patient),
      name: profileRow['name'] ?? '',
      email: profileRow['email'] ?? '',
      phone: profileRow['phone'],
      address: profileRow['address'],
      photoUrl: profileRow['photo_url'],
      isActive: profileRow['is_active'] ?? true,
      diabetesType: patientRow?['diabetes_type'],
      profession: medicRow?['profession'],
      noStr: medicRow?['no_str'],
      medicStatus: medicRow?['medic_status'] != null
          ? MedicStatus.values.firstWhere(
              (s) => s.name == medicRow!['medic_status'],
              orElse: () => MedicStatus.pending,
            )
          : null,
      rating: medicRow?['rating'] != null ? (medicRow!['rating'] as num).toDouble() : null,
      patientCount: medicRow?['patient_count'],
      joinDate: medicRow?['join_date'] != null ? DateTime.tryParse(medicRow!['join_date']) : null,
      birthDate: (medicRow?['birth_date'] ?? patientRow?['birth_date']) != null
          ? DateTime.tryParse(medicRow?['birth_date'] ?? patientRow?['birth_date'])
          : null,
      gender: medicRow?['gender'] ?? patientRow?['gender'],
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profession,
    String? noStr,
    DateTime? birthDate,
    String? gender,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      role: role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl,
      isActive: isActive ?? this.isActive,
      diabetesType: diabetesType,
      profession: profession ?? this.profession,
      noStr: noStr ?? this.noStr,
      medicStatus: medicStatus,
      rating: rating,
      patientCount: patientCount,
      joinDate: joinDate,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
    );
  }
}