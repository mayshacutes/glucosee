import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/models/user_model.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';

class ProfileNakesPage extends StatefulWidget {
  const ProfileNakesPage({super.key});

  @override
  State<ProfileNakesPage> createState() => _ProfileNakesPageState();
}

class _ProfileNakesPageState extends State<ProfileNakesPage> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 20),
            _menuItem(Icons.edit, "Edit Profil", () => _openEditPage(context, user)),
            _menuItem(Icons.history, "Riwayat Layanan", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur riwayat layanan segera hadir")),
              );
            }),
            _menuItem(Icons.settings, "Pengaturan", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur pengaturan segera hadir")),
              );
            }),
            const SizedBox(height: 10),
            _menuItem(Icons.logout, "Keluar", () {
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
            "${user?.name ?? '-'} ${user?.profession ?? ''}".trim(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (user == null) return;
              setState(() {
                user.isActive = !user.isActive;
                AuthService.updateUser(user);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: (user?.isActive ?? true) ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (user?.isActive ?? true) ? "Aktif" : "Nonaktif",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _infoRow(Icons.email, "Email", user?.email ?? '-'),
          _infoRow(Icons.phone, "Telepon", user?.phone ?? '-'),
          _infoRow(Icons.location_on, "Alamat", user?.address ?? '-'),
          _infoRow(
            Icons.cake,
            "Tanggal Lahir",
            user?.birthDate != null ? DateFormat('d MMM yyyy').format(user!.birthDate!) : '-',
          ),
          _infoRow(Icons.wc, "Jenis Kelamin", user?.gender ?? '-'),
          _infoRow(
            Icons.calendar_today,
            "Bergabung",
            user?.joinDate != null ? DateFormat('d MMM yyyy').format(user!.joinDate!) : '-',
          ),
          _infoRow(Icons.badge, "No. STR", user?.noStr ?? '-'),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                user?.rating?.toStringAsFixed(1) ?? '-',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                "${user?.patientCount ?? 0} pasien",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
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

  void _openEditPage(BuildContext context, UserModel? user) async {
    if (user == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileNakesPage(user: user)),
    );
    setState(() {});
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.primaryBlue),
          title: Text(title, style: GoogleFonts.poppins(color: color)),
          trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}

class EditProfileNakesPage extends StatefulWidget {
  final UserModel user;
  const EditProfileNakesPage({super.key, required this.user});

  @override
  State<EditProfileNakesPage> createState() => _EditProfileNakesPageState();
}

class _EditProfileNakesPageState extends State<EditProfileNakesPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _professionCtrl;
  late TextEditingController _noStrCtrl;
  String? _gender;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.name);
    _emailCtrl = TextEditingController(text: u.email);
    _phoneCtrl = TextEditingController(text: u.phone ?? '');
    _addressCtrl = TextEditingController(text: u.address ?? '');
    _professionCtrl = TextEditingController(text: u.profession ?? '');
    _noStrCtrl = TextEditingController(text: u.noStr ?? '');
    _gender = u.gender;
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan email tidak boleh kosong"), backgroundColor: Colors.red),
      );
      return;
    }
    final updated = widget.user.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      profession: _professionCtrl.text.trim(),
      noStr: _noStrCtrl.text.trim(),
      gender: _gender,
    );
    AuthService.updateUser(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _professionCtrl,
              decoration: const InputDecoration(labelText: "Profesi / Gelar", prefixIcon: Icon(Icons.medical_services)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: "Telepon", prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: "Alamat", prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: "Jenis Kelamin", prefixIcon: Icon(Icons.wc)),
              items: const [
                DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
                DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noStrCtrl,
              decoration: const InputDecoration(labelText: "No. STR", prefixIcon: Icon(Icons.badge)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("Simpan Perubahan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
