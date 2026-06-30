import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/medic_data.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  @override
  Widget build(BuildContext context) {
    final items = [...MedicData.appointments]..sort((a, b) => a.date.compareTo(b.date));

    final Map<String, List<AppointmentItem>> grouped = {};
    for (final item in items) {
      final key = DateFormat('EEEE, d MMMM yyyy').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Request List"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: items.isEmpty
          ? const Center(child: Text("Tidak ada appointment", style: TextStyle(color: Colors.grey)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    ...entry.value.map((apt) => _appointmentTile(apt)),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _appointmentTile(AppointmentItem apt) {
    Color statusColor;
    switch (apt.status) {
      case AppointmentStatus.approved:
        statusColor = Colors.green;
        break;
      case AppointmentStatus.declined:
        statusColor = Colors.red;
        break;
      case AppointmentStatus.pending:
        statusColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
          child: Text(apt.patientName[0]),
        ),
        title: Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(apt.timeRange, style: const TextStyle(fontSize: 12)),
        trailing: apt.status == AppointmentStatus.pending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Setujui",
                    onPressed: () => setState(() => apt.status = AppointmentStatus.approved),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Tolak",
                    onPressed: () => setState(() => apt.status = AppointmentStatus.declined),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  apt.status == AppointmentStatus.approved ? "Disetujui" : "Ditolak",
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}