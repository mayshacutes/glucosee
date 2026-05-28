import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      {"action": "Login", "user": "Emberlia T.P.", "time": "10:30", "icon": Icons.login},
      {"action": "Update Profile", "user": "Dr. Andi", "time": "10:15", "icon": Icons.edit},
      {"action": "Registrasi Baru", "user": "User Baru", "time": "09:45", "icon": Icons.person_add},
      {"action": "Cek Gula Darah", "user": "Ahmad Fauzi", "time": "09:30", "icon": Icons.bloodtype},
      {"action": "Konsultasi AI", "user": "Siti Rahayu", "time": "09:00", "icon": Icons.smart_toy},
      {"action": "Tambah Resep", "user": "Dr. Andi", "time": "08:45", "icon": Icons.medication},
      {"action": "Login", "user": "Admin", "time": "08:00", "icon": Icons.login},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Icon(log["icon"] as IconData, color: AppColors.primaryBlue, size: 20),
            ),
            title: Text(log["action"] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(log["user"] as String),
            trailing: Text(log["time"] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
