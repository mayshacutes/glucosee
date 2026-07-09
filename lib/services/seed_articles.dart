import 'package:glucosee/services/supabase_config.dart';

class SeedArticles {
  static Future<void> seed() async {
    final client = SupabaseConfig.client;

    final articles = [
      {
        'title': 'Apa Itu Diabetes Melitus? Panduan Lengkap untuk Pemula',
        'description': 'Memahami diabetes melitus, jenis-jenisnya, penyebab, serta cara pencegahan dan pengelolaannya.',
        'category': 'Edukasi Dasar',
        'content': '''Diabetes Melitus adalah penyakit metabolik kronis yang ditandai dengan kadar gula darah yang tinggi. Hal ini terjadi karena pankreas tidak dapat memproduksi cukup insulin, atau tubuh tidak dapat menggunakan insulin secara efektif.

Jenis-jenis Diabetes:

1. Diabetes Tipe 1
Diabetes tipe 1 adalah kondisi autoimun di mana sistem kekebalan tubuh menyerang sel-sel penghasil insulin di pankreas. Penderita diabetes tipe 1 memerlukan suntikan insulin setiap hari untuk bertahan hidup. Biasanya didiagnosis pada anak-anak dan remaja.

2. Diabetes Tipe 2
Ini adalah jenis diabetes yang paling umum, mencakup sekitar 90% dari seluruh kasus diabetes. Terjadi ketika tubuh menjadi resisten terhadap insulin atau tidak memproduksi cukup insulin. Faktor risiko utama termasuk obesitas, pola makan tidak sehat, dan kurang aktivitas fisik.

3. Diabetes Gestasional
Diabetes yang terjadi selama kehamilan dan biasanya hilang setelah melahirkan. Namun, wanita yang pernah mengalaminya memiliki risiko lebih tinggi terkena diabetes tipe 2 di kemudian hari.

Gejala Umum Diabetes:
- Sering buang air kecil (poliuria)
- Rasa haus yang berlebihan (polidipsia)
- Berat badan turun tanpa sebab jelas
- Mudah lelah dan lemas
- Luka yang sulit sembuh
- Penglihatan kabur

Pencegahan:
- Menjaga berat badan ideal
- Olahraga teratur minimal 30 menit per hari
- Pola makan sehat dengan mengurangi gula dan karbohidrat olahan
- Pemeriksaan gula darah rutin, terutama jika memiliki faktor risiko

Pengelolaan:
Pantau kadar gula darah secara teratur, konsumsi obat sesuai resep dokter, jaga pola makan, dan lakukan aktivitas fisik secara rutin. Edukasi diri dan keluarga mengenai diabetes sangat penting untuk pengelolaan jangka panjang yang baik.''',
        'is_published': true,
      },
      {
        'title': 'Pola Makan Sehat untuk Penderita Diabetes',
        'description': 'Panduan lengkap memilih makanan yang aman dan sehat untuk menjaga kadar gula darah tetap stabil.',
        'category': 'Nutrisi',
        'content': '''Mengatur pola makan adalah salah satu pilar utama dalam pengelolaan diabetes. Berikut adalah panduan lengkap pola makan sehat untuk penderita diabetes.

Prinsip Dasar:
- Makan teratur 3 kali sehari dengan porsi terkontrol
- Pilih karbohidrat kompleks yang kaya serat
- Batasi gula tambahan dan makanan olahan
- Perbanyak sayuran dan protein tanpa lemak

Makanan yang Dianjurkan:

1. Karbohidrat Kompleks
- Nasi merah atau beras coklat
- Roti gandum utuh
- Oatmeal
- Quinoa
- Ubi jalar

2. Protein Sehat
- Ikan (terutama salmon, tuna, sarden)
- Daging ayam tanpa kulit
- Tahu dan tempe
- Kacang-kacangan
- Telur

3. Sayuran
- Brokoli, bayam, kangkung
- Wortel, mentimun
- Tomat, paprika
- Selada dan sayuran hijau lainnya

4. Buah yang Aman
- Apel, pir, jeruk
- Beri-berian (stroberi, blueberry)
- Alpukat
- Semangka dalam jumlah terbatas

Makanan yang Harus Dihindari:
- Minuman manis seperti soda, jus kemasan, teh manis
- Makanan cepat saji dan gorengan
- Kue, donat, dan pastry
- Nasi putih dalam jumlah besar
- Makanan dengan indeks glikemik tinggi

Tips Praktis:
- Gunakan metode piring: 1/4 protein, 1/4 karbohidrat, 1/2 sayuran
- Baca label nutrisi pada kemasan makanan
- Minum air putih minimal 8 gelas sehari
- Hindari makan 2-3 jam sebelum tidur
- Catat asupan makanan harian untuk membantu kontrol gula darah

Konsultasikan dengan ahli gizi untuk mendapatkan rencana makan yang disesuaikan dengan kondisi dan kebutuhan spesifik Anda.''',
        'is_published': true,
      },
      {
        'title': 'Pentingnya Olahraga bagi Pengidap Diabetes',
        'description': 'Manfaat aktivitas fisik dalam mengontrol gula darah dan jenis olahraga yang paling direkomendasikan.',
        'category': 'Gaya Hidup',
        'content': '''Aktivitas fisik teratur sangat penting bagi pengidap diabetes. Olahraga membantu menurunkan kadar gula darah, meningkatkan sensitivitas insulin, dan menjaga berat badan ideal.

Manfaat Olahraga bagi Penderita Diabetes:

1. Menurunkan Gula Darah
Saat berolahraga, otot-otot tubuh menggunakan glukosa sebagai energi, sehingga kadar gula darah langsung berkurang. Efek ini dapat bertahan hingga 24 jam setelah berolahraga.

2. Meningkatkan Sensitivitas Insulin
Olahraga teratur membuat sel-sel tubuh lebih responsif terhadap insulin, sehingga gula darah lebih mudah masuk ke dalam sel.

3. Mengontrol Berat Badan
Kombinasi olahraga dan pola makan sehat membantu mencapai dan mempertahankan berat badan ideal, yang sangat penting untuk pengelolaan diabetes tipe 2.

4. Menjaga Kesehatan Jantung
Penderita diabetes memiliki risiko penyakit jantung yang lebih tinggi. Olahraga membantu memperkuat jantung dan memperlancar sirkulasi darah.

Jenis Olahraga yang Direkomendasikan:

1. Olahraga Aerobik (minimal 150 menit/minggu)
- Jalan cepat
- Bersepeda
- Berenang
- Senam aerobik
- Jogging ringan

2. Latihan Kekuatan (2-3 kali/minggu)
- Angkat beban ringan
- Push-up dan squat
- Latihan resistance band
- Yoga

3. Latihan Fleksibilitas
- Peregangan
- Pilates
- Tai chi

Tips Aman Berolahraga:
- Periksa gula darah sebelum dan sesudah olahraga
- Jangan berolahraga jika gula darah >250 mg/dL atau <70 mg/dL
- Bawa camilan untuk antisipasi hipoglikemia
- Minum air putih yang cukup
- Gunakan sepatu yang nyaman dan sesuai
- Mulai dengan intensitas rendah dan tingkatkan secara bertahap
- Konsultasikan dengan dokter sebelum memulai program olahraga baru

Yang Perlu Diwaspadai:
- Hipoglikemia (gula darah turun drastis) saat atau setelah olahraga
- Masalah kaki diabetes - periksa kaki secara rutin
- Dehidrasi
- Cedera sendi atau otot

Ingat, konsistensi lebih penting daripada intensitas. Lakukan olahraga secara teratur dan nikmati prosesnya!''',
        'is_published': true,
      },
      {
        'title': 'Cara Mengukur dan Memantau Gula Darah Mandiri',
        'description': 'Langkah-langkah melakukan pengecekan gula darah sendiri di rumah serta cara membaca hasilnya.',
        'category': 'Tips Praktis',
        'content': '''Memantau gula darah secara mandiri sangat penting bagi penderita diabetes. Dengan pemantauan rutin, Anda dapat mengontrol kondisi dan mencegah komplikasi.

Kapan Waktu yang Tepat untuk Cek Gula Darah?

1. Gula Darah Puasa
Dicek setelah berpuasa minimal 8 jam. Waktu terbaik adalah pagi hari sebelum sarapan. Nilai normal: 70-100 mg/dL.

2. Gula Darah 2 Jam Setelah Makan
Dicek 2 jam setelah makan pertama. Membantu mengevaluasi respons tubuh terhadap makanan. Nilai normal: <140 mg/dL.

3. Gula Darah Sewaktu
Dicek kapan saja tanpa persiapan khusus. Berguna untuk skrining awal. Nilai normal: <200 mg/dL.

4. Sebelum Tidur
Membantu mencegah hipoglikemia saat tidur malam.

Alat yang Dibutuhkan:
- Glukometer (alat cek gula darah)
- Strip tes yang sesuai
- Lancing device (jarum penusuk)
- Lancet (jarum steril)
- Kapas alkohol
- Buku catatan atau aplikasi pencatat

Langkah-langkah:

1. Cuci tangan dengan sabun dan air hangat
2. Siapkan alat dan strip tes
3. Masukkan strip ke dalam glukometer
4. Tusuk ujung jari dengan lancing device
5. Teteskan darah ke strip tes
6. Tunggu hasil (biasanya 5-10 detik)
7. Catat hasil di buku catatan

Tips Membaca Hasil:

Target Gula Darah untuk Penderita Diabetes:
- Puasa: 80-130 mg/dL
- 2 Jam setelah makan: <180 mg/dL
- HbA1c: <7%

Tips Tambahan:
- Ganti jari tusukan setiap kali untuk mengurangi rasa sakit
- Gunakan sisi jari, bukan ujung tengah
- Catat juga waktu, makanan terakhir, dan aktivitas fisik dalam catatan
- Bawa alat cek saat bepergian
- Kalibrasi alat sesuai petunjuk penggunaan

Catatan Penting:
Jika hasil pengukuran menunjukkan angka yang tidak biasa, ulangi pengecekan. Segera hubungi dokter jika gula darah sangat tinggi (>300 mg/dL) atau sangat rendah (<70 mg/dL) disertai gejala.

Konsultasikan target gula darah individual dengan dokter Anda, karena target dapat berbeda tergantung usia, durasi diabetes, dan kondisi kesehatan lainnya.''',
        'is_published': true,
      },
      {
        'title': 'Mengenal Komplikasi Diabetes dan Cara Mencegahnya',
        'description': 'Berbagai komplikasi yang dapat timbul akibat diabetes serta langkah-langkah pencegahan yang efektif.',
        'category': 'Edukasi Dasar',
        'content': '''Diabetes yang tidak dikelola dengan baik dapat menyebabkan berbagai komplikasi serius. Namun, dengan pengelolaan yang tepat, risiko komplikasi dapat dikurangi secara signifikan.

Komplikasi Jangka Pendek:

1. Hipoglikemia
Gula darah turun di bawah 70 mg/dL. Gejala: pusing, keringat dingin, gemetar, jantung berdebar. Penanganan: segera konsumsi 15 gram karbohidrat sederhana (3 sendok gula, 150 ml jus buah).

2. Hiperglikemia
Gula darah sangat tinggi (>300 mg/dL). Gejala: sering buang air kecil, haus berlebihan, lemas. Dapat berlanjut ke ketoasidosis diabetik (KAD) yang memerlukan penanganan medis darurat.

Komplikasi Jangka Panjang:

1. Neuropati Diabetik (Kerusakan Saraf)
Gejala: kesemutan, mati rasa, nyeri pada tangan dan kaki. Dapat menyebabkan luka yang tidak terasa dan berujung pada amputasi.

2. Nefropati Diabetik (Kerusakan Ginjal)
Diabetes adalah penyebab utama gagal ginjal. Pemeriksaan fungsi ginjal rutin sangat penting.

3. Retinopati Diabetik (Kerusakan Mata)
Dapat menyebabkan kebutaan. Pemeriksaan mata rutin setahun sekali sangat dianjurkan.

4. Penyakit Kardiovaskular
Penderita diabetes memiliki risiko 2-4 kali lebih tinggi terkena serangan jantung dan stroke.

5. Gangren dan Amputasi
Luka pada kaki yang tidak sembuh dapat menyebabkan infeksi berat dan berujung amputasi.

Cara Mencegah Komplikasi:

1. Kontrol Gula Darah
Jaga gula darah dalam rentang target. Lakukan pemantauan rutin dan patuhi pengobatan.

2. Pola Makan Sehat
Konsumsi makanan bergizi seimbang, batasi gula dan lemak jenuh.

3. Olahraga Teratur
Minimal 30 menit per hari, 5 kali seminggu.

4. Pemeriksaan Rutin
- Cek HbA1c setiap 3-6 bulan
- Pemeriksaan mata setahun sekali
- Pemeriksaan fungsi ginjal setahun sekali
- Pemeriksaan kaki setiap kali ke dokter

5. Perawatan Kaki
- Cuci kaki setiap hari dengan air hangat
- Keringkan terutama di sela jari
- Gunakan pelembab untuk kulit kering
- Pakai sepatu yang nyaman
- Periksa kaki setiap hari ada luka atau tidak

6. Stop Merokok
Merokok meningkatkan risiko komplikasi diabetes secara signifikan.

7. Kelola Stres
Stres dapat meningkatkan gula darah. Lakukan relaksasi, meditasi, atau hobi yang menyenangkan.

Ingatlah bahwa diabetes bukanlah akhir dari segalanya. Dengan pengelolaan yang baik, Anda tetap dapat menjalani hidup yang sehat, produktif, dan berkualitas. Selalu konsultasikan kondisi Anda dengan tim medis secara teratur.''',
        'is_published': true,
      },
    ];

    // Export to allow calling from outside if needed
    _insertArticles(client, articles);
  }

  static Future<void> _insertArticles(client, List<Map<String, dynamic>> articles) async {
    print('Seeding 5 articles...');
    for (final article in articles) {
      final existing = await client
          .from('articles')
          .select('id')
          .eq('title', article['title'])
          .maybeSingle();

      if (existing == null) {
        await client.from('articles').insert(article);
        print('  + Added: ${article['title']}');
      } else {
        print('  = Already exists: ${article['title']}');
      }
    }
    print('Seeding complete!');
  }

}
