import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/widgets/common_widgets.dart';

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final _emailController = TextEditingController();
  final _relationController = TextEditingController();
  String _selectedRelation = 'Orang Tua';

  final List<Map<String, String>> _connections = [
    {"name": "Ibu Sari", "relation": "Orang Tua", "status": "Terhubung"},
    {"name": "Ayah Budi", "relation": "Orang Tua", "status": "Terhubung"},
  ];

  void _addConnection() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _connections.add({
          "name": _emailController.text,
          "relation": _selectedRelation,
          "status": "Menunggu",
        });
      });
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan koneksi terkirim!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Keluarga/Teman"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new connection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tambah Koneksi Baru",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Tambahkan keluarga atau teman sebagai pemantau kondisi kesehatan kamu",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    label: "Email/Username",
                    hint: "Masukkan email atau username",
                    controller: _emailController,
                    prefixIcon: Icons.person_search,
                  ),
                  const Text("Hubungan", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedRelation,
                        items: const [
                          DropdownMenuItem(value: 'Orang Tua', child: Text('Orang Tua')),
                          DropdownMenuItem(value: 'Anak', child: Text('Anak')),
                          DropdownMenuItem(value: 'Pasangan', child: Text('Pasangan')),
                          DropdownMenuItem(value: 'Saudara', child: Text('Saudara')),
                          DropdownMenuItem(value: 'Teman', child: Text('Teman')),
                        ],
                        onChanged: (val) => setState(() => _selectedRelation = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(text: "Kirim Permintaan", onPressed: _addConnection),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Existing connections
            const Text(
              "Koneksi Saya",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._connections.map((conn) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(conn["name"]![0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(conn["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(conn["relation"]!),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: conn["status"] == "Terhubung"
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    conn["status"]!,
                    style: TextStyle(
                      fontSize: 11,
                      color: conn["status"] == "Terhubung" ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
