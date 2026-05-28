import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';

class ProfileNakesPage extends StatelessWidget {
  const ProfileNakesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? "Tenaga Medis",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(user?.profession ?? "Dokter", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("STR: ${user?.noStr ?? '-'}", style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProfileStat("Pasien", "25"),
                      const SizedBox(width: 30),
                      _buildProfileStat("Rating", "4.8"),
                      const SizedBox(width: 30),
                      _buildProfileStat("Tahun", "5"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(Icons.edit, "Edit Profil", () {}),
            _buildMenuItem(Icons.schedule, "Ketersediaan Jadwal", () {}),
            _buildMenuItem(Icons.history, "Riwayat Layanan", () {}),
            _buildMenuItem(Icons.settings, "Pengaturan", () {}),
            const SizedBox(height: 20),
            _buildMenuItem(Icons.logout, "Keluar", () {
              AuthService.currentUser = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false,
              );
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryBlue),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
