import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';

class MedicineReminderPage extends StatefulWidget {
  const MedicineReminderPage({super.key});

  @override
  State<MedicineReminderPage> createState() => _MedicineReminderPageState();
}

class _MedicineReminderPageState extends State<MedicineReminderPage> {
  final _client = SupabaseConfig.client;
  List<Map<String, dynamic>> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _client
        .from('medicine_reminders')
        .select()
        .eq('user_id', AuthService.currentUser!.id)
        .order('created_at', ascending: false);
    if (!mounted) return;
    setState(() {
      _reminders = (rows as List).cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  Future<void> _toggle(Map<String, dynamic> r) async {
    final newActive = !(r['is_active'] as bool? ?? false);
    await _client
        .from('medicine_reminders')
        .update({'is_active': newActive})
        .eq('id', r['id']);
    _load();
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengingat?'),
        content: const Text('Pengingat ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _client.from('medicine_reminders').delete().eq('id', id);
      _load();
    }
  }

  void _openForm([Map<String, dynamic>? reminder]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ReminderFormPage(reminder: reminder)),
    ).then((_) => _load());
  }

  Future<void> _testNotification() async {
    await _client.from('notifications').insert({
      'receiver_id': AuthService.currentUser!.id,
      'sender_id': AuthService.currentUser!.id,
      'title': 'Test Notifikasi',
      'message': 'Ini adalah notifikasi uji coba dari Pengingat Obat',
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi test terkirim! Cek tab Notifikasi'), backgroundColor: Colors.green),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r) {
    final isActive = r['is_active'] as bool? ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.medication,
              color: isActive ? AppColors.primaryBlue : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['medicine_name'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${r['dose'] ?? '-'} — ${r['time'] ?? '-'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (_) => _toggle(r),
              activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _openForm(r),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _delete(r['id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pengingat Obat'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Belum ada pengingat obat', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._reminders.map((r) => _buildReminderCard(r)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _testNotification,
                          icon: const Icon(Icons.notifications, size: 18),
                          label: const Text('Test Notifikasi'),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ReminderFormPage extends StatefulWidget {
  final Map<String, dynamic>? reminder;
  const _ReminderFormPage({this.reminder});

  @override
  State<_ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<_ReminderFormPage> {
  final _client = SupabaseConfig.client;
  late TextEditingController _nameCtrl;
  late TextEditingController _doseCtrl;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _nameCtrl = TextEditingController(text: r?['medicine_name'] ?? '');
    _doseCtrl = TextEditingController(text: r?['dose'] ?? '');
    if (r?['time'] != null) {
      final parts = (r!['time'] as String).split(':');
      if (parts.length == 2) {
        _time = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih waktu minum'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);
    final timeStr = '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';
    final data = {
      'user_id': AuthService.currentUser!.id,
      'medicine_name': _nameCtrl.text.trim(),
      'dose': _doseCtrl.text.trim(),
      'time': timeStr,
      'is_active': true,
    };

    if (widget.reminder != null) {
      await _client.from('medicine_reminders').update(data).eq('id', widget.reminder!['id']);
    } else {
      await _client.from('medicine_reminders').insert(data);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengingat obat disimpan'), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Tambah Pengingat' : 'Edit Pengingat'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Obat',
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _doseCtrl,
              decoration: const InputDecoration(
                labelText: 'Dosis (mis: 1 tablet, 500 mg)',
                prefixIcon: Icon(Icons.balance),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Waktu Minum',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                child: Text(
                  _time != null
                      ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
                      : 'Pilih waktu',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
