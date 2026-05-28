import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class ResepPage extends StatefulWidget {
  const ResepPage({super.key});

  @override
  State<ResepPage> createState() => _ResepPageState();
}

class _ResepPageState extends State<ResepPage> {
  final _obatController = TextEditingController();
  final _dosisController = TextEditingController();
  final _pasienController = TextEditingController();

  final List<Map<String, String>> _resepList = [
    {"pasien": "Emberlia T.P.", "obat": "Metformin", "dosis": "500mg 2x sehari"},
    {"pasien": "Ahmad Fauzi", "obat": "Glimepiride", "dosis": "2mg 1x sehari"},
  ];

  void _addResep() {
    if (_obatController.text.isEmpty || _dosisController.text.isEmpty) return;
    setState(() {
      _resepList.add({
        "pasien": _pasienController.text.isEmpty ? "Pasien" : _pasienController.text,
        "obat": _obatController.text,
        "dosis": _dosisController.text,
      });
    });
    _obatController.clear();
    _dosisController.clear();
    _pasienController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resep berhasil ditambahkan"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resep Obat"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _resepList.length,
        itemBuilder: (context, index) {
          final resep = _resepList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(resep["pasien"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.medication, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text("Obat: ${resep["obat"]}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Text("Dosis: ${resep["dosis"]}"),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tambah Resep", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _pasienController,
              decoration: const InputDecoration(labelText: "Nama Pasien", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _obatController,
              decoration: const InputDecoration(labelText: "Nama Obat", prefixIcon: Icon(Icons.medication)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosisController,
              decoration: const InputDecoration(labelText: "Dosis", prefixIcon: Icon(Icons.schedule)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addResep,
                child: const Text("Simpan Resep"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
