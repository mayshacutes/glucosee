import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

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
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
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
                    user?.name ?? 'Pengguna',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Diabetes ${user?.diabetesType ?? '-'}",
                      style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu items
            _buildMenuItem(Icons.medical_information, "Riwayat Kesehatan", () {}),
            _buildMenuItem(Icons.history, "Riwayat Layanan", () {}),
            _buildMenuItem(Icons.family_restroom, "Koneksi Keluarga", () {}),
            _buildMenuItem(Icons.medication, "Pengingat Obat", () {}),
            _buildMenuItem(Icons.settings, "Pengaturan Akun", () {}),
            _buildMenuItem(Icons.help, "Bantuan", () {}),
            const SizedBox(height: 20),
            _buildMenuItem(
              Icons.logout,
              "Keluar",
              () {
                AuthService.currentUser = null;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                  (route) => false,
                );
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryBlue),
        title: Text(title, style: TextStyle(color: color)),
        trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
