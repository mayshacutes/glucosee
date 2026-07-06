import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          TextButton(
            onPressed: () async {
              await PatientService.markAllRead();
              setState(() {});
            },
            child: const Text('Tandai semua dibaca',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: PatientService.notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snapshot.data ?? [];
          if (notifs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Tidak ada notifikasi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final unread = notifs.where((n) => (n['is_read'] as bool? ?? false) == false).toList();
          final read = notifs.where((n) => (n['is_read'] as bool? ?? false) == true).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unread.isNotEmpty) ...[
                _sectionHeader('Baru', unread.length, Colors.blue),
                const SizedBox(height: 8),
                ...unread.map((n) => _buildNotifItem(n)),
                const SizedBox(height: 20),
              ],
              if (read.isNotEmpty) ...[
                _sectionHeader('Riwayat', read.length, Colors.grey),
                const SizedBox(height: 8),
                ...read.map((n) => _buildNotifItem(n)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildNotifItem(Map<String, dynamic> n) {
    final isRead = n['is_read'] as bool? ?? false;
    final createdAt = n['created_at'] != null ? DateTime.parse(n['created_at']) : null;
    final isFamilyRequest = (n['title'] as String?)?.contains('Permintaan Pemantauan') ?? false;

    return GestureDetector(
      onTap: () async {
        if (!isRead) {
          await PatientService.markNotificationRead(n['id']);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : AppColors.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.grey.shade100 : AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRead ? Icons.notifications_off_outlined : Icons.notifications,
                    color: isRead ? Colors.grey : AppColors.primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n['title'] ?? '-',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 13,
                                color: isRead ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['message'] ?? '-',
                        style: TextStyle(fontSize: 12, color: isRead ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      if (createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('d MMM yyyy, HH:mm').format(createdAt),
                            style: TextStyle(fontSize: 10, color: isRead ? Colors.grey.shade300 : Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isFamilyRequest && !isRead) ...[
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: PatientService.getPendingFamilyRequests(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 20, child: LinearProgressIndicator());
                  }
                  final requests = snap.data ?? [];
                  if (requests.isEmpty) return const SizedBox();
                  final req = requests.first;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                          onPressed: () async {
                            await PatientService.respondFamilyRequest(req['id'], req['patient_id'], false);
                            if (!mounted) return;
                            await PatientService.markNotificationRead(n['id']);
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Terima'),
                          onPressed: () async {
                            await PatientService.respondFamilyRequest(req['id'], req['patient_id'], true);
                            if (!mounted) return;
                            await PatientService.markNotificationRead(n['id']);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
