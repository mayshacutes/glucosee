import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_service.dart';

class GlucoseInputPage extends StatefulWidget {
  final String? preselectedPatientId;
  final String? preselectedPatientName;

  const GlucoseInputPage({
    super.key,
    this.preselectedPatientId,
    this.preselectedPatientName,
  });

  @override
  State<GlucoseInputPage> createState() => _GlucoseInputPageState();
}

class _GlucoseInputPageState extends State<GlucoseInputPage> {
  final _glucoseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _bodyTempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _hba1cCtrl = TextEditingController();
  final _cholesterolCtrl = TextEditingController();
  final _otherFindingsCtrl = TextEditingController();

  List<Map<String, String>> _patients = [];
  Map<String, String>? _selectedPatient;
  bool _loadingPatients = true;
  bool _saving = false;
  String? _conditionPreview;
  String _glucoseType = 'Sewaktu';

  final List<String> _glucoseTypes = ['Puasa', 'Sewaktu', 'Sesudah Makan', 'Sebelum Tidur'];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _glucoseCtrl.addListener(_updateConditionPreview);
  }

  void _updateConditionPreview() {
    final val = double.tryParse(_glucoseCtrl.text);
    if (val == null) {
      setState(() => _conditionPreview = null);
      return;
    }
    String c;
    if (val < 70) c = 'rendah';
    else if (val > 140) c = 'tinggi';
    else c = 'normal';
    setState(() => _conditionPreview = c);
  }

  Future<void> _loadPatients() async {
    final data = await MedicService.getApprovedPatients();
    if (!mounted) return;
    setState(() {
      _patients = data;
      _loadingPatients = false;
      if (widget.preselectedPatientId != null) {
        _selectedPatient = data.cast<Map<String, String>?>().firstWhere(
          (p) => p?['id'] == widget.preselectedPatientId,
          orElse: () => {'id': widget.preselectedPatientId!, 'name': widget.preselectedPatientName ?? 'Pasien'},
        );
      }
    });
  }

  Future<void> _save() async {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih pasien dulu'), backgroundColor: Colors.red));
      return;
    }
    final level = double.tryParse(_glucoseCtrl.text);
    if (level == null || level <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Masukkan kadar gula darah yang valid'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _saving = true);
    await MedicService.inputGlucoseRecord(
      patientId: _selectedPatient!['id']!,
      glucoseLevel: level,
      notes: _notesCtrl.text.trim(),
      systolic: int.tryParse(_systolicCtrl.text),
      diastolic: int.tryParse(_diastolicCtrl.text),
      heartRate: int.tryParse(_heartRateCtrl.text),
      bodyTemp: double.tryParse(_bodyTempCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      height: double.tryParse(_heightCtrl.text),
      hba1c: double.tryParse(_hba1cCtrl.text),
      cholesterol: double.tryParse(_cholesterolCtrl.text),
      glucoseType: _glucoseType,
      otherFindings: _otherFindingsCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Data pemeriksaan berhasil disimpan & keluarga diberitahu'),
      backgroundColor: Colors.green,
    ));
  }

  Color _conditionColor(String? c) {
    switch (c) {
      case 'tinggi': return Colors.red;
      case 'rendah': return Colors.orange;
      case 'normal': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _glucoseCtrl.dispose();
    _notesCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _heartRateCtrl.dispose();
    _bodyTempCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _hba1cCtrl.dispose();
    _cholesterolCtrl.dispose();
    _otherFindingsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Hasil Pemeriksaan Pasien'),
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
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data pemeriksaan akan otomatis terkirim ke pasien dan anggota keluarga yang terdaftar.',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Pilih Pasien', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _loadingPatients
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? const Text('Belum ada pasien dengan appointment disetujui',
                        style: TextStyle(color: Colors.grey))
                    : DropdownButtonFormField<Map<String, String>>(
                        value: _selectedPatient,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        items: _patients
                            .map((p) => DropdownMenuItem(value: p, child: Text(p['name']!)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPatient = v),
                      ),

            const SizedBox(height: 24),
            const Text('Tanda Vital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field('Tek. Sistolik', _systolicCtrl, 'mmHg', Icons.favorite, TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Tek. Diastolik', _diastolicCtrl, 'mmHg', Icons.favorite_border, TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field('Denyut Nadi', _heartRateCtrl, 'bpm', Icons.monitor_heart, TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Suhu Tubuh', _bodyTempCtrl, '°C', Icons.thermostat, const TextInputType.numberWithOptions(decimal: true)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field('Berat Badan', _weightCtrl, 'kg', Icons.monitor_weight, const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Tinggi Badan', _heightCtrl, 'cm', Icons.height, TextInputType.number),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Pemeriksaan Laboratorium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Jenis Pemeriksaan Gula', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _glucoseType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.science),
              ),
              items: _glucoseTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _glucoseType = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kadar Gula Darah', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _glucoseCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Contoh: 120',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                prefixIcon: const Icon(Icons.water_drop, color: Colors.red),
                                suffixText: 'mg/dL',
                              ),
                            ),
                          ),
                          if (_conditionPreview != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _conditionColor(_conditionPreview).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _conditionColor(_conditionPreview)),
                              ),
                              child: Text(
                                _conditionPreview!.toUpperCase(),
                                style: TextStyle(
                                  color: _conditionColor(_conditionPreview),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ReferenceChip('< 70', 'Rendah', Colors.orange),
                  _ReferenceChip('70-140', 'Normal', Colors.green),
                  _ReferenceChip('> 140', 'Tinggi', Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field('HbA1c', _hba1cCtrl, '%', Icons.bloodtype, const TextInputType.numberWithOptions(decimal: true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field('Kolesterol', _cholesterolCtrl, 'mg/dL', Icons.opacity, TextInputType.number),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Catatan & Temuan Lain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Catatan pemeriksaan, saran diet, dll...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.note),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otherFindingsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Temuan klinis lain, rencana tindak lanjut, rujukan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Icon(Icons.summarize),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan & Kirim Notifikasi'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String suffix, IconData icon, TextInputType keyboardType) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20),
        suffixText: suffix,
        isDense: true,
      ),
    );
  }
}

class _ReferenceChip extends StatelessWidget {
  final String range;
  final String label;
  final Color color;
  const _ReferenceChip(this.range, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(range, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
