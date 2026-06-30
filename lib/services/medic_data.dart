enum AppointmentStatus { pending, approved, declined }

class AppointmentItem {
  final String id;
  final String patientName;
  final DateTime date;
  final String timeRange;
  AppointmentStatus status;

  AppointmentItem({
    required this.id,
    required this.patientName,
    required this.date,
    required this.timeRange,
    this.status = AppointmentStatus.pending,
  });
}

class Prescription {
  final String id;
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

  Prescription({
    required this.id,
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
}

/// Penyimpanan data sederhana di memori (mock) yang dipakai bersama oleh
/// Home, Appointment, dan Resep Obat agar datanya konsisten/nyambung.
class MedicData {
  MedicData._();

  static final List<AppointmentItem> appointments = [
    AppointmentItem(
      id: 'a1',
      patientName: 'Emberlia Trisnawati Putri',
      date: DateTime.now(),
      timeRange: '09.00-12.00',
    ),
    AppointmentItem(
      id: 'a2',
      patientName: 'Bella Khoirunnisa',
      date: DateTime.now(),
      timeRange: '12.00-13.00',
    ),
    AppointmentItem(
      id: 'a3',
      patientName: 'Julia Firly',
      date: DateTime.now(),
      timeRange: '13.00-15.00',
    ),
    AppointmentItem(
      id: 'a4',
      patientName: 'Mushab Abdurrozak',
      date: DateTime.now().add(const Duration(days: 1)),
      timeRange: '07.00-10.00',
    ),
    AppointmentItem(
      id: 'a5',
      patientName: 'Ahmad Fathoni',
      date: DateTime.now().add(const Duration(days: 1)),
      timeRange: '11.00-12.00',
    ),
    AppointmentItem(
      id: 'a6',
      patientName: 'Najlaa Mahendra',
      date: DateTime.now().add(const Duration(days: 2)),
      timeRange: '15.00-17.00',
    ),
  ];

  static final List<Prescription> prescriptions = [
    Prescription(
      id: 'r1',
      patientName: 'Emberlia Trisnawati Putri',
      patientIdNumber: 'PSN-0001',
      usia: '29',
      beratBadan: '58 kg',
      jenisKelamin: 'Perempuan',
      diagnosis: 'Diabetes Tipe 2',
      alergi: '-',
      namaObat: 'Metformin',
      dosis: '500mg',
      frekuensi: '2x sehari',
      aturanPakai: 'Sesudah makan',
      catatan: 'Kontrol kembali 2 minggu lagi',
      createdAt: DateTime.now(),
    ),
  ];

  /// Tanggal yang sengaja ditandai dokter sebagai TIDAK tersedia praktik.
  static final Set<DateTime> unavailableDates = {};

  static List<AppointmentItem> appointmentsOn(DateTime day) {
    return appointments
        .where((a) =>
            a.date.year == day.year &&
            a.date.month == day.month &&
            a.date.day == day.day)
        .toList();
  }

  static int get todayCount => appointmentsOn(DateTime.now()).length;

  static void toggleAvailability(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final existing = unavailableDates.firstWhere(
      (d) => d.year == key.year && d.month == key.month && d.day == key.day,
      orElse: () => DateTime(0),
    );
    if (existing.year == 0) {
      unavailableDates.add(key);
    } else {
      unavailableDates.remove(existing);
    }
  }

  static bool isUnavailable(DateTime day) {
    return unavailableDates.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );
  }
}