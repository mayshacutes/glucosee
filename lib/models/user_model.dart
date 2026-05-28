enum UserRole { patient, medic, admin }

enum MedicStatus { pending, verified, rejected }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? diabetesType;
  final String? profession; // for medic
  final String? noStr; // for medic
  final MedicStatus? medicStatus; // for medic verification

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    this.address,
    this.diabetesType,
    this.profession,
    this.noStr,
    this.medicStatus,
  });
}

class FamilyConnection {
  final String id;
  final String patientId;
  final String familyId;
  final String familyName;
  final String relationship;
  final DateTime createdAt;

  FamilyConnection({
    required this.id,
    required this.patientId,
    required this.familyId,
    required this.familyName,
    required this.relationship,
    required this.createdAt,
  });
}

class GlucoseRecord {
  final String id;
  final String patientId;
  final double glucoseLevel;
  final DateTime checkTime;
  final String conditionStatus;
  final String? notes;

  GlucoseRecord({
    required this.id,
    required this.patientId,
    required this.glucoseLevel,
    required this.checkTime,
    required this.conditionStatus,
    this.notes,
  });
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isUser,
  });
}
