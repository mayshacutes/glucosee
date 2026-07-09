import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/screens/admin/verification_page.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  late Future<_DashboardData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAll();
  }

  Future<_DashboardData> _loadAll() async {
    final results = await Future.wait<List<dynamic>>([
      AuthService.patients,
      AuthService.verifiedMedics,
      AuthService.pendingMedics,
      _getWeeklyActivity(),
    ]);
    return _DashboardData(
      patients: results[0] as List<UserModel>,
      verifiedMedics: results[1] as List<UserModel>,
      pendingMedics: results[2] as List<UserModel>,
      weeklyActivity: results[3] as List<int>,
    );
  }

  Future<List<int>> _getWeeklyActivity() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dates = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));

    final rows = await SupabaseConfig.client
        .from('appointments')
        .select('appointment_date')
        .gte('created_at', dates.first.toIso8601String())
        .lte('created_at', dates.last.add(const Duration(hours: 23, minutes: 59)).toIso8601String());

    final counts = List.filled(7, 0);
    for (final row in (rows as List)) {
      final dt = DateTime.tryParse(row['appointment_date'] as String? ?? '');
      if (dt == null) continue;
      for (int i = 0; i < 7; i++) {
        if (dt.year == dates[i].year && dt.month == dates[i].month && dt.day == dates[i].day) {
          counts[i]++;
          break;
        }
      }
    }
    return counts;
  }

  void _refresh() => setState(() => _dataFuture = _loadAll());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        final data = snapshot.data!;
        final totalPasien = data.patients.length;
        final totalNakes = data.verifiedMedics.length;
        final totalUser = totalPasien + totalNakes;

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dashboard", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _statCard("Total Pasien", "$totalPasien", Icons.people, Colors.blue),
                    _statCard("Tenaga Medis", "$totalNakes", Icons.medical_services, Colors.green),
                    _statCard("Pending Verif", "${data.pendingMedics.length}", Icons.pending, Colors.orange),
                    _statCard("Total User", "$totalUser", Icons.group, Colors.purple),
                  ],
                ),
                const SizedBox(height: 24),
                _buildUserDistributionChart(totalPasien, totalNakes, data.pendingMedics.length),
                const SizedBox(height: 24),
                _buildActivityChart(data.weeklyActivity),
                if (data.pendingMedics.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Menunggu Verifikasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerificationPage()),
                        ).then((_) => _refresh()),
                        child: const Text("Lihat semua"),
                      ),
                    ],
                  ),
                  ...data.pendingMedics.map((m) => _pendingCard(context, m)),
                ],
                const SizedBox(height: 20),
                Text("Pasien Terdaftar", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (data.patients.isEmpty)
                  Text("Belum ada pasien", style: GoogleFonts.poppins(color: Colors.grey))
                else
                  ...data.patients.take(5).map((p) => _userRow(p, Colors.blue)),
                const SizedBox(height: 20),
                Text("Tenaga Medis Aktif", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (data.verifiedMedics.isEmpty)
                  Text("Belum ada tenaga medis", style: GoogleFonts.poppins(color: Colors.grey))
                else
                  ...data.verifiedMedics.take(5).map((m) => _userRow(m, Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserDistributionChart(int pasien, int nakes, int pending) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distribusi User", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: pasien.toDouble(),
                    title: "$pasien",
                    color: Colors.blue,
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: nakes.toDouble(),
                    title: "$nakes",
                    color: Colors.green,
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    title: "$pending",
                    color: Colors.orange,
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legend(Colors.blue, "Pasien"),
              _legend(Colors.green, "Nakes"),
              _legend(Colors.orange, "Pending"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<int> weeklyData) {
    final maxVal = weeklyData.isEmpty ? 0 : weeklyData.reduce((a, b) => a > b ? a : b).toDouble();
    final effectiveMax = maxVal > 0 ? maxVal * 1.3 : 5.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Aktivitas 7 Hari Terakhir", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: effectiveMax,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            value.toInt() < labels.length ? labels[value.toInt()] : '',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: effectiveMax > 0 ? (effectiveMax / 4.0) : 1.0,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyData[i].toDouble(),
                        color: weeklyData[i] > 0 ? AppColors.primaryBlue : Colors.grey.shade300,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _pendingCard(BuildContext context, UserModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(m.name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${m.profession ?? '-'} | STR: ${m.noStr ?? '-'}",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                Text(m.email, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VerificationPage()),
            ).then((_) => _refresh()),
            child: const Text("Verifikasi", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _userRow(UserModel u, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 3)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(u.name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(u.email, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final List<UserModel> patients;
  final List<UserModel> verifiedMedics;
  final List<UserModel> pendingMedics;
  final List<int> weeklyActivity;

  _DashboardData({
    required this.patients,
    required this.verifiedMedics,
    required this.pendingMedics,
    required this.weeklyActivity,
  });
}
