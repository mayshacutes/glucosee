import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final List<Map<String, String>> _articles = [
    {"title": "Tips Mengontrol Gula Darah", "category": "Edukasi", "date": "28 Mei 2026"},
    {"title": "Pola Hidup Sehat untuk Diabetesi", "category": "Lifestyle", "date": "27 Mei 2026"},
    {"title": "Mengenal Insulin dan Cara Kerjanya", "category": "Medis", "date": "26 Mei 2026"},
  ];

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _addArticle() {
    if (_titleController.text.isEmpty) return;
    setState(() {
      _articles.insert(0, {
        "title": _titleController.text,
        "category": "Edukasi",
        "date": "28 Mei 2026",
      });
    });
    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Artikel berhasil ditambahkan"), backgroundColor: Colors.green),
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Artikel Baru"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Artikel",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Isi Artikel",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: _addArticle, child: const Text("Simpan")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _articles.isEmpty
          ? const Center(child: Text("Belum ada artikel"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(article["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${article["category"]} • ${article["date"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _articles.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Artikel dihapus"), backgroundColor: Colors.orange),
                        );
                      },
                    ),
                    onTap: () {
                      // Bisa ditambahkan detail artikel jika perlu
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: _showAddArticleDialog,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: "Tambah Artikel",
      ),
    );
  }
}
