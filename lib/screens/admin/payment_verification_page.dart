import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';

class PaymentVerificationPage extends StatefulWidget {
  const PaymentVerificationPage({super.key});

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  List<Map<String, dynamic>> _allPayments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AuthService.getAllPayments();
    if (!mounted) return;
    setState(() {
      _allPayments = data;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _pending =>
      _allPayments.where((p) => p['status'] == 'pending').toList();

  List<Map<String, dynamic>> get _history =>
      _allPayments.where((p) => p['status'] != 'pending').toList();

  Future<void> _verify(String id, String appointmentId, bool approve) async {
    await AuthService.verifyPayment(id, appointmentId, approve);
    if (!mounted) return;
    _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(approve ? 'Pembayaran disetujui' : 'Pembayaran ditolak'),
      backgroundColor: approve ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.primaryBlue,
                    indicatorColor: AppColors.primaryBlue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Pending"),
                      Tab(text: "Riwayat"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildList(_pending, true),
                        _buildList(_history, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, bool isPending) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'Tidak ada pembayaran menunggu verifikasi'
                  : 'Belum ada riwayat pembayaran',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final p = list[i];
          final isBpjs = p['payment_method'] == 'bpjs';
          final status = p['status'] as String? ?? '';

          Color statusColor;
          String statusLabel;
          switch (status) {
            case 'approved':
              statusColor = Colors.green;
              statusLabel = 'Disetujui';
              break;
            case 'rejected':
              statusColor = Colors.red;
              statusLabel = 'Ditolak';
              break;
            default:
              statusColor = Colors.orange;
              statusLabel = 'Pending';
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            isBpjs ? Colors.blue : Colors.orange,
                        radius: 18,
                        child: Text(
                          (p['patient_name'] as String? ?? '?')[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['patient_name'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              p['patient_email'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isBpjs
                              ? Colors.blue.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isBpjs ? 'BPJS' : 'Mandiri',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isBpjs ? Colors.blue : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isBpjs)
                    _infoRow('No. BPJS', p['bpjs_number'] ?? '-')
                  else ...[
                    _infoRow('Total', 'Rp ${p['amount'] ?? 0}'),
                    if (p['proof_url'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p['proof_url'],
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Text('Gagal memuat bukti'),
                          ),
                        ),
                      ),
                  ],
                  if (isPending) ...[
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _verify(p['id'], p['appointment_id'], true),
                          icon: const Icon(Icons.check_circle,
                              size: 18, color: Colors.green),
                          label: const Text('Setujui',
                              style: TextStyle(color: Colors.green)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _verify(p['id'], p['appointment_id'], false),
                          icon: const Icon(Icons.cancel,
                              size: 18, color: Colors.red),
                          label: const Text('Tolak',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label : ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
