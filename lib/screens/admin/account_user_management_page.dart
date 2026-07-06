import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';

class AccountUserManagementPage extends StatefulWidget {
  const AccountUserManagementPage({super.key});

  @override
  State<AccountUserManagementPage> createState() => _AccountUserManagementPageState();
}

class _AccountUserManagementPageState extends State<AccountUserManagementPage> {
  late Future<List<UserModel>> _allUsersFuture;
  late Future<List<UserModel>> _patientsFuture;
  late Future<List<UserModel>> _medicsFuture;
  late Future<List<UserModel>> _pendingFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _allUsersFuture = AuthService.allUsers;
      _patientsFuture = AuthService.patients;
      _medicsFuture = AuthService.verifiedMedics;
      _pendingFuture = AuthService.pendingMedics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.primaryBlue,
            indicatorColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Semua Akun"),
              Tab(text: "Pasien"),
              Tab(text: "Nakes Aktif"),
              Tab(text: "Pending"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAllAccountsTab(),
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

  Widget _buildAllAccountsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari nama atau email...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<UserModel>>(
            future: _allUsersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                );
              }
              final allUsers = snapshot.data ?? [];
              final filtered = _search.isEmpty
                  ? allUsers
                  : allUsers
                      .where((u) =>
                          u.name.toLowerCase().contains(_search) ||
                          u.email.toLowerCase().contains(_search))
                      .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("Tidak ada akun ditemukan"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _roleColor(user.role),
                        child: Text(user.name[0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email, style: const TextStyle(fontSize: 12)),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _roleColor(user.role).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  user.role.name.toUpperCase(),
                                  style: TextStyle(fontSize: 10, color: _roleColor(user.role), fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (user.role == UserRole.medic && user.medicStatus != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(user.medicStatus!).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    user.medicStatus!.name.toUpperCase(),
                                    style: TextStyle(fontSize: 10, color: _statusColor(user.medicStatus!), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.patient: return Colors.blue;
      case UserRole.medic: return Colors.green;
      case UserRole.admin: return Colors.purple;
      case UserRole.family: return Colors.teal;
    }
  }

  Color _statusColor(MedicStatus status) {
    switch (status) {
      case MedicStatus.pending: return Colors.orange;
      case MedicStatus.verified: return Colors.green;
      case MedicStatus.rejected: return Colors.red;
    }
  }
}