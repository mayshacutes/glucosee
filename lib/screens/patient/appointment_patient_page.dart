import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/services/medic_service.dart';

class AppointmentPatientPage extends StatefulWidget {
  const AppointmentPatientPage({super.key});

  @override
  State<AppointmentPatientPage> createState() =>
      _AppointmentPatientPageState();
}

class _AppointmentPatientPageState extends State<AppointmentPatientPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _myAppointments = [];
  bool _loading = true;
  void _showRatingDialog(BuildContext context, Map<String, dynamic> apt) {
    int tempRating = 5;
    final reviewCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Rating untuk ${apt['medic_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setDlgState(() => tempRating = i + 1),
                    child: Icon(
                      Icons.star,
                      size: 36,
                      color: i < tempRating ? Colors.amber : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan (opsional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                await PatientService.submitRating(
                  appointmentId: apt['id'],
                  medicId: apt['medic_id'],
                  rating: tempRating,
                  review: reviewCtrl.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                _load();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Rating berhasil dikirim, terima kasih!'),
                  backgroundColor: Colors.green,
                ));
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getMyAppointments();
    if (!mounted) return;
    setState(() {
      _myAppointments = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: AppColors.primaryBlue,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Jadwal Saya"),
            Tab(text: "Buat Appointment"),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildMyAppointments(),
                const _BrowseMedicTab(),
              ],
            ),
    );
  }

  Widget _buildMyAppointments() {
    if (_myAppointments.isEmpty) {
      return const Center(
        child: Text("Belum ada appointment",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myAppointments.length,
        itemBuilder: (context, i) {
          final apt = _myAppointments[i];
          final status = apt['status'] as String;
          Color statusColor;
          String statusLabel;
          switch (status) {
            case 'approved':
              statusColor = Colors.green;
              statusLabel = 'Disetujui';
              break;
            case 'declined':
              statusColor = Colors.red;
              statusLabel = 'Ditolak';
              break;
            default:
              statusColor = Colors.orange;
              statusLabel = 'Menunggu';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primaryBlue.withValues(alpha: 0.15),
                        child: const Icon(Icons.medical_services,
                            color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(apt['medic_name'] ?? 'Dokter',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('EEEE, d MMM yyyy').format(
                                  DateTime.parse(apt['appointment_date'])),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(apt['time_range'] ?? '-',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
                        label: const Text("Batalkan", style: TextStyle(color: Colors.red)),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Batalkan Appointment?"),
                              content: Text(
                                "Appointment dengan ${apt['medic_name']} pada ${DateFormat('d MMM yyyy').format(DateTime.parse(apt['appointment_date']))} akan dibatalkan.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Kembali"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Ya, Batalkan"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await PatientService.cancelAppointment(apt['id']);
                            if (mounted) _load();
                          }
                        },
                      ),
                    ),
                  ],

                  if (status == 'approved') ...[
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: PatientService.getRating(apt['id']),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 20, child: LinearProgressIndicator());
                        }
                        final existingRating = snap.data;
                        if (existingRating != null) {
                          return Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: i < (existingRating['rating'] as int)
                                      ? Colors.amber
                                      : Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('Rating diberikan',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          );
                        }
                        // Hanya tampilkan tombol rating kalau appointment sudah lewat
                        final aptDate = DateTime.parse(apt['appointment_date']);
                        if (aptDate.isAfter(DateTime.now())) return const SizedBox();
                        return TextButton.icon(
                          icon: const Icon(Icons.star_border, color: Colors.amber, size: 18),
                          label: const Text('Beri Rating',
                              style: TextStyle(color: Colors.amber)),
                          onPressed: () => _showRatingDialog(context, apt),
                        );
                      },
                    ),
                  ],
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── TAB BROWSE NAKES ──────────────────────────────────────

class _BrowseMedicTab extends StatefulWidget {
  const _BrowseMedicTab();

  @override
  State<_BrowseMedicTab> createState() => _BrowseMedicTabState();
}

class _BrowseMedicTabState extends State<_BrowseMedicTab> {
  List<Map<String, dynamic>> _medics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getVerifiedMedics();
    if (!mounted) return;
    setState(() {
      _medics = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_medics.isEmpty) {
      return const Center(
          child: Text("Belum ada tenaga medis tersedia",
              style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medics.length,
      itemBuilder: (context, i) {
        final m = _medics[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.green.withValues(alpha: 0.15),
                      child: const Icon(Icons.person,
                          color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['name'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(m['profession'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(m['address'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 14),
                        Text(
                          "${m['rating'] ?? 0}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openBookingSheet(context, m),
                    child: const Text("Buat Appointment"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openBookingSheet(
      BuildContext context, Map<String, dynamic> medic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BookingSheet(medic: medic),
    ).then((_) => _load());
  }
}

// ── BOOKING SHEET ─────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> medic;
  const _BookingSheet({required this.medic});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {

  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Widget _buildCustomCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday;
    final leadingEmpty = (firstWeekday - 1) % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _calendarMonth =
                  DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1)),
            ),
            Text(DateFormat('MMMM yyyy').format(_calendarMonth),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _calendarMonth =
                  DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1)),
            ),
          ],
        ),
        Row(
          children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
              .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingEmpty + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            if (index < leadingEmpty) return const SizedBox();
            final day = index - leadingEmpty + 1;
            final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
            final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
            final unavail = _isUnavailable(date);
            final isWeekend = date.weekday == DateTime.sunday;
            final isBlocked = isPast || unavail || isWeekend;
            final isSelected = _selectedDate != null &&
                date.year == _selectedDate!.year &&
                date.month == _selectedDate!.month &&
                date.day == _selectedDate!.day;

            return GestureDetector(
              onTap: isBlocked
                  ? () {
                      if (unavail) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Dokter tidak tersedia pada tanggal ini"),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 1),
                        ));
                      }
                    }
                  : () => setState(() => _selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : isBlocked
                          ? null
                          : Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: isBlocked
                      ? null
                      : Border.all(color: Colors.green.shade300, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$day",
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : isBlocked
                            ? Colors.grey.shade400
                            : Colors.green.shade800,
                    fontWeight: isBlocked ? FontWeight.normal : FontWeight.w600,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade300),
              ),
            ),
            const SizedBox(width: 4),
            const Text("Tersedia", style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(width: 16),
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            const Text("Tidak tersedia", style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  DateTime? _selectedDate;
  String? _selectedTime;
  List<DateTime> _unavailable = [];
  bool _loading = false;
  bool _loadingDates = true;

  final List<String> _timeSlots = [
    '08.00-09.00', '09.00-10.00', '10.00-11.00',
    '11.00-12.00', '13.00-14.00', '14.00-15.00',
    '15.00-16.00', '16.00-17.00',
  ];

  @override
  void initState() {
    super.initState();
    _loadUnavailable();
  }

  Future<void> _loadUnavailable() async {
    final data = await PatientService.getMedicUnavailableDates(
        widget.medic['id']);
    if (!mounted) return;
    setState(() {
      _unavailable = data;
      _loadingDates = false;
    });
  }

  bool _isUnavailable(DateTime day) => _unavailable.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day);

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Pilih tanggal dan jam dulu"),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    await PatientService.createAppointment(
      medicId: widget.medic['id'],
      date: _selectedDate!,
      timeRange: _selectedTime!,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Appointment berhasil dibuat, menunggu konfirmasi dokter"),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text("Buat Appointment dengan",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(widget.medic['name'] ?? '-',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Text(widget.medic['profession'] ?? '-',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          const Text("Pilih Tanggal",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _loadingDates
              ? const Center(child: CircularProgressIndicator())
              : _buildCustomCalendar(),
          if (_selectedDate != null) ...[
            const Text("Pilih Jam",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((t) {
                final selected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t,
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _book,
                    child: const Text("Konfirmasi Appointment")),
          ),
        ],
      ),
    );
  }
}