import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = [
      {"patient": "Ahmad Fauzi", "time": "10:00", "date": "28 Mei 2026", "type": "Kontrol"},
      {"patient": "Siti Rahayu", "time": "11:30", "date": "28 Mei 2026", "type": "Konsultasi"},
      {"patient": "Budi Santoso", "time": "13:00", "date": "28 Mei 2026", "type": "Home Visit"},
      {"patient": "Emberlia T.P.", "time": "14:30", "date": "29 Mei 2026", "type": "Kontrol"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final apt = appointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          apt["time"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Text(
                          apt["date"]!.split(" ")[0],
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt["patient"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(apt["date"]!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      apt["type"]!,
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                    ),
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
