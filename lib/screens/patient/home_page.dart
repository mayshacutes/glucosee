import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/patient_service.dart';
import 'package:glucosee/screens/patient/add_family_page.dart';
import 'package:glucosee/screens/patient/notifications_page.dart';
import 'package:glucosee/screens/patient/glucose_history_page.dart';
import 'package:glucosee/screens/patient/article_detail_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  Map<String, dynamic>? _latestGlucose;
  List<Map<String, dynamic>> _articles = [];
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      PatientService.getLatestGlucose(),
      PatientService.getPublishedArticles(),
    ]);
    if (!mounted) return;
    setState(() {
      _latestGlucose = results[0] as Map<String, dynamic>?;
      _articles = (results[1] as List).cast<Map<String, dynamic>>();
      _loading = false;
    });
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    final rows = await PatientService.getNotificationsUnreadCount();
    if (!mounted) return;
    setState(() => _unreadCount = rows);
  }

  Color _glucoseColor(String? condition) {
    switch (condition) {
      case 'tinggi': return const Color(0xffCC0000);
      case 'rendah': return Colors.orange;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final glucoseLevel = _latestGlucose?['glucose_level'];
    final condition = _latestGlucose?['condition_status'] as String?;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.menu, color: Colors.white),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.person_add, color: Colors.white),
                                    onPressed: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const AddFamilyPage()))
                                        .then((_) => _load()),
                                  ),
                                  Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.notifications, color: Colors.white),
                                        onPressed: () => Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (_) => const NotificationsPage()))
                                            .then((_) => _loadUnread()),
                                      ),
                                      if (_unreadCount > 0)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                                color: Colors.red, shape: BoxShape.circle),
                                            child: Center(
                                              child: Text('$_unreadCount',
                                                  style: const TextStyle(
                                                      color: Colors.white, fontSize: 9)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white24,
                                backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                                child: user?.photoUrl == null
                                    ? const Icon(Icons.person, size: 35, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? 'Pengguna',
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(user?.address ?? '-',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('Gula Darah',
                                  glucoseLevel != null ? '$glucoseLevel mg/dL' : 'Belum ada data',
                                  glucoseLevel != null ? _glucoseColor(condition) : Colors.white70),
                              _buildStat('Status',
                                  condition != null ? condition.toUpperCase() : '-',
                                  Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alert card
                          if (_latestGlucose != null && condition != 'normal')
                            _buildAlert(glucoseLevel, condition),

                          // Shortcut glucose history
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const GlucoseHistoryPage())),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.water_drop, color: Colors.red),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Riwayat Gula Darah',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text('Lihat semua hasil pemeriksaan',
                                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const Text('Glucourse - Edukasi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  _articles.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Belum ada artikel',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final a = _articles[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                child: _buildArticleCard(a),
                              );
                            },
                            childCount: _articles.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  Widget _buildAlert(dynamic level, String? condition) {
    final isHigh = condition == 'tinggi';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isHigh ? Colors.red.shade200 : Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHigh ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber, color: isHigh ? Colors.red : Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gula darahmu $level mg/dL',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  isHigh ? 'Di atas batas normal. Hubungi dokter segera.'
                      : 'Di bawah batas normal. Segera konsumsi makanan/minuman manis.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.article, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article['title'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (article['description'] != null)
                    Text(article['description'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (article['category'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(article['category'],
                          style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue)),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}