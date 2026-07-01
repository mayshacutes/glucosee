import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  late Future<List<UserModel>> _usersFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = AuthService.allUsers;
  }

  @override
  Widget build(BuildContext context) {
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
            future: _usersFuture,
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