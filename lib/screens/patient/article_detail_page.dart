import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final createdAt = article['created_at'] != null
        ? DateTime.tryParse(article['created_at'])
        : null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['category'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(article['category'],
                    style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            Text(article['title'] ?? '-',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (createdAt != null)
              Text(DateFormat('d MMMM yyyy').format(createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (article['description'] != null)
              Text(article['description'],
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            if (article['content'] != null)
              Text(article['content'],
                  style: const TextStyle(fontSize: 15, height: 1.7)),
          ],
        ),
      ),
    );
  }
}