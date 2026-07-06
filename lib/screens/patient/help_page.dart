import 'package:flutter/material.dart';
import 'package:glucosee/theme/app_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final _faqs = const [
    _FaqData('Bagaimana cara mengganti password?',
        'Buka menu Profil > Pengaturan Akun > Ubah Password. Masukkan password lama dan baru Anda.'),
    _FaqData('Bagaimana cara menambah anggota keluarga?',
        'Buka menu Profil > Koneksi Keluarga. Masukkan email anggota keluarga yang ingin ditambahkan.'),
    _FaqData('Bagaimana cara membuat janji dengan nakes?',
        'Dari halaman utama, pilih nakes yang tersedia, lalu pilih tanggal dan jam yang diinginkan.'),
    _FaqData('Apa itu BPJS dan Mandiri?',
        'BPJS adalah pembayaran menggunakan nomor BPJS Kesehatan. Mandiri adalah pembayaran mandiri sebesar Rp 50.000 yang harus dibayar sebelum konsultasi.'),
    _FaqData('Bagaimana cara melihat riwayat gula darah?',
        'Buka menu Profil > Riwayat Kesehatan untuk melihat grafik dan riwayat gula darah Anda.'),
    _FaqData('Bagaimana cara menghubungi nakes?',
        'Setelah janji dikonfirmasi dan pembayaran diverifikasi, Anda bisa chat dengan nakes melalui menu Chat.'),
    _FaqData('Bagaimana cara mengatur pengingat obat?',
        'Buka menu Profil > Pengingat Obat. Tambah jadwal minum obat dengan nama, dosis, dan waktu.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pertanyaan Umum',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _faqs.asMap().entries.map((e) {
                  final i = e.key;
                  final faq = e.value;
                  return Column(
                    children: [
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      ExpansionTile(
                        title: Text(faq.question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(faq.answer, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqData {
  final String question;
  final String answer;
  const _FaqData(this.question, this.answer);
}
