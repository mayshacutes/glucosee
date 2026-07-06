import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:glucosee/services/supabase_config.dart';

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

  List<Map<String, String>> _patients = [];
  Map<String, String>? _selectedPatient;
  bool _loadingPatients = true;
  bool _saving = false;
  String? _conditionPreview;
  String? _diabetesType;

  final _diabetesOptions = ['Tipe 1', 'Tipe 2', 'Gestasional', 'Pra-diabetes', 'Lainnya'];

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
        _selectedPatient = {
          'id': widget.preselectedPatientId!,
          'name': widget.preselectedPatientName ?? 'Pasien',
        };
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
    );

    if (_diabetesType != null) {
      await SupabaseConfig.client
          .from('patient_profiles')
          .update({'diabetes_type': _diabetesType})
          .eq('user_id', _selectedPatient!['id']!);
    }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Input Pemeriksaan Gula Darah'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
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

            const SizedBox(height: 12),
            const Text('Tipe Diabetes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _diabetesType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.medical_information),
              ),
              items: _diabetesOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _diabetesType = v),
            ),

            const SizedBox(height: 20),
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

            const SizedBox(height: 8),
            // Referensi nilai normal
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
                  _ReferenceChip('70–140', 'Normal', Colors.green),
                  _ReferenceChip('> 140', 'Tinggi', Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Kondisi pasien, saran diet, dll...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          ],
        ),
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