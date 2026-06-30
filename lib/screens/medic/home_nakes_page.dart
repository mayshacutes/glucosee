import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/medic_data.dart';
import 'package:glucosee/screens/medic/profile_nakes_page.dart';

class HomeNakesPage extends StatefulWidget {
  const HomeNakesPage({super.key});

  @override
  State<HomeNakesPage> createState() => _HomeNakesPageState();
}

class _HomeNakesPageState extends State<HomeNakesPage> {
  late DateTime _visibleMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final todayAppointments = MedicData.todayCount;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 16),
                _buildAppointmentBanner(todayAppointments),
                const SizedBox(height: 20),
                const Text(
                  "My Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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

  Widget _buildHeader(BuildContext context, user) {
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
                ),
                tooltip: "Edit Profil",
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => setState(() {}),
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
                backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                child: user?.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user?.name ?? 'Tenaga Medis'} ${user?.profession ?? ''}".trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          user?.address ?? '-',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
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
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    user?.rating?.toStringAsFixed(1) ?? '-',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Riwayat Pelayanan",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _miniStat("Akumulasi Pasien", "${user?.patientCount ?? 0}\nOrang"),
              ),
              Expanded(
                child: _miniStat(
                  "Bergabung Sejak",
                  user?.joinDate != null ? DateFormat('d MMM yyyy').format(user!.joinDate!) : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildAppointmentBanner(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Hari ini anda memiliki $count appointment",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedDay = DateTime.now()),
            child: const Text("See more"),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Senin = 0 ... Minggu = 6, sesuai mockup (Mon..Sat ditampilkan, mulai dari Senin)
    final leadingEmpty = (firstDayOfMonth.weekday - 1) % 7;

    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
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
              final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isSelected = _selectedDay != null &&
                  date.year == _selectedDay!.year &&
                  date.month == _selectedDay!.month &&
                  date.day == _selectedDay!.day;
              final hasAppointment = MedicData.appointmentsOn(date).isNotEmpty;
              final unavailable = MedicData.isUnavailable(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                onLongPress: () {
                  setState(() => MedicData.toggleAvailability(date));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        MedicData.isUnavailable(date)
                            ? "Tanggal ${date.day} ditandai tidak tersedia"
                            : "Tanggal ${date.day} tersedia kembali",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : isToday
                            ? AppColors.primaryBlue.withOpacity(0.15)
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
                              : unavailable
                                  ? Colors.grey
                                  : Colors.black87,
                          decoration: unavailable ? TextDecoration.lineThrough : null,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasAppointment)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.accentRed,
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
          const Text(
            "Tekan lama tanggal untuk tandai tidak tersedia",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final dayAppointments = MedicData.appointmentsOn(_selectedDay!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(_selectedDay!),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (dayAppointments.isEmpty)
            const Text("Tidak ada appointment pada tanggal ini.", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...dayAppointments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                      child: Text(a.patientName[0], style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(a.patientName, style: const TextStyle(fontSize: 13))),
                    Text(a.timeRange, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}