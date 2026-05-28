import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class GlucoNetPage extends StatefulWidget {
  const GlucoNetPage({super.key});

  @override
  State<GlucoNetPage> createState() => _GlucoNetPageState();
}

class _GlucoNetPageState extends State<GlucoNetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _forumPosts = [
    {
      "user": "Ahmad R.",
      "text": "Tips menjaga gula darah tetap stabil saat puasa 🌙",
      "likes": 24,
      "comments": 8,
      "time": "2 jam lalu",
    },
    {
      "user": "Siti N.",
      "text": "Pengalaman saya menggunakan insulin pump selama 6 bulan",
      "likes": 45,
      "comments": 12,
      "time": "5 jam lalu",
    },
    {
      "user": "Budi S.",
      "text": "Resep makanan rendah gula yang enak! 🍳",
      "likes": 32,
      "comments": 15,
      "time": "1 hari lalu",
    },
  ];

  final List<Map<String, dynamic>> _groups = [
    {"name": "Diabetes Tipe 2 Support", "members": 156, "icon": Icons.group},
    {"name": "Diet Sehat Diabetes", "members": 89, "icon": Icons.restaurant},
    {"name": "Olahraga untuk Diabetesi", "members": 67, "icon": Icons.fitness_center},
  ];

  final List<Map<String, dynamic>> _privateChats = [
    {"name": "Ibu (Keluarga)", "lastMsg": "Gimana kadar gulanya hari ini?", "time": "10:30"},
    {"name": "Ayah (Keluarga)", "lastMsg": "Jangan lupa minum obat ya", "time": "09:15"},
    {"name": "Dr. Andi", "lastMsg": "Hasil lab sudah keluar", "time": "Kemarin"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GlucoNet"),
        backgroundColor: AppColors.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Forum", icon: Icon(Icons.forum, size: 18)),
            Tab(text: "Grup", icon: Icon(Icons.groups, size: 18)),
            Tab(text: "Chat", icon: Icon(Icons.chat, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForum(),
          _buildGroups(),
          _buildPrivateChats(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () => _showNewPostDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildForum() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _forumPosts.length,
      itemBuilder: (context, index) {
        final post = _forumPosts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                      child: Text(post["user"][0]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post["user"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(post["time"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post["text"]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text("${post["likes"]}"),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text("${post["comments"]}"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroups() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Icon(group["icon"], color: Colors.white),
            ),
            title: Text(group["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${group["members"]} anggota"),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Gabung", style: TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivateChats() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _privateChats.length,
      itemBuilder: (context, index) {
        final chat = _privateChats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.darkBlue,
              child: Text(chat["name"][0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(chat["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(chat["lastMsg"], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(chat["time"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {},
          ),
        );
      },
    );
  }

  void _showNewPostDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Post Baru"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Tulis sesuatu..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _forumPosts.insert(0, {
                    "user": "Kamu",
                    "text": controller.text,
                    "likes": 0,
                    "comments": 0,
                    "time": "Baru saja",
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }
}
