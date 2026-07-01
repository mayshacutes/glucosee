import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:glucosee/screens/medic/profile_nakes_page.dart';

class HomeNakesPage extends StatefulWidget {
  const HomeNakesPage({super.key});

  @override
  State<HomeNakesPage> createState() => _HomeNakesPageState();
}

class _HomeNakesPageState extends State<HomeNakesPage> {
  late DateTime _visibleMonth;
  DateTime? _selectedDay;
  List<AppointmentModel> _appointments = [];
  List<DateTime> _unavailable = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      MedicService.getAppointments(),
      MedicService.getUnavailableDates(),
    ]);
    if (!mounted) return;
    setState(() {
      _appointments = results[0] as List<AppointmentModel>;
      _unavailable = results[1] as List<DateTime>;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  bool _isUnavailable(DateTime day) => _unavailable.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day);

  // untuk titik merah di kalender — exclude declined
  List<AppointmentModel> _dayActiveAppointments(DateTime day) =>
      MedicService.appointmentsOn(_appointments, day)
          .where((a) => a.status != 'declined')
          .toList();

  int get _todayCount =>
      _dayActiveAppointments(DateTime.now()).length;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: 16),
                      _buildBanner(),
                      const SizedBox(height: 20),
                      const Text("My Schedule",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      _buildCalendar(),
                      if (_selectedDay != null) ...[
                        const SizedBox(height: 16),
                        _buildSelectedDayInfo(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileNakesPage()),
                ).then((_) => setState(() {})),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _load,
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user?.name ?? '-'} ${user?.profession ?? ''}".trim(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(user?.address ?? '-',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(user?.rating?.toStringAsFixed(1) ?? '-',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                  child: _miniStat("Akumulasi Pasien",
                      "${user?.patientCount ?? 0}\nOrang")),
              Expanded(
                  child: _miniStat(
                "Bergabung Sejak",
                user?.joinDate != null
                    ? DateFormat('d MMM yyyy').format(user!.joinDate!)
                    : '-',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      );

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Hari ini anda memiliki $_todayCount appointment",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () =>
                setState(() => _selectedDay = DateTime.now()),
            child: const Text("See more"),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = (firstDay.weekday - 1) % 7;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1)),
              Text(DateFormat('MMMM yyyy').format(_visibleMonth),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1)),
            ],
          ),
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmpty + daysInMonth,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox();
              final day = index - leadingEmpty + 1;
              final date =
                  DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = _selectedDay != null &&
                  date.year == _selectedDay!.year &&
                  date.month == _selectedDay!.month &&
                  date.day == _selectedDay!.day;
              final hasAppt = _dayActiveAppointments(date).isNotEmpty;
              final unavail = _isUnavailable(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                onLongPress: () async {
                  await MedicService.toggleUnavailableDate(date);
                  await _load();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_isUnavailable(date)
                        ? "Tanggal $day ditandai tidak tersedia"
                        : "Tanggal $day tersedia kembali"),
                    duration: const Duration(seconds: 1),
                  ));
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : isToday
                            ? AppColors.primaryBlue.withValues(alpha: 0.15)
                            : null,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "$day",
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : unavail
                                  ? Colors.grey
                                  : Colors.black87,
                          decoration:
                              unavail ? TextDecoration.lineThrough : null,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (hasAppt)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text("Tekan lama tanggal untuk tandai tidak tersedia",
              style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final dayAppts = _dayActiveAppointments(_selectedDay!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDay!),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          if (dayAppts.isEmpty)
            const Text("Tidak ada appointment pada tanggal ini.",
                style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...dayAppts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AppColors.primaryBlue.withValues(alpha: 0.2),
                        child: Text(a.patientName[0],
                            style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(a.patientName,
                              style: const TextStyle(fontSize: 13))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(a.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(a.timeRange,
                            style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(a.status))),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'declined': return Colors.red;
      default: return Colors.grey;
    }
  }
}