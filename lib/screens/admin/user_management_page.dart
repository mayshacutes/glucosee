import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<UserModel>> _patientsFuture;
  late Future<List<UserModel>> _medicsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = AuthService.patients;
    _medicsFuture = AuthService.verifiedMedics;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.primaryBlue,
            indicatorColor: AppColors.primaryBlue,
            tabs: [
              Tab(text: "Pasien"),
              Tab(text: "Tenaga Medis"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                FutureBuilder<List<UserModel>>(
                  future: _patientsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final patients = snapshot.data ?? [];
                    if (patients.isEmpty) {
                      return const Center(child: Text("Belum ada pasien terdaftar"));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final p = patients[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryBlue,
                              child: Text(p.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(p.name),
                            subtitle: Text("Diabetes ${p.diabetesType ?? '-'}"),
                            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                          ),
                        );
                      },
                    );
                  },
                ),
                FutureBuilder<List<UserModel>>(
                  future: _medicsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final medics = snapshot.data ?? [];
                    if (medics.isEmpty) {
                      return const Center(child: Text("Belum ada tenaga medis terverifikasi"));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: medics.length,
                      itemBuilder: (context, index) {
                        final m = medics[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(m.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(m.name),
                            subtitle: Text("${m.profession ?? '-'} | STR: ${m.noStr ?? '-'}"),
                            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}