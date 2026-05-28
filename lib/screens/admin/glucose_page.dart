import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class AdminGlucosePage extends StatelessWidget {
  const AdminGlucosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final records = [
      {"name": "Emberlia T.P.", "level": "164", "status": "Tinggi", "time": "08:30"},
      {"name": "Ahmad Fauzi", "level": "120", "status": "Normal", "time": "09:00"},
      {"name": "Siti Rahayu", "level": "95", "status": "Normal", "time": "09:15"},
      {"name": "Budi Santoso", "level": "185", "status": "Tinggi", "time": "10:00"},
      {"name": "Dewi Lestari", "level": "78", "status": "Rendah", "time": "10:30"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummary("Rata-rata", "128 mg/dL"),
                _buildSummary("Tertinggi", "185 mg/dL"),
                _buildSummary("Terendah", "78 mg/dL"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Data Gula Darah Pasien", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...records.map((r) {
            Color statusColor = r["status"] == "Tinggi"
                ? Colors.red
                : r["status"] == "Rendah"
                    ? Colors.orange
                    : Colors.green;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(Icons.bloodtype, color: statusColor),
                ),
                title: Text(r["name"]!),
                subtitle: Text("${r["level"]} mg/dL • ${r["time"]}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(r["status"]!, style: TextStyle(color: statusColor, fontSize: 11)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummary(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
