import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_data.dart';

class ResepPage extends StatefulWidget {
  const ResepPage({super.key});

  @override
  State<ResepPage> createState() => _ResepPageState();
}

class _ResepPageState extends State<ResepPage> {
  @override
  Widget build(BuildContext context) {
    final list = MedicData.prescriptions;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Resep Obat"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: list.isEmpty
          ? const Center(child: Text("Belum ada resep dibuat", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final r = list[index];
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
                            Expanded(
                              child: Text(r.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility, size: 20, color: Colors.grey),
                              onPressed: () => _showDetail(context, r),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.medication, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            Text("Obat: ${r.namaObat}"),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text("Dosis: ${r.dosis} • ${r.frekuensi}"),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddResepFormPage()),
        ).then((_) => setState(() {})),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDetail(BuildContext context, Prescription r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _detailLine("ID Pasien", r.patientIdNumber),
            _detailLine("Usia", r.usia),
            _detailLine("Berat Badan", r.beratBadan),
            _detailLine("Jenis Kelamin", r.jenisKelamin),
            _detailLine("Diagnosis", r.diagnosis),
            _detailLine("Alergi", r.alergi),
            const Divider(height: 24),
            _detailLine("Nama Obat", r.namaObat),
            _detailLine("Dosis", r.dosis),
            _detailLine("Frekuensi", r.frekuensi),
            _detailLine("Aturan Pakai", r.aturanPakai),
            _detailLine("Catatan", r.catatan),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class AddResepFormPage extends StatefulWidget {
  const AddResepFormPage({super.key});

  @override
  State<AddResepFormPage> createState() => _AddResepFormPageState();
}

class _AddResepFormPageState extends State<AddResepFormPage> {
  final _namaPasien = TextEditingController();
  final _idPasien = TextEditingController();
  final _usia = TextEditingController();
  final _beratBadan = TextEditingController();
  final _jenisKelamin = TextEditingController();
  final _diagnosis = TextEditingController();
  final _alergi = TextEditingController();
  final _namaObat = TextEditingController();
  final _dosis = TextEditingController();
  final _frekuensi = TextEditingController();
  final _aturanPakai = TextEditingController();
  final _catatan = TextEditingController();

  void _simpan() {
    if (_namaPasien.text.trim().isEmpty || _namaObat.text.trim().isEmpty || _dosis.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama pasien, nama obat, dan dosis wajib diisi"), backgroundColor: Colors.red),
      );
      return;
    }
    MedicData.prescriptions.insert(
      0,
      Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: _namaPasien.text.trim(),
        patientIdNumber: _idPasien.text.trim(),
        usia: _usia.text.trim(),
        beratBadan: _beratBadan.text.trim(),
        jenisKelamin: _jenisKelamin.text.trim(),
        diagnosis: _diagnosis.text.trim(),
        alergi: _alergi.text.trim(),
        namaObat: _namaObat.text.trim(),
        dosis: _dosis.text.trim(),
        frekuensi: _frekuensi.text.trim(),
        aturanPakai: _aturanPakai.text.trim(),
        catatan: _catatan.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resep berhasil ditambahkan"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Tambah Resep"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informasi Pasien", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _field("Nama Pasien", _namaPasien),
            Row(
              children: [
                Expanded(child: _field("ID Pasien", _idPasien)),
                const SizedBox(width: 10),
                Expanded(child: _field("Usia", _usia, keyboard: TextInputType.number)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field("Berat Badan", _beratBadan)),
                const SizedBox(width: 10),
                Expanded(child: _field("Jenis Kelamin", _jenisKelamin)),
              ],
            ),
            _field("Diagnosis", _diagnosis),
            _field("Alergi", _alergi),
            const SizedBox(height: 10),
            const Text("Informasi Obat", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _field("Nama Obat", _namaObat),
            _field("Dosis", _dosis),
            Row(
              children: [
                Expanded(child: _field("Frekuensi", _frekuensi)),
                const SizedBox(width: 10),
                Expanded(child: _field("Aturan Pakai", _aturanPakai)),
              ],
            ),
            _field("Catatan/Instruksi", _catatan, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _simpan, child: const Text("Simpan Resep")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}