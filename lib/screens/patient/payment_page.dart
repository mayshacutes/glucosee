import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const PaymentPage({super.key, required this.appointment});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _method = 'mandiri';
  final _bpjsCtrl = TextEditingController();
  XFile? _proofFile;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Pembayaran Konsultasi'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info appointment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Konsultasi', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _detailRow('Dokter', widget.appointment['medic_name'] ?? '-'),
                  _detailRow('Tanggal', widget.appointment['appointment_date'] ?? '-'),
                  _detailRow('Waktu', widget.appointment['time_range'] ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Pilih metode
            Row(
              children: [
                Expanded(child: _methodCard('mandiri', 'Mandiri', Icons.account_balance, 'Rp 50.000')),
                const SizedBox(width: 10),
                Expanded(child: _methodCard('bpjs', 'BPJS', Icons.health_and_safety, 'Gratis')),
              ],
            ),
            const SizedBox(height: 20),

            // Form sesuai metode
            if (_method == 'mandiri') _buildMandiriForm(),
            if (_method == 'bpjs') _buildBpjsForm(),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(_method == 'bpjs' ? 'Ajukan Verifikasi BPJS' : 'Konfirmasi Pembayaran'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodCard(String value, String label, IconData icon, String price) {
    final selected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.primaryBlue, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            )),
            Text(price, style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white70 : Colors.grey,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMandiriForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transfer ke rekening berikut:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Bank BRI', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('008601168763504',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor rekening disalin')));
                    },
                    child: const Icon(Icons.copy, size: 18, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('a.n. RS. Universitas Airlangga', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Nominal: Rp 50.000',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Upload Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) setState(() => _proofFile = picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _proofFile != null ? Colors.green : Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _proofFile != null ? Icons.check_circle : Icons.upload_file,
                  size: 36,
                  color: _proofFile != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 6),
                Text(
                  _proofFile != null ? _proofFile!.name : 'Tap untuk pilih foto bukti transfer',
                  style: TextStyle(color: _proofFile != null ? Colors.green : Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBpjsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verifikasi BPJS memerlukan persetujuan admin. Proses 1x24 jam kerja.',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bpjsCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nomor Kartu BPJS (13 digit)',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_method == 'bpjs') {
      if (_bpjsCtrl.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Masukkan nomor BPJS yang valid'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    } else {
      if (_proofFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Upload bukti transfer dulu'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    setState(() => _loading = true);
    String? error;

    if (_method == 'bpjs') {
      error = await PatientService.submitBpjs(
        appointmentId: widget.appointment['id'],
        bpjsNumber: _bpjsCtrl.text.trim(),
        appointmentDate: DateTime.parse(widget.appointment['appointment_date']),
        timeStart: widget.appointment['time_range'] ?? '08.00',
      );
    } else {
      error = await PatientService.submitMandiriPayment(
        appointmentId: widget.appointment['id'],
        proofLocalPath: _proofFile!.path,
        appointmentDate: DateTime.parse(widget.appointment['appointment_date']),
        timeStart: widget.appointment['time_range'] ?? '08.00',
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $error'), backgroundColor: Colors.red));
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_method == 'bpjs'
          ? 'Pengajuan BPJS dikirim, menunggu verifikasi admin'
          : 'Bukti pembayaran dikirim, menunggu konfirmasi admin'),
      backgroundColor: Colors.green,
    ));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}