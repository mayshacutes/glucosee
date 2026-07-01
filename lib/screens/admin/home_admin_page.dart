import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
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
    final results = await Future.wait([
      AuthService.patients,
      AuthService.verifiedMedics,
      AuthService.pendingMedics,
    ]);
    return _DashboardData(
      patients: results[0],
      verifiedMedics: results[1],
      pendingMedics: results[2],
    );
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

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _statCard("Total Pasien", "${data.patients.length}", Icons.people, Colors.blue),
                    _statCard("Tenaga Medis", "${data.verifiedMedics.length}", Icons.medical_services, Colors.green),
                    _statCard("Pending Verif", "${data.pendingMedics.length}", Icons.pending, Colors.orange),
                    _statCard("Total User", "${data.patients.length + data.verifiedMedics.length}", Icons.group, Colors.purple),
                  ],
                ),

                if (data.pendingMedics.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Menunggu Verifikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                const Text("Pasien Terdaftar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (data.patients.isEmpty)
                  const Text("Belum ada pasien", style: TextStyle(color: Colors.grey))
                else
                  ...data.patients.take(5).map((p) => _userRow(p, Colors.blue)),

                const SizedBox(height: 20),
                const Text("Tenaga Medis Aktif", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                if (data.verifiedMedics.isEmpty)
                  const Text("Belum ada tenaga medis", style: TextStyle(color: Colors.grey))
                else
                  ...data.verifiedMedics.take(5).map((m) => _userRow(m, Colors.green)),
              ],
            ),
          ),
        );
      },
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${m.profession ?? '-'} | STR: ${m.noStr ?? '-'}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(m.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(u.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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

  _DashboardData({
    required this.patients,
    required this.verifiedMedics,
    required this.pendingMedics,
  });
}