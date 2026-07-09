import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucosee/theme/app_theme.dart';
import 'package:glucosee/services/supabase_config.dart';
import 'package:glucosee/services/auth_service.dart';
import 'package:glucosee/services/seed_articles.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final _client = SupabaseConfig.client;
  List<Map<String, dynamic>> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _client
        .from('articles')
        .select()
        .order('created_at', ascending: false);
    if (!mounted) return;
    setState(() {
      _articles = (rows as List).cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  Future<void> _togglePublish(Map<String, dynamic> article) async {
    final newStatus = !(article['is_published'] as bool? ?? false);
    await _client
        .from('articles')
        .update({'is_published': newStatus})
        .eq('id', article['id']);
    _load();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newStatus ? 'Artikel dipublikasikan' : 'Artikel disembunyikan'),
      backgroundColor: newStatus ? Colors.green : Colors.orange,
    ));
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: const Text('Artikel ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _client.from('articles').delete().eq('id', id);
      _load();
    }
  }

  void _openForm([Map<String, dynamic>? article]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleFormPage(article: article)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.article_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Belum ada artikel'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Artikel'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await SeedArticles.seed();
                          if (mounted) _load();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('5 artikel contoh berhasil ditambahkan!'),
                            backgroundColor: Colors.green,
                          ));
                        },
                        icon: const Icon(Icons.auto_stories),
                        label: const Text('Tambah 5 Artikel Contoh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _articles.length,
                    itemBuilder: (context, i) {
                      final a = _articles[i];
                      final isPublished = a['is_published'] as bool? ?? false;
                      final createdAt = a['created_at'] != null
                          ? DateTime.tryParse(a['created_at'])
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(a['title'] ?? '-',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isPublished
                                          ? Colors.green.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isPublished ? 'Published' : 'Draft',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isPublished ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (a['description'] != null) ...[
                                const SizedBox(height: 4),
                                Text(a['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                              if (createdAt != null) ...[
                                const SizedBox(height: 4),
                                Text(DateFormat('d MMM yyyy').format(createdAt),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                    onPressed: () => _openForm(a),
                                  ),
                                  TextButton.icon(
                                    icon: Icon(
                                      isPublished ? Icons.visibility_off : Icons.publish,
                                      size: 16,
                                      color: isPublished ? Colors.orange : Colors.green,
                                    ),
                                    label: Text(
                                      isPublished ? 'Sembunyikan' : 'Publish',
                                      style: TextStyle(
                                          color: isPublished ? Colors.orange : Colors.green),
                                    ),
                                    onPressed: () => _togglePublish(a),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                    label: const Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () => _delete(a['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ArticleFormPage extends StatefulWidget {
  final Map<String, dynamic>? article;
  const ArticleFormPage({super.key, this.article});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _client = SupabaseConfig.client;
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _categoryCtrl;
  bool _isPublished = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _titleCtrl = TextEditingController(text: a?['title'] ?? '');
    _descCtrl = TextEditingController(text: a?['description'] ?? '');
    _contentCtrl = TextEditingController(text: a?['content'] ?? '');
    _categoryCtrl = TextEditingController(text: a?['category'] ?? '');
    _isPublished = a?['is_published'] ?? false;
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Judul wajib diisi'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _saving = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'is_published': _isPublished,
      'created_by': AuthService.currentUser?.id,
    };

    if (widget.article != null) {
      await _client.from('articles').update(data).eq('id', widget.article!['id']);
    } else {
      await _client.from('articles').insert(data);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Artikel berhasil disimpan'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(widget.article == null ? 'Buat Artikel' : 'Edit Artikel'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field('Judul', _titleCtrl),
            _field('Kategori', _categoryCtrl),
            _field('Deskripsi Singkat', _descCtrl, maxLines: 2),
            _field('Konten Artikel', _contentCtrl, maxLines: 10),
            SwitchListTile(
              value: _isPublished,
              onChanged: (v) => setState(() => _isPublished = v),
              title: const Text('Langsung publish'),
              subtitle: const Text('Pasien bisa membaca artikel ini'),
              activeColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      child: const Text('Simpan Artikel')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}