import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_service.dart';

class ResepPage extends StatefulWidget {
  const ResepPage({super.key});

  @override
  State<ResepPage> createState() => _ResepPageState();
}

class _ResepPageState extends State<ResepPage> {
  List<PrescriptionModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await MedicService.getPrescriptions();
    if (!mounted) return;
    setState(() {
      _list = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Resep Obat"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(
                  child: Text("Belum ada resep dibuat",
                      style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      final r = _list[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: AppColors.primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(r.patientName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        size: 20, color: Colors.grey),
                                    onPressed: () => _showDetail(context, r),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(children: [
                                const Icon(Icons.medication,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Text("Obat: ${r.namaObat}"),
                              ]),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.schedule,
                                    color: Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Text("Dosis: ${r.dosis} • ${r.frekuensi}"),
                              ]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () =>
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddResepFormPage()))
                .then((_) => _load()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDetail(BuildContext context, PrescriptionModel r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.patientName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _dl("ID Pasien", r.patientIdNumber),
              _dl("Usia", r.usia),
              _dl("Berat Badan", r.beratBadan),
              _dl("Jenis Kelamin", r.jenisKelamin),
              _dl("Diagnosis", r.diagnosis),
              _dl("Alergi", r.alergi),
              const Divider(height: 24),
              _dl("Nama Obat", r.namaObat),
              _dl("Dosis", r.dosis),
              _dl("Frekuensi", r.frekuensi),
              _dl("Aturan Pakai", r.aturanPakai),
              _dl("Catatan", r.catatan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dl(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12))),
            Expanded(
                child: Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}

class AddResepFormPage extends StatefulWidget {
  const AddResepFormPage({super.key});

  @override
  State<AddResepFormPage> createState() => _AddResepFormPageState();
}

class _AddResepFormPageState extends State<AddResepFormPage> {
  final _namaObat = TextEditingController();
  final _dosis = TextEditingController();
  final _frekuensi = TextEditingController();
  final _aturanPakai = TextEditingController();
  final _catatan = TextEditingController();
  final _usia = TextEditingController();
  final _beratBadan = TextEditingController();
  final _jenisKelamin = TextEditingController();
  final _diagnosis = TextEditingController();
  final _alergi = TextEditingController();

  List<Map<String, String>> _patients = [];
  Map<String, String>? _selectedPatient;
  bool _loading = false;
  bool _loadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final data = await MedicService.getMyPatients();
    if (!mounted) return;
    setState(() {
      _patients = data;
      _loadingPatients = false;
    });
  }

  Future<void> _simpan() async {
    if (_selectedPatient == null || _namaObat.text.isEmpty || _dosis.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pilih pasien, nama obat, dan dosis wajib diisi"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _loading = true);
    await MedicService.addPrescription(
      patientName: _selectedPatient!['name']!,
      patientId: _selectedPatient!['id'],
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
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Resep berhasil disimpan"),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
          title: const Text("Tambah Resep"),
          backgroundColor: AppColors.primaryBlue),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informasi Pasien",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _loadingPatients
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Map<String, String>>(
                    value: _selectedPatient,
                    decoration: InputDecoration(
                      labelText: "Pilih Pasien (dari appointment)",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _patients
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p['name']!),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPatient = v),
                  ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field("Usia", _usia, keyboard: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _field("Berat Badan", _beratBadan)),
            ]),
            _field("Jenis Kelamin", _jenisKelamin),
            _field("Diagnosis", _diagnosis),
            _field("Alergi", _alergi),
            const SizedBox(height: 10),
            const Text("Informasi Obat",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _field("Nama Obat", _namaObat),
            _field("Dosis", _dosis),
            Row(children: [
              Expanded(child: _field("Frekuensi", _frekuensi)),
              const SizedBox(width: 10),
              Expanded(child: _field("Aturan Pakai", _aturanPakai)),
            ]),
            _field("Catatan/Instruksi", _catatan, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _simpan,
                      child: const Text("Simpan Resep")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}