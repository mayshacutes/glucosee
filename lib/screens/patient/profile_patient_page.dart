import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';
import 'package:glucosee/screens/patient/edit_profile_patient_page.dart';
import 'package:glucosee/screens/patient/glucose_history_page.dart';
import 'package:glucosee/screens/patient/appointment_patient_page.dart';
import 'package:glucosee/screens/patient/add_family_page.dart';
import 'package:glucosee/screens/patient/medicine_reminder_page.dart';
import 'package:glucosee/screens/patient/account_settings_page.dart';
import 'package:glucosee/screens/patient/help_page.dart';
import 'package:glucosee/screens/patient/medication_reminder_page.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
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
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                    backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 50, color: AppColors.primaryBlue)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.name ?? 'Pengguna',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _openEditProfile(context),
                        child: const Icon(Icons.edit, size: 16, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (user?.phone != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(user!.phone!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
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
            _buildMenuItem(Icons.edit, "Edit Profil", () => _openEditProfile(context)),
            _buildMenuItem(Icons.medical_information, "Riwayat Kesehatan", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GlucoseHistoryPage()));
            }),
            _buildMenuItem(Icons.history, "Riwayat Layanan", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentPatientPage()));
            }),
            _buildMenuItem(Icons.family_restroom, "Koneksi Keluarga", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFamilyPage()));
            }),
            _buildMenuItem(Icons.medication, "Pengingat Obat", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineReminderPage()));
            }),
            _buildMenuItem(Icons.settings, "Pengaturan Akun", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage()));
            }),
            _buildMenuItem(Icons.help, "Bantuan", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
            }),
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

  Future<void> _openEditProfile(BuildContext context) async {
    if (AuthService.currentUser == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePatientPage(user: AuthService.currentUser!),
      ),
    );
    setState(() {});
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
