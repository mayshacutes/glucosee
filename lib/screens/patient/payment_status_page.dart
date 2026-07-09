import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/screens/patient/payment_page.dart';

class PaymentStatusPage extends StatefulWidget {
  const PaymentStatusPage({super.key});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getMyAppointments();
    if (!mounted) return;
    setState(() {
      _appointments = data.where((a) {
        final ps = a['payment_status'] as String? ?? 'unpaid';
        return ps != 'unpaid' || a['status'] != 'pending';
      }).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Status Pembayaran"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("Belum ada riwayat pembayaran",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appointments.length,
                    itemBuilder: (context, i) => _buildCard(_appointments[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> apt) {
    final paymentStatus = apt['payment_status'] as String? ?? 'unpaid';
    final aptDate = DateTime.parse(apt['appointment_date']);
    final medicName = apt['medic_name'] ?? 'Dokter';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (paymentStatus) {
      case 'paid':
        statusColor = Colors.green;
        statusLabel = 'Lunas';
        statusIcon = Icons.check_circle;
        break;
      case 'pending_verification':
        statusColor = Colors.orange;
        statusLabel = 'Menunggu Verifikasi';
        statusIcon = Icons.access_time;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = 'Ditolak';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = 'Belum Dibayar';
        statusIcon = Icons.pending;
    }

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
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat('EEEE, d MMM yyyy').format(aptDate),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(apt['time_range'] ?? '-',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (apt['payment_method'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payment, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    apt['payment_method'] == 'bpjs' ? 'BPJS' : 'Mandiri',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (paymentStatus == 'unpaid') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Bayar Sekarang'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentPage(appointment: apt)),
                  ).then((_) => _load()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
