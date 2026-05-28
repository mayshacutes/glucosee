import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/models/user_model.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  List<UserModel> get _pendingMedics => AuthService.pendingMedics;

  void _verifyMedic(UserModel medic) {
    setState(() {
      final index = AuthService.allUsers.indexWhere((u) => u.id == medic.id);
      if (index != -1) {
        AuthService.allUsers[index] = UserModel(
          id: medic.id,
          name: medic.name,
          email: medic.email,
          password: medic.password,
          role: medic.role,
          profession: medic.profession,
          noStr: medic.noStr,
          medicStatus: MedicStatus.verified,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tenaga medis ${medic.name} telah diverifikasi"), backgroundColor: Colors.green),
    );
  }

  void _rejectMedic(UserModel medic) {
    setState(() {
      final index = AuthService.allUsers.indexWhere((u) => u.id == medic.id);
      if (index != -1) {
        AuthService.allUsers[index] = UserModel(
          id: medic.id,
          name: medic.name,
          email: medic.email,
          password: medic.password,
          role: medic.role,
          profession: medic.profession,
          noStr: medic.noStr,
          medicStatus: MedicStatus.rejected,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verifikasi tenaga medis ${medic.name} ditolak"), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi Tenaga Medis"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _pendingMedics.isEmpty
          ? const Center(child: Text("Tidak ada tenaga medis yang menunggu verifikasi"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingMedics.length,
              itemBuilder: (context, index) {
                final medic = _pendingMedics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(medic.name[0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(medic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${medic.profession} | STR: ${medic.noStr}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _verifyMedic(medic),
                          tooltip: "Verifikasi",
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _rejectMedic(medic),
                          tooltip: "Tolak",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
