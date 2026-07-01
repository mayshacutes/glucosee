import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/screens/admin/verification_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<UserModel>> _patientsFuture;
  late Future<List<UserModel>> _medicsFuture;
  late Future<List<UserModel>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _patientsFuture = AuthService.patients;
      _medicsFuture = AuthService.verifiedMedics;
      _pendingFuture = AuthService.pendingMedics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.primaryBlue,
            indicatorColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Pasien"),
              Tab(text: "Nakes Aktif"),
              Tab(text: "Pending"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildList(_patientsFuture, Colors.blue, subtitle: (u) => "Diabetes: ${u.diabetesType ?? '-'}"),
                _buildList(_medicsFuture, Colors.green, subtitle: (u) => "${u.profession ?? '-'} | STR: ${u.noStr ?? '-'}"),
                _buildPendingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(Future<List<UserModel>> future, Color color, {required String Function(UserModel) subtitle}) {
    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text("Belum ada data", style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Text(u.name[0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(subtitle(u), style: const TextStyle(fontSize: 12)),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingList() {
    return FutureBuilder<List<UserModel>>(
      future: _pendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        final pending = snapshot.data ?? [];
        if (pending.isEmpty) {
          return const Center(child: Text("Tidak ada nakes pending", style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (context, i) {
            final m = pending[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.orange.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(m.name[0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.email, style: const TextStyle(fontSize: 11)),
                    Text("${m.profession ?? '-'} | STR: ${m.noStr ?? '-'}", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: "Setujui",
                      onPressed: () async {
                        await AuthService.updateMedicStatus(m.id, MedicStatus.verified);
                        if (mounted) _refresh();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${m.name} telah diverifikasi"), backgroundColor: Colors.green),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: "Tolak",
                      onPressed: () async {
                        await AuthService.updateMedicStatus(m.id, MedicStatus.rejected);
                        if (mounted) _refresh();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${m.name} ditolak"), backgroundColor: Colors.red),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}