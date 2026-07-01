import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/patient_service.dart';

class GlucoseHistoryPage extends StatefulWidget {
  const GlucoseHistoryPage({super.key});

  @override
  State<GlucoseHistoryPage> createState() => _GlucoseHistoryPageState();
}

class _GlucoseHistoryPageState extends State<GlucoseHistoryPage> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await PatientService.getGlucoseHistory();
    if (!mounted) return;
    setState(() { _records = data; _loading = false; });
  }

  Color _conditionColor(String? c) {
    switch (c) {
      case 'tinggi': return Colors.red;
      case 'rendah': return Colors.orange;
      default: return Colors.green;
    }
  }

  IconData _conditionIcon(String? c) {
    switch (c) {
      case 'tinggi': return Icons.arrow_upward;
      case 'rendah': return Icons.arrow_downward;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Riwayat Gula Darah'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Belum ada data pemeriksaan',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary card
                    _buildSummary(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, i) {
                          final r = _records[i];
                          final level = r['glucose_level'];
                          final condition = r['condition_status'] as String?;
                          final color = _conditionColor(condition);
                          final time = r['check_time'] != null
                              ? DateTime.parse(r['check_time'])
                              : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(_conditionIcon(condition),
                                        color: color, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$level mg/dL',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: color)),
                                        Text(
                                          condition?.toUpperCase() ?? '-',
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        if (r['notes'] != null && (r['notes'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(r['notes'],
                                                style: const TextStyle(
                                                    fontSize: 12, color: Colors.grey)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (time != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(DateFormat('d MMM').format(time),
                                            style: const TextStyle(
                                                fontSize: 11, color: Colors.grey)),
                                        Text(DateFormat('HH:mm').format(time),
                                            style: const TextStyle(
                                                fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummary() {
    if (_records.isEmpty) return const SizedBox();
    final levels = _records.map((r) => (r['glucose_level'] as num).toDouble()).toList();
    final avg = levels.reduce((a, b) => a + b) / levels.length;
    final max = levels.reduce((a, b) => a > b ? a : b);
    final min = levels.reduce((a, b) => a < b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Rata-rata', '${avg.toStringAsFixed(0)} mg/dL'),
          _summaryItem('Tertinggi', '$max mg/dL'),
          _summaryItem('Terendah', '$min mg/dL'),
          _summaryItem('Total', '${_records.length}x'),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}