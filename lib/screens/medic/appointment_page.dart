import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_service.dart';
import 'package:glucosee/screens/medic/glucose_input_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<AppointmentModel> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await MedicService.getAppointments();
    if (!mounted) return;
    setState(() {
      _appointments = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(AppointmentModel apt, String status) async {
    await MedicService.updateAppointmentStatus(apt.id, status);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(status == 'approved'
          ? "${apt.patientName} disetujui"
          : "${apt.patientName} ditolak"),
      backgroundColor: status == 'approved' ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final sorted = [..._appointments]
      ..sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<AppointmentModel>> grouped = {};
    for (final item in sorted) {
      final key = DateFormat('EEEE, d MMMM yyyy').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Request List"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text("Tidak ada appointment",
                  style: TextStyle(color: Colors.grey)))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      ...entry.value.map((apt) => _appointmentTile(apt)),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _appointmentTile(AppointmentModel apt) {
    Color statusColor;
    String statusLabel;
    switch (apt.status) {
      case 'approved': statusColor = Colors.green; statusLabel = 'Disetujui'; break;
      case 'declined': statusColor = Colors.red; statusLabel = 'Ditolak'; break;
      default: statusColor = Colors.orange; statusLabel = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
              child: Text(apt.patientName[0]),
            ),
            title: Text(apt.patientName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(apt.timeRange, style: const TextStyle(fontSize: 12)),
            trailing: apt.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: "Setujui",
                        onPressed: () => _updateStatus(apt, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: "Tolak",
                        onPressed: () => _updateStatus(apt, 'declined'),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
          ),
          if (apt.status == 'approved')
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.water_drop, size: 16, color: Colors.red),
                      label: const Text('Input Pemeriksaan Gula Darah',
                          style: TextStyle(fontSize: 12)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GlucoseInputPage(
                            preselectedPatientId: apt.patientId,
                            preselectedPatientName: apt.patientName,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}