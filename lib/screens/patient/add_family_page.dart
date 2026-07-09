import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final _emailCtrl = TextEditingController();
  String _relationship = 'Suami/Istri';
  List<Map<String, dynamic>> _connections = [];
  bool _loading = true;
  bool _saving = false;

  final List<String> _relationships = [
    'Suami/Istri', 'Anak', 'Orang Tua', 'Kakak/Adik', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getFamilyConnections();
    if (!mounted) return;
    setState(() { _connections = data; _loading = false; });
  }

  Future<void> _add() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final error = await PatientService.addFamilyByEmail(
        _emailCtrl.text.trim(), _relationship);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      _emailCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Anggota keluarga berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ));
      _load();
    }
  }

  Future<void> _remove(String connectionId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pemantau?'),
        content: Text('$name tidak akan lagi memantau kondisi kamu.'),
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
      await PatientService.removeFamilyConnection(connectionId);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pemantau Keluarga'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Text(
                'Tambahkan anggota keluarga agar mereka mendapat notifikasi otomatis setiap ada hasil pemeriksaan gula darahmu.',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tambah Pemantau', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email akun Glucosee anggota keluarga',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _relationship,
              decoration: InputDecoration(
                labelText: 'Hubungan',
                prefixIcon: const Icon(Icons.people),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _relationship = v!),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Tambahkan'),
                    ),
            ),
            const SizedBox(height: 24),
            const Text('Daftar Pemantau', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _connections.isEmpty
                    ? const Text('Belum ada anggota keluarga terhubung',
                        style: TextStyle(color: Colors.grey))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _connections.length,
                        itemBuilder: (context, i) {
                          final c = _connections[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                                child: Text((c['name'] as String)[0],
                                    style: const TextStyle(color: AppColors.primaryBlue)),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(c['name'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(c['relationship'] ?? '',
                                        style: TextStyle(fontSize: 9, color: AppColors.primaryBlue, fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              subtitle: Text(c['email'] ?? '',
                                  style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _remove(c['id'], c['name']),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}