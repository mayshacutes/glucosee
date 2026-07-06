import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';

class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AuthService.getPendingPayments();
    if (!mounted) return;
    setState(() { _payments = data; _loading = false; });
  }

  Future<void> _verify(Map<String, dynamic> payment, bool approve) async {
    String? note;
    if (!approve) {
      final ctrl = TextEditingController();
      note = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Alasan Penolakan'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Tulis alasan penolakan...'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Kirim'),
            ),
          ],
        ),
      );
      if (note == null) return;
    }

    await AuthService.verifyPayment(
      payment['id'], payment['appointment_id'], approve, note: note);
    _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(approve ? 'Pembayaran disetujui' : 'Pembayaran ditolak'),
      backgroundColor: approve ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Verifikasi Pembayaran'),
        backgroundColor: AppColors.primaryBlue,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? const Center(child: Text('Tidak ada pembayaran pending', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _payments.length,
                  itemBuilder: (context, i) {
                    final p = _payments[i];
                    final isBpjs = p['payment_method'] == 'bpjs';
                    final createdAt = p['created_at'] != null ? DateTime.parse(p['created_at']) : null;

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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBpjs ? Colors.green.shade50 : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isBpjs ? 'BPJS' : 'Mandiri',
                                    style: TextStyle(
                                      color: isBpjs ? Colors.green : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(p['patient_name'] ?? '-',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(p['patient_email'] ?? '-',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            if (isBpjs && p['bpjs_number'] != null) ...[
                              const SizedBox(height: 4),
                              Text('No. BPJS: ${p['bpjs_number']}',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                            if (!isBpjs) ...[
                              const SizedBox(height: 4),
                              Text('Nominal: Rp ${NumberFormat('#,###').format(p['amount'] ?? 50000)}',
                                  style: const TextStyle(fontSize: 13)),
                              if (p['proof_url'] != null)
                                TextButton.icon(
                                  icon: const Icon(Icons.image, size: 16),
                                  label: const Text('Lihat Bukti Transfer'),
                                  onPressed: () {
                                    // TODO: open proof image
                                  },
                                ),
                            ],
                            if (createdAt != null)
                              Text(DateFormat('d MMM yyyy, HH:mm').format(createdAt),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                  label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _verify(p, false),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text('Setujui'),
                                  onPressed: () => _verify(p, true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}