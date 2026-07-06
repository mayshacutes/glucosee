import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';
import 'package:glucosee/screens/patient/edit_profile_patient_page.dart';
import 'package:glucosee/screens/patient/glucose_history_page.dart';
import 'package:glucosee/screens/patient/appointment_patient_page.dart';
import 'package:glucosee/screens/patient/add_family_page.dart';
import 'package:glucosee/screens/patient/medicine_reminder_page.dart';
import 'package:glucosee/screens/patient/account_settings_page.dart';
import 'package:glucosee/screens/patient/help_page.dart';

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
            _buildProfileCard(user),
            const SizedBox(height: 20),
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

  Widget _buildProfileCard(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _uploadPhoto(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (user?.phone != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(user!.phone!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Diabetes ${user?.diabetesType ?? '-'}",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _openEditProfile(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text("Edit Profil", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    if (AuthService.currentUser == null) return;
    final url = await PatientService.uploadAvatar(AuthService.currentUser!.id);
    if (url != null && mounted) {
      AuthService.currentUser = AuthService.currentUser!.copyWith();
      setState(() {});
    }
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
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryBlue),
        title: Text(title, style: GoogleFonts.poppins(color: color)),
        trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
