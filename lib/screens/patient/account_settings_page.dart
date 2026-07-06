import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/screens/auth/sign_in_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _client = SupabaseConfig.client;
  bool _notifOn = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final row = await _client
        .from('user_preferences')
        .select('notifications_on')
        .eq('user_id', AuthService.currentUser!.id)
        .maybeSingle();
    if (row != null) {
      setState(() => _notifOn = row['notifications_on'] ?? true);
    }
  }

  Future<void> _toggleNotif(bool v) async {
    setState(() => _notifOn = v);
    await _client.from('user_preferences').upsert({
      'user_id': AuthService.currentUser!.id,
      'notifications_on': v,
    });
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (newCtrl.text != confirmCtrl.text) {
        _showSnack('Password baru tidak cocok', Colors.red);
        return;
      }
      if (newCtrl.text.length < 6) {
        _showSnack('Password minimal 6 karakter', Colors.red);
        return;
      }
      try {
        await _client.auth.updateUser(UserAttributes(password: newCtrl.text));
        _showSnack('Password berhasil diubah', Colors.green);
      } catch (e) {
        _showSnack('Gagal: ${e.toString()}', Colors.red);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Semua data Anda akan dihapus permanen. Tindakan ini tidak bisa dibatalkan. Lanjutkan?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Akun Saya'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _client.rpc('delete_user_account', params: {'user_id': AuthService.currentUser!.id});
        await _client.auth.signOut();
        AuthService.currentUser = null;
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (route) => false,
        );
        _showSnack('Akun berhasil dihapus', Colors.green);
      } catch (e) {
        _showSnack('Gagal menghapus akun: ${e.toString()}', Colors.red);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notifOn,
                    onChanged: _toggleNotif,
                    title: const Text('Notifikasi'),
                    subtitle: const Text('Terima notifikasi dari aplikasi'),
                    activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                    secondary: const Icon(Icons.notifications, color: AppColors.primaryBlue),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.lock, color: AppColors.primaryBlue),
                    title: const Text('Ubah Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _changePassword,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Hapus Akun', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Hapus semua data Anda', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
