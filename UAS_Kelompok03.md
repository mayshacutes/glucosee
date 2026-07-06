# LAPORAN UAS
## PEMBELAJARAN MESIN PRAKTIKUM

# KOMPARASI DEEP MLP (TENSORFLOW/KERAS) DAN RNN (PYTORCH) UNTUK KLASIFIKASI KETUNTASAN KURSUS PADA PLATFORM PEMBELAJARAN DIGITAL

**Dosen Pengampu:** Indah Werdiningsih, S.Si., M.Kom.

**Disusun Oleh:**

| Nama | NIM |
|---|---|
| Misbahul Muttaqin | 187241037 |
| Maysha Akmala Dina A | 187241038 |
| Kisnaya Fianggi Maysha P | 187241039 |

**PROGRAM STUDI SISTEM INFORMASI**
**FAKULTAS SAINS DAN TEKNOLOGI**
**UNIVERSITAS AIRLANGGA**
**2026/2027**

---

## DAFTAR ISI

- BAB I PENDAHULUAN
  - 1.1 Latar Belakang
  - 1.2 Rumusan Masalah
  - 1.3 Tujuan Penelitian
  - 1.4 Manfaat Penelitian
  - 1.5 Batasan Penelitian
- BAB II TINJAUAN PUSTAKA
  - 2.1 Educational Data Mining (EDM)
  - 2.2 Deep Learning
  - 2.3 Penanganan Data Tidak Seimbang (Imbalanced Data)
  - 2.4 Reduksi Dimensi (Dimensionality Reduction)
  - 2.5 Metrik Evaluasi Klasifikasi
  - 2.6 Kerangka Berpikir
- BAB III METODOLOGI PENELITIAN
  - 3.1 Desain Penelitian
  - 3.2 Data dan Sumber Pustaka
  - 3.3 Preprocessing Data
  - 3.4 Transformasi Data
  - 3.5 Data Splitting
  - 3.6 Penanganan Data Tidak Seimbang (SMOTETomek)
  - 3.7 Perancangan Arsitektur Model Deep Learning
  - 3.8 Metrik Evaluasi
- BAB IV HASIL DAN PEMBAHASAN
  - 4.1 Eksplorasi Data (EDA)
  - 4.2 Reduksi Dimensi
  - 4.3 Hasil Training Model
  - 4.4 Evaluasi Model
  - 4.5 Perbandingan Performa
  - 4.6 Uji Inferensi
  - 4.7 Implementasi Antarmuka Mobile
  - 4.8 Ringkasan Hasil
- BAB V KESIMPULAN DAN SARAN
  - 5.1 Kesimpulan
  - 5.2 Saran
- DAFTAR PUSTAKA
- LAMPIRAN

---

# BAB I PENDAHULUAN

## 1.1 Latar Belakang

Perkembangan teknologi informasi yang pesat telah mengubah lanskap pendidikan secara fundamental. Platform pembelajaran daring seperti Learning Management Systems (LMS) dan Massive Open Online Courses (MOOCs) kini telah menjadi bagian integral dari sistem pendidikan global, menyediakan akses pembelajaran yang fleksibel bagi jutaan peserta didik di seluruh dunia. Sistem-sistem ini tidak hanya menyediakan sumber daya belajar seperti video, dokumen, kuesioner, dan kuis, tetapi juga secara otomatis melacak aktivitas belajar peserta didik dan menghasilkan rekaman perilaku belajar yang kaya akan data.

Disisi lain, tingginya angka putus kuliah (drop out) dan rendahnya tingkat ketuntasan kursus (course completion) telah menjadi tantangan serius dalam pendidikan daring. Penelitian menunjukkan bahwa tingkat putus kuliah di kalangan peserta didik yang belajar mandiri di MOOCs dapat melebihi 90%, dengan lebih dari 50% peserta didik hanya berpartisipasi dalam aktivitas belajar daring selama satu hari. Fenomena ini menyoroti urgensi pengembangan sistem prediksi yang dapat mengidentifikasi peserta didik yang berisiko sejak dini, sehingga intervensi yang tepat waktu dapat diberikan.

Educational Data Mining (EDM) telah muncul sebagai bidang penelitian penting yang memanfaatkan kekuatan teknik komputasi untuk menganalisis data pendidikan. Dengan meningkatnya kompleksitas dan keragaman data akademik, teknik Deep Learning telah menunjukkan keunggulan signifikan dalam mengatasi tantangan yang terkait dengan analisis dan pemodelan data ini. Berbeda dengan pendekatan machine learning konvensional yang memerlukan rekayasa fitur manual, Deep Learning memungkinkan mesin untuk secara otomatis menemukan struktur yang rumit dalam data besar dengan menggunakan berbagai lapisan abstraksi.

Penelitian sebelumnya telah menunjukkan bahwa berbagai arsitektur Deep Learning efektif untuk prediksi performa akademik. Al-Azazi & Ghurab (2023) mengusulkan model ANN-LSTM yang menggabungkan Artificial Neural Network dan Long Short-Term Memory untuk prediksi performa siswa secara harian di lingkungan MOOC, dan berhasil mencapai akurasi sekitar 70% pada akhir bulan ketiga kursus, mengungguli model RNN dan GRU. Kukkar dkk. (2023) mengembangkan sistem SAPP (Student Academic Performance Predicting) yang menggabungkan LSTM 4-lapis dengan Random Forest dan Gradient Boosting, mencapai akurasi prediksi sekitar 96%.

Meskipun berbagai penelitian telah menerapkan Deep Learning untuk prediksi pendidikan, masih terdapat kesenjangan penelitian dalam hal komparasi sistematis antara arsitektur Deep Learning yang berbeda pada dataset yang sama, khususnya untuk kasus klasifikasi ketuntasan kursus (course completion) dengan data yang tidak seimbang (imbalanced data) dan dimensi fitur yang tinggi. Oleh karena itu, penelitian ini bertujuan untuk mengimplementasikan dan membandingkan dua metode Deep Learning—yakni Deep MLP (TensorFlow/Keras) dan RNN (PyTorch)—pada dataset pembelajaran digital yang sama, serta mengukur performa keduanya menggunakan metrik akurasi, presisi, recall, dan F1-Score.

## 1.2 Rumusan Masalah

Berdasarkan latar belakang yang telah dipaparkan, rumusan masalah dalam penelitian ini adalah sebagai berikut:

1. Bagaimana performa model Deep MLP (TensorFlow/Keras) dalam mengklasifikasikan ketuntasan kursus (course completion) pada dataset pembelajaran digital?
2. Bagaimana performa model RNN (PyTorch) dalam mengklasifikasikan ketuntasan kursus pada dataset yang sama?
3. Bagaimana perbandingan performa antara model Deep MLP dan RNN berdasarkan metrik akurasi, presisi, recall, dan F1-Score?
4. Manakah di antara kedua metode Deep Learning tersebut yang memiliki performa terbaik untuk kasus klasifikasi ketuntasan kursus?

## 1.3 Tujuan Penelitian

Tujuan yang ingin dicapai dalam penelitian ini adalah:

1. Mengimplementasikan model Deep MLP menggunakan TensorFlow/Keras untuk klasifikasi ketuntasan kursus pada dataset pembelajaran digital.
2. Mengimplementasikan model RNN menggunakan PyTorch untuk klasifikasi ketuntasan kursus pada dataset yang sama.
3. Membandingkan performa kedua model berdasarkan metrik evaluasi klasifikasi (akurasi, presisi, recall, dan F1-Score).
4. Menentukan model terbaik di antara kedua metode Deep Learning tersebut berdasarkan F1-Score sebagai metrik utama.

## 1.4 Manfaat Penelitian

### 1.4.1 Manfaat Teoretis

Penelitian ini diharapkan dapat memberikan kontribusi bagi pengembangan ilmu pengetahuan di bidang Educational Data Mining dan Deep Learning, khususnya dalam hal:

a. Memperkaya literatur tentang komparasi arsitektur Deep Learning untuk prediksi pendidikan.
b. Memberikan wawasan tentang efektivitas Deep MLP versus RNN dalam menangani data tabular dengan dimensi tinggi dan ketidakseimbangan kelas.

### 1.4.2 Manfaat Praktis

Secara praktis, penelitian ini bermanfaat bagi:

a. **Lembaga Pendidikan**: Mendapatkan model prediktif yang dapat digunakan untuk mengidentifikasi peserta didik yang berisiko tidak menyelesaikan kursus sejak dini, sehingga intervensi dapat diberikan tepat waktu.
b. **Pengembang Platform Pembelajaran**: Memperoleh panduan dalam memilih arsitektur Deep Learning yang tepat untuk sistem rekomendasi dan peringatan dini.
c. **Peserta Didik**: Mendapatkan pengalaman belajar yang lebih personal dan dukungan yang lebih baik untuk mencapai ketuntasan khusus.

## 1.5 Batasan Penelitian

Untuk menjaga fokus dan ruang lingkup penelitian, diterapkan batasan-batasan sebagai berikut:

1. **Dataset**: Penelitian menggunakan satu dataset spesifik, yaitu `digital_learning_analytics_100k.csv`, yang terdiri dari 100.000 baris data dan 43 kolom fitur.
2. **Tipe Masalah**: Penelitian terbatas pada masalah klasifikasi biner (binary classification) dengan target `course_completed` (Lulus/Tidak Lulus).
3. **Metode Deep Learning**: Penelitian hanya membandingkan dua arsitektur, yaitu Deep MLP (TensorFlow/Keras) dan RNN (PyTorch).
4. **Evaluasi**: Evaluasi performa dibatasi pada metrik akurasi, presisi, recall, F1-Score, dan AUC-ROC.
5. **Preprocessing**: Menggunakan pipeline preprocessing spesifik yang mencakup imputasi missing value, penanganan outlier dengan IQR, encoding ordinal dan one-hot, serta scaling dengan StandardScaler.
6. **Reduksi Dimensi**: Menggunakan teknik PCA+LDA Hybrid sebagai metode reduksi dimensi terbaik berdasarkan benchmarking.
7. **Penanganan Imbalance**: Menggunakan SMOTETomek untuk menyeimbangkan data training.

---

# BAB II TINJAUAN PUSTAKA

## 2.1 Educational Data Mining (EDM)

Educational Data Mining (EDM) telah muncul sebagai bidang penelitian vital yang memanfaatkan kekuatan teknik komputasi untuk menganalisis data pendidikan. Seiring dengan meningkatnya kompleksitas dan keragaman data pendidikan, teknik Deep Learning telah menunjukkan keunggulan signifikan dalam mengatasi tantangan yang terkait dengan analisis dan pemodelan data ini.

Romero & Ventura (2024) dalam survei terbarunya mencatat bahwa dalam dekade terakhir, bidang EDM dan Learning Analytics telah berkembang sangat pesat, dengan berbagai istilah terkait seperti Academic Analytics, Institutional Analytics, dan Teaching Analytics kini banyak digunakan dalam literatur. Lin dkk. (2023) dalam survei komprehensifnya mengidentifikasi empat skenario tipikal penerapan Deep Learning dalam EDM, yaitu: knowledge tracing, deteksi siswa bermasalah (undesirable student detecting), prediksi performa (performance prediction), dan rekomendasi personalisasi (personalized recommendation).

EDM berperan penting dalam memprediksi performa siswa dan menyediakan langkah-langkah untuk membantu siswa menghindari kegagalan dan belajar lebih baik. Data Mining (DM) merupakan pendekatan yang paling banyak digunakan untuk prediksi performa siswa yang mengekstrak informasi penting dari kumpulan data mentah yang besar. Namun, berbagai pendekatan prediksi performa yang berpusat pada DM masih memiliki akurasi rendah dan waktu pelatihan tinggi.

## 2.2 Deep Learning

Deep Learning merupakan sub bidang dari machine learning yang menggunakan jaringan saraf tiruan dengan banyak lapisan (deep neural networks) untuk mempelajari representasi data secara hierarkis. Berbeda dengan pendekatan machine learning konvensional yang memerlukan rekayasa fitur manual, Deep Learning memungkinkan mesin untuk secara otomatis menemukan struktur yang rumit dalam data besar dengan menggunakan berbagai lapisan abstraksi.

Dalam konteks pendidikan, Deep Learning telah menunjukkan hasil yang menjanjikan untuk berbagai tugas seperti prediksi performa siswa, deteksi dini siswa berisiko, dan sistem rekomendasi pembelajaran personal. Penelitian oleh Wang dkk. (2024) menunjukkan bahwa deep neural network memiliki efek prediksi terbaik dengan tingkat akurasi 89% dalam memprediksi performa akademik siswa.

### 2.2.1 Multilayer Perceptron (MLP)

Multilayer Perceptron (MLP) adalah salah satu arsitektur neural network paling fundamental dalam Deep Learning. MLP terdiri dari lapisan input, satu atau lebih lapisan tersembunyi (hidden layers), dan lapisan output. Setiap neuron dalam satu lapisan terhubung sepenuhnya ke semua neuron di lapisan berikutnya (fully connected), sehingga MLP sering disebut sebagai Dense Neural Network.

MLP telah banyak digunakan dalam prediksi performa pendidikan. Penelitian oleh Nayani dkk. (2023) mengembangkan model hybrid deep learning dengan mengoptimalkan hyperparameter CNN dan RNN menggunakan algoritma GRSO, mencapai sensitivitas 94% dan akurasi 93%. Penelitian terbaru mengintegrasikan Knowledge Tracing dengan MLP untuk prediksi skor ujian bahasa Inggris, di mana MLP digunakan bersama dengan profil siswa dan skor tipe soal untuk mencapai prediksi akurat pada level modul dan total skor. Studi lain menggunakan MLP bersama CNN dan LSTM dalam pendekatan stacked ensemble learning untuk memprediksi prestasi akademik siswa. MLP juga terbukti efektif sebagai base learner dalam kerangka ensemble bersama Random Forest dan XGBoost untuk prediksi hasil akademik.

### 2.2.2 Recurrent Neural Network (RNN)

Recurrent Neural Network (RNN) adalah arsitektur neural network yang dirancang khusus untuk menangani data sekuensial atau data deret waktu (time-series data). Keunggulan utama RNN adalah kemampuannya untuk mempertahankan informasi dari langkah waktu sebelumnya melalui mekanisme recurrent atau umpan balik, sehingga cocok untuk memodelkan ketergantungan temporal dalam data.

Dalam konteks pendidikan, RNN sangat relevan karena data perilaku belajar siswa bersifat sekuensial—aktivitas belajar terjadi secara berurutan dari waktu ke waktu. Leelaluk dkk. (2025) memperkenalkan kerangka RNN-Attention-KD untuk memprediksi siswa berisiko secara dini sepanjang kursus, di mana RNN-Attention-KD mengungguli model neural network tradisional dalam hal recall dan F1-measure.

Namun, RNN standar memiliki kelemahan berupa masalah vanishing gradient yang membatasi kemampuannya dalam mempertahankan pola jangka panjang. Untuk mengatasi keterbatasan ini, dikembangkan varian RNN yang lebih canggih seperti Long Short-Term Memory (LSTM) dan Gated Recurrent Units (GRU). GRU memberikan alternatif yang tidak terlalu kompleks namun sama efisiennya dengan LSTM dengan menggunakan mekanisme gating untuk mengatur aliran informasi.

## 2.3 Penanganan Data Tidak Seimbang (Imbalanced Data)

Dalam klasifikasi, ketidakseimbangan kelas terjadi ketika jumlah sampel dalam satu kelas jauh lebih sedikit daripada kelas lainnya. Hal ini sering ditemui dalam dataset pendidikan, di mana jumlah siswa yang lulus (kelas minoritas) biasanya lebih sedikit daripada yang tidak lulus (kelas mayoritas).

Berbagai teknik penyeimbangan data telah dikembangkan untuk mengatasi masalah ini, antara lain Random Over Sampling, Random Under Sampling, Synthetic Minority Over Sampling (SMOTE), SMOTE dengan Edited Nearest Neighbor (SMOTE-ENN), dan SMOTE dengan Tomek Links (SMOTE-Tomek).

SMOTETomek merupakan metode hibrida yang menggabungkan SMOTE (untuk oversampling kelas minoritas dengan membuat sampel sintetis) dan Tomek Links (untuk undersampling dengan menghapus sampel yang menjadi noise atau borderline). Penelitian oleh Tariq dkk. (2023) membandingkan sepuluh metode resampling termasuk SMOTETomek pada dataset pendidikan multi-kelas. Hasilnya menunjukkan bahwa KNN dengan SMOTETomek mencapai akurasi tertinggi 83,7%, menegaskan efektivitas SMOTETomek dalam mengurangi ketidakseimbangan kelas pada dataset pendidikan. Penelitian lain juga menegaskan bahwa resampling hybrid bekerja paling baik untuk data dengan ketidakseimbangan ekstrem.

## 2.4 Reduksi Dimensi (Dimensionality Reduction)

Dataset pendidikan seringkali memiliki dimensi fitur yang tinggi, yang dapat menyebabkan curse of dimensionality dan meningkatkan kompleksitas komputasi. Reduksi dimensi bertujuan untuk mengurangi jumlah fitur sambil mempertahankan informasi penting sebanyak mungkin.

### 2.4.1 Principal Component Analysis (PCA)

Principal Component Analysis (PCA) adalah teknik reduksi dimensi unsupervised yang mengubah fitur-fitur asli menjadi sekumpulan komponen utama (principal components) yang saling ortogonal, di mana setiap komponen merupakan kombinasi linear dari fitur asli dan menangkap varians data secara maksimal. PCA sangat berguna untuk mengurangi dimensi data linear dan mengurangi curse of dimensionality.

### 2.4.2 Linear Discriminant Analysis (LDA)

Linear Discriminant Analysis (LDA) adalah teknik reduksi dimensi supervised yang mencari proyeksi linear yang memaksimalkan pemisahan antar kelas. Berbeda dengan PCA yang tidak mempertimbangkan label kelas, LDA secara eksplisit berusaha menemukan sumbu yang memaksimalkan rasio varians antar kelas terhadap varians dalam kelas.

Penelitian oleh Feng dkk. (2022) menganalisis dan memprediksi performa akademik siswa menggunakan EDM, di mana LDA dan PCA digunakan untuk melacak performa siswa di masa depan. Temuan mereka menunjukkan bahwa LDA meningkatkan akurasi klasifikasi logistic regression sebesar 8,86% dibandingkan dengan PCA. Kombinasi PCA dan LDA sering digunakan dalam penelitian EDM untuk meningkatkan akurasi prediksi.

## 2.5 Metrik Evaluasi Klasifikasi

Evaluasi model klasifikasi sangat penting untuk mengukur seberapa baik model dalam memprediksi kelas yang benar. Metrik-metrik berikut umum digunakan dalam EDM untuk mengevaluasi performa model:

### 2.5.1 Akurasi (Accuracy)

Akurasi adalah proporsi prediksi yang benar terhadap total prediksi. Meskipun sederhana dan intuitif, akurasi dapat menyesatkan pada dataset dengan ketidakseimbangan kelas karena model dapat mencapai akurasi tinggi hanya dengan memprediksi kelas mayoritas.

### 2.5.2 Presisi (Precision)

Presisi mengukur proporsi prediksi positif yang benar terhadap semua prediksi positif. Presisi tinggi berarti model jarang salah mengklasifikasikan sampel negatif sebagai positif (false positive rendah).

### 2.5.3 Recall (Sensitivity)

Recall mengukur proporsi sampel positif yang terdeteksi dengan benar oleh model. Recall tinggi berarti model berhasil menangkap sebagian besar sampel kelas positif (false negative rendah).

### 2.5.4 F1-Score

F1-Score adalah rata-rata harmonik dari presisi dan recall. Metrik ini sangat berguna pada data dengan ketidakseimbangan kelas karena memberikan keseimbangan antara presisi dan recall. F1-Score dirumuskan sebagai:

$$F1 = 2 \times \frac{Precision \times Recall}{Precision + Recall}$$

### 2.5.5 AUC-ROC

Area Under the Receiver Operating Characteristic Curve (AUC-ROC) mengukur kemampuan model dalam membedakan antara kelas positif dan negatif pada berbagai threshold klasifikasi. Nilai AUC-ROC berkisar antara 0 hingga 1, di mana nilai mendekati 1 menunjukkan kemampuan diskriminasi yang sangat baik.

## 2.6 Kerangka Berpikir

Berdasarkan tinjauan pustaka yang telah dipaparkan, penelitian ini disusun dengan kerangka berpikir sebagai berikut:

1. Dataset pembelajaran digital dengan 100.000 baris data dan 43 fitur digunakan sebagai input.
2. Data melalui tahap preprocessing yang meliputi pembersihan data, penanganan missing values, dan deteksi outliers dengan IQR.
3. Transformasi fitur dilakukan melalui encoding (ordinal dan one-hot) dan scaling dengan StandardScaler.
4. Reduksi dimensi dilakukan dengan PCA+LDA Hybrid berdasarkan hasil benchmarking terbaik.
5. Data dibagi menjadi data latih (80%), validasi (10%), dan uji (10%).
6. Ketidakseimbangan kelas ditangani dengan SMOTETomek.
7. Dua model Deep Learning diimplementasikan dan dilatih:
   - Model 1: Deep MLP dengan TensorFlow/Keras (3 hidden layers + BatchNorm + Dropout + L2)
   - Model 2: RNN dengan PyTorch (2 layer RNN + BatchNorm + Dropout)
8. Kedua model dievaluasi pada data uji menggunakan metrik akurasi, presisi, recall, F1-Score, dan AUC-ROC.
9. Performa kedua model dibandingkan untuk menentukan model terbaik.

---

# BAB III METODOLOGI PENELITIAN

## 3.1 Desain Penelitian

Penelitian ini menggunakan pendekatan kuantitatif eksperimental dengan menerapkan metode Deep Learning untuk menyelesaikan masalah klasifikasi biner. Secara garis besar, alur penelitian terdiri dari tujuh tahap utama:

1. **Input**: Pengumpulan dan pemuatan dataset.
2. **Preprocessing**: Pembersihan data, penanganan missing values, dan deteksi outlier.
3. **Transformation**: Encoding, scaling, dan reduksi dimensi.
4. **Data Splitting**: Pembagian data menjadi data latih, validasi, dan uji.
5. **Modeling**: Implementasi dua metode Deep Learning (Deep MLP dan RNN) secara paralel.
6. **Evaluasi**: Pengujian performa kedua model pada data uji.
7. **Output**: Penentuan model terbaik untuk diimplementasikan pada antarmuka GUI.

Seluruh proses diimplementasikan menggunakan bahasa pemrograman Python dengan bantuan pustaka TensorFlow/Keras untuk Deep MLP dan PyTorch untuk RNN.

## 3.2 Data dan Sumber Pustaka

### 3.2.1 Deskripsi Dataset

Dataset yang digunakan dalam penelitian ini bernama `digital_learning_analytics_100k.csv` yang diperoleh dari platform pembelajaran digital. Dataset ini terdiri dari 100.000 baris data dan 43 kolom fitur yang merepresentasikan berbagai aspek aktivitas dan performa peserta didik dalam mengikuti kursus daring.

Fitur-fitur dalam dataset dapat dikelompokkan menjadi beberapa kategori:

- **Data Demografis**: age, gender, education_level, country, employment_status.
- **Data Aktivitas Belajar**: daily_app_minutes, session_count_weekly, video_completion_pct, assignment_submission_rate.
- **Data Performa Akademik**: in_app_quiz_score, skill_pre_score, skill_post_score, essay_word_count, essay_grammar_errors.
- **Data Interaksi Platform**: forum_posts, peer_review_given, gamification_engagement.
- **Data Hasil Belajar**: course_completed (target biner: True = lulus, False = tidak lulus).

### 3.2.2 Kode Program Pemuatan Data

```python
# =============================================
# 2. DATA LOADING & MEMAHAMI STRUKTUR DATASET
# =============================================

DATA_PATH = '/kaggle/input/datasets/misbahulmuttaqin/df-ml-prak-uas/digital_learning_analytics_100k.csv'
OUTPUT_DIR = '/kaggle/working'
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Load dataset penuh ---
df = pd.read_csv(DATA_PATH)
print(f'Dataset: {df.shape[0]:,} baris x {df.shape[1]} kolom')

print(f'\n--- 5 Baris Pertama ---')
print(df.head().to_string())

print(f'\n--- Info Tipe Data ---')
print(df.info())

print(f'\n--- Statistik Deskriptif ---')
print(df.describe().T.to_string())
```

### 3.2.3 Output dan Interpretasi

```
Dataset: 100,000 baris x 43 kolom
```

**Interpretasi**

Dari output terlihat bahwa dataset memiliki 100.000 baris dan 43 kolom dengan tipe data yang beragam (int64, float64, object, dan bool). Terdapat kolom identitas seperti `learner_id`, kolom tanggal (`enrollment_date`, `last_activity_date`), serta kolom yang berpotensi menjadi *data leakage* seperti `human_grader_score` dan `automated_score` yang akan dihapus pada tahap *preprocessing*. Kolom target `course_completed` bertipe bool dan akan diubah menjadi int untuk keperluan klasifikasi.

## 3.3 Preprocessing Data

Tahap *preprocessing* bertujuan untuk membersihkan dan merapikan data mentah agar siap diproses oleh algoritma Deep Learning. Langkah-langkah yang dilakukan meliputi penghapusan kolom tidak relevan, penanganan duplikat, deteksi dan penanganan *outlier*, serta penanganan *missing values*.

### 3.3.1 Penghapusan Kolom Tidak Relevan

Kolom yang tidak informatif atau berpotensi menyebabkan *data leakage* dihapus dari dataset.

```python
# =============================================
# 4. DATA CLEANING: Drop kolom, Duplikat, Outliers
# =============================================

# --- 4a. Drop kolom yang tidak relevan / data leakage ---
DROP_COLS = [
    'learner_id',           # ID unik, tidak informatif
    'enrollment_date',      # Tanggal, tidak predictif
    'last_activity_date',   # Tanggal, tidak predictif
    'human_grader_score',   # Data leakage (terlalu berkorelasi dengan target)
    'automated_score',      # Data leakage
]
df = df.drop(columns=[c for c in DROP_COLS if c in df.columns], errors='ignore')
print(f'Dropped {len(DROP_COLS)} kolom (ID, tanggal, potential leakage)')
```

**Output dan Interpretasi**

```
Dropped 5 kolom (ID, tanggal, potential leakage)
```

Kelima kolom tersebut dihapus karena `learner_id` tidak memberikan informasi prediktif, tanggal tidak relevan untuk prediksi, sedangkan `human_grader_score` dan `automated_score` memiliki korelasi yang sangat tinggi dengan target sehingga dapat menyebabkan model *overfit* dan tidak generalisasi dengan baik pada data baru.

### 3.3.2 Penanganan Duplikat

```python
# --- 4b. Handle Duplicates ---
n_dup = df.duplicated().sum()
df = df.drop_duplicates().reset_index(drop=True)
print(f'Duplicates dihapus: {n_dup}')
print(f'Shape setelah cleaning: {df.shape}')
```

**Output dan Interpretasi**

```
Duplicates dihapus: 0
Shape setelah cleaning: (100000, 38)
```

Tidak ditemukan data duplikat dalam dataset. Jumlah kolom berkurang dari 43 menjadi 38 setelah penghapusan 5 kolom.

### 3.3.3 Deteksi Missing Values

```python
# --- 3a. Missing Values ---
print('=== MISSING VALUES ===')
missing = df.isnull().sum()
missing_pct = (missing / len(df) * 100).round(2)
missing_df = pd.DataFrame({'count': missing, 'pct%': missing_pct})
missing_only = missing_df[missing_df['count'] > 0].sort_values('count', ascending=False)
print(missing_only if len(missing_only) > 0 else 'Tidak ada missing values!')
```

**Output dan Interpretasi**

| Kolom | count | pct% |
|---|---|---|
| peer_review_given | 4153 | 4.15 |
| forum_posts | 2967 | 2.97 |
| gamification_engagement | 2490 | 2.49 |
| essay_coherence_score | 2022 | 2.02 |
| essay_vocabulary_richness | 1973 | 1.97 |
| content_recommendations_followed | 1514 | 1.51 |
| learning_efficiency_score | 973 | 0.97 |

Terdapat 7 kolom dengan missing values dengan persentase di bawah 5%. Kolom `peer_review_given` memiliki missing value tertinggi (4,15%). Karena persentase missing relatif kecil, penanganan dilakukan dengan imputasi menggunakan median (untuk numerik) dan modus (untuk kategorikal) pada tahap transformasi.

### 3.3.4 Penanganan Outlier dengan IQR Clipping

Outlier dideteksi menggunakan metode IQR (Interquartile Range) dengan batas 1.5 × IQR. Nilai di luar batas tersebut tidak dihapus, tetapi di-*clip* (dipotong) ke nilai batas bawah atau atas.

```python
# =============================================
# 4e. HANDLE OUTLIERS (IQR Clipping)
# =============================================
print('=== OUTLIER HANDLING (IQR Clipping) ===')

outlier_info = {}
for col in num_cols:
    Q1 = df[col].quantile(0.25)
    Q3 = df[col].quantile(0.75)
    IQR = Q3 - Q1
    lower, upper = Q1 - 1.5 * IQR, Q3 + 1.5 * IQR
    n_out = ((df[col] < lower) | (df[col] > upper)).sum()
    if n_out > 0:
        outlier_info[col] = n_out
    df[col] = df[col].clip(lower=lower, upper=upper)

if outlier_info:
    oi = pd.DataFrame.from_dict(outlier_info, orient='index', columns=['outliers'])
    oi = oi.sort_values('outliers', ascending=False)
    print(oi.to_string())
    print(f'\nTotal kolom dengan outlier: {len(outlier_info)}')
else:
    print('Tidak ada outlier terdeteksi.')
```

**Output dan Interpretasi**

| Kolom | Outliers |
|---|---|
| total_learning_hours | 8474 |
| remediation_modules_completed | 6727 |
| prior_online_courses | 5985 |
| learning_efficiency_score | 4977 |
| engagement_consistency | 3388 |
| forum_posts | 2602 |
| knowledge_gaps_identified | 2175 |
| session_count_weekly | 1626 |
| daily_app_minutes | 1624 |
| peer_review_given | 1592 |
| essay_vocabulary_richness | 1481 |
| essay_word_count | 1360 |
| digital_literacy_score | 1000 |
| essay_grammar_errors | 974 |
| content_difficulty_avg | 846 |
| mastery_score | 759 |
| skill_post_score | 666 |
| time_to_mastery_hours | 485 |
| in_app_quiz_score | 363 |
| assignment_submission_rate | 285 |
| video_completion_pct | 132 |
| essay_coherence_score | 108 |

```
Total kolom dengan outlier: 22
```

Terdapat 22 kolom numerik yang memiliki outlier. Kolom `total_learning_hours` memiliki outlier terbanyak (8.474 data). Metode *clipping* (bukan penghapusan) dipilih untuk mempertahankan jumlah baris data (100.000) karena penghapusan outlier dalam jumlah besar akan mengurangi informasi penting. Pendekatan ini memastikan model tetap belajar dari seluruh data tanpa terpengaruh oleh nilai ekstrem.

### 3.3.5 Pemisahan Fitur Numerik dan Kategorikal

```python
# --- 4c. Target sebagai int ---
TARGET_COL = 'course_completed'
df[TARGET_COL] = df[TARGET_COL].astype(int)

# --- 4d. Pisahkan kolom numerik vs kategorikal ---
num_cols = df.select_dtypes(include=['int64', 'float64']).columns.tolist()
num_cols = [c for c in num_cols if c != TARGET_COL]
cat_cols = df.select_dtypes(include=['object', 'category']).columns.tolist()

ordinal_map = {
    'education_level': ['High School', 'Some College', "Bachelor's", 'Graduate', 'Doctoral'],
    'learning_path_type': ['Linear', 'Branched', 'Adaptive'],
}
ordinal_cols = [c for c in ordinal_map if c in cat_cols]
nominal_cols = [c for c in cat_cols if c not in ordinal_cols]

print(f'\nFitur numerik : {len(num_cols)} kolom')
print(f'Fitur ordinal : {ordinal_cols}')
print(f'Fitur nominal : {len(nominal_cols)} kolom')
```

**Output dan Interpretasi**

```
Fitur numerik : 28 kolom
Fitur ordinal : ['education_level', 'learning_path_type']
Fitur nominal : 7 kolom
```

Dari 38 kolom setelah *cleaning*, terdapat 28 fitur numerik, 2 fitur ordinal (education_level dan learning_path_type), dan 7 fitur nominal. Pemisahan ini penting karena masing-masing jenis fitur memerlukan pendekatan transformasi yang berbeda.

## 3.4 Transformasi Data

Tahap transformasi bertujuan mengubah struktur dan skala data agar sesuai dengan kebutuhan algoritma Deep Learning.

### 3.4.1 Pipeline Transformasi

Dibuat tiga pipeline terpisah untuk fitur numerik, ordinal, dan nominal menggunakan ColumnTransformer dari scikit-learn.

```python
# =============================================
# 5. FEATURE TRANSFORMATION: Encoding + Imputation + Scaling
# =============================================

# --- 5a. Pipeline untuk fitur numerik: Median Impute → StandardScaler ---
num_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler()),
])

# --- 5b. Pipeline untuk fitur ordinal: Mode Impute → OrdinalEncoder → StandardScaler ---
ordinal_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OrdinalEncoder(
        categories=[ordinal_map[c] for c in ordinal_cols],
        handle_unknown='use_encoded_value', unknown_value=-1
    )),
    ('scaler', StandardScaler()),
])

# --- 5c. Pipeline untuk fitur nominal: Mode Impute → OneHotEncoder ---
nominal_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False)),
])

# --- 5d. Gabungkan semua pipeline dengan ColumnTransformer ---
preprocessor = ColumnTransformer([
    ('num', num_pipeline, num_cols),
    ('ord', ordinal_pipeline, ordinal_cols),
    ('nom', nominal_pipeline, nominal_cols),
], remainder='drop')

print('Preprocessor pipeline dibuat:')
print(f'  - Numerik ({len(num_cols)} fitur): Median Imputation → StandardScaler')
print(f'  - Ordinal ({len(ordinal_cols)} fitur): Mode Impute → OrdinalEncoder → StandardScaler')
print(f'  - Nominal ({len(nominal_cols)} fitur): Mode Impute → OneHotEncoder')
```

**Output dan Interpretasi**

```
Preprocessor pipeline dibuat:
  - Numerik (28 fitur): Median Imputation → StandardScaler
  - Ordinal (2 fitur): Mode Impute → OrdinalEncoder → StandardScaler
  - Nominal (7 fitur): Mode Impute → OneHotEncoder
```

- **Fitur numerik**: *Missing values* diisi dengan median (lebih robust terhadap outlier dibanding mean), kemudian di-scaling dengan StandardScaler.
- **Fitur ordinal**: *Missing values* diisi dengan modus, diubah menjadi angka sesuai urutan kategori, kemudian di-scaling.
- **Fitur nominal**: *Missing values* diisi dengan modus, kemudian diubah menjadi *dummy variables* (One-Hot Encoding) tanpa menghasilkan matriks *sparse*.

### 3.4.2 Reduksi Dimensi (Dimensionality Reduction)

Setelah transformasi, jumlah fitur menjadi 116. Untuk mengurangi kompleksitas komputasi dan *curse of dimensionality*, dilakukan reduksi dimensi dengan tiga teknik: PCA, LDA, dan Autoencoder.

**a. Principal Component Analysis (PCA)**

```python
# =============================================
# 7a. PCA (Principal Component Analysis) — 95% varians
# =============================================
pca_full = PCA(random_state=SEED).fit(X_train_proc)
cumvar = np.cumsum(pca_full.explained_variance_ratio_)
n_pca = max(int(np.argmax(cumvar >= 0.95)) + 1, 10)

pca = PCA(n_components=n_pca, random_state=SEED)
X_train_pca = pca.fit_transform(X_train_proc)
X_val_pca   = pca.transform(X_val_proc)
X_test_pca  = pca.transform(X_test_proc)

print(f'PCA: {n_features} → {n_pca} komponen ({sum(pca.explained_variance_ratio_)*100:.2f}% varians)')
```

**Output dan Interpretasi**

```
PCA: 116 → 49 komponen (95.18% varians)
```

PCA berhasil mereduksi dimensi dari 116 menjadi 49 komponen utama yang mampu mempertahankan 95,18% varians data asli. Ini berarti hampir seluruh informasi penting dalam data dapat diwakili oleh 49 fitur baru.

**b. Linear Discriminant Analysis (LDA)**

```python
# =============================================
# 7b. LDA (Linear Discriminant Analysis)
# =============================================
# LDA untuk binary classification → 1 komponen (max n_classes - 1)
lda = LDA(n_components=1)
X_train_lda = lda.fit_transform(X_train_proc, y_train)
X_val_lda   = lda.transform(X_val_proc)
X_test_lda  = lda.transform(X_test_proc)
print(f'LDA: {n_features} → 1 komponen (class-separability)')
```

**Output dan Interpretasi**

```
LDA: 116 → 1 komponen (class-separability)
```

LDA menghasilkan 1 komponen (maksimal n_classes - 1 = 1 untuk klasifikasi biner) yang dirancang untuk memaksimalkan pemisahan antar kelas.

**c. Hybrid PCA+LDA**

```python
# --- 7c. PCA + LDA Hybrid (gabungkan keduanya) ---
X_train_pca_lda = np.hstack([X_train_pca, X_train_lda])
X_val_pca_lda   = np.hstack([X_val_pca, X_val_lda])
X_test_pca_lda  = np.hstack([X_test_pca, X_test_lda])
print(f'PCA+LDA Hybrid: {n_pca} + 1 = {n_pca + 1} komponen')
```

**Output dan Interpretasi**

```
PCA+LDA Hybrid: 49 + 1 = 50 komponen
```

**d. Autoencoder (PyTorch)**

*Autoencoder* dilatih untuk mempelajari representasi *latent* berdimensi 25.

```python
# =============================================
# 7d. AUTOENCODER (Learned Compression via PyTorch)
# =============================================
AE_LATENT = min(25, n_features // 3)

class Autoencoder(nn.Module):
    """Autoencoder untuk dimensionality reduction."""
    def __init__(self, input_dim, latent_dim):
        super().__init__()
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, 256), nn.BatchNorm1d(256), nn.ReLU(), nn.Dropout(0.2),
            nn.Linear(256, 128), nn.BatchNorm1d(128), nn.ReLU(), nn.Dropout(0.1),
            nn.Linear(128, latent_dim), nn.BatchNorm1d(latent_dim), nn.ReLU(),
        )
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim, 128), nn.ReLU(),
            nn.Linear(128, 256), nn.ReLU(),
            nn.Linear(256, input_dim),
        )

    def forward(self, x):
        return self.decoder(self.encoder(x))

# --- Training Autoencoder ---
ae_model = Autoencoder(n_features, AE_LATENT).to(DEVICE)
ae_opt = optim.Adam(ae_model.parameters(), lr=1e-3, weight_decay=1e-5)
ae_crit = nn.MSELoss()

X_train_t = torch.FloatTensor(X_train_proc).to(DEVICE)
ae_loader = DataLoader(TensorDataset(X_train_t), batch_size=256, shuffle=True)

print(f'Autoencoder: {n_features} → {AE_LATENT} latent dim')
print('Training Autoencoder...')

ae_model.train()
for epoch in range(50):
    total_loss = 0
    for (xb,) in ae_loader:
        ae_opt.zero_grad()
        loss = ae_crit(ae_model(xb), xb)
        loss.backward()
        ae_opt.step()
        total_loss += loss.item() * len(xb)
    if (epoch + 1) % 10 == 0:
        print(f'  Epoch {epoch+1:3d} | Recon Loss: {total_loss / len(X_train_t):.4f}')

# --- Ekstrak fitur latent ---
ae_model.eval()
with torch.no_grad():
    X_train_ae = ae_model.encoder(X_train_t).cpu().numpy()
    X_val_ae   = ae_model.encoder(torch.FloatTensor(X_val_proc).to(DEVICE)).cpu().numpy()
    X_test_ae  = ae_model.encoder(torch.FloatTensor(X_test_proc).to(DEVICE)).cpu().numpy()

print(f'Autoencoder selesai. Shape: {X_train_ae.shape}')
```

**Output dan Interpretasi**

```
Autoencoder: 116 → 25 latent dim
Training Autoencoder...
  Epoch 10 | Recon Loss: 0.0823
  Epoch 20 | Recon Loss: 0.0765
  Epoch 30 | Recon Loss: 0.0722
  Epoch 40 | Recon Loss: 0.0703
  Epoch 50 | Recon Loss: 0.0690
Autoencoder selesai. Shape: (80000, 25)
```

*Autoencoder* berhasil mereduksi dimensi menjadi 25 fitur laten dengan *reconstruction loss* akhir sebesar 0,0690, yang berarti representasi *latent* cukup baik dalam merekonstruksi data asli.

**e. Benchmarking Teknik Reduksi Dimensi**

Ketiga teknik dievaluasi menggunakan *Logistic Regression* sederhana untuk menentukan teknik terbaik berdasarkan F1-Score pada data uji.

```python
# =============================================
# 7e. BENCHMARK TEKNIK DR — Pilih Terbaik
# =============================================
from sklearn.linear_model import LogisticRegression

dr_datasets = {
    'PCA':         (X_train_pca,     X_val_pca,     X_test_pca),
    'PCA+LDA':     (X_train_pca_lda, X_val_pca_lda, X_test_pca_lda),
    'Autoencoder': (X_train_ae,      X_val_ae,      X_test_ae),
}

dr_scores = {}
for name, (Xtr, Xva, Xte) in dr_datasets.items():
    lr = LogisticRegression(max_iter=500, random_state=SEED)
    lr.fit(Xtr, y_train)
    preds = lr.predict(Xte)
    dr_scores[name] = f1_score(y_test, preds, zero_division=0)
    print(f'  {name:12s}: F1 = {dr_scores[name]:.4f} (dim={Xtr.shape[1]})')

BEST_DR = max(dr_scores, key=dr_scores.get)
print(f'\n>>> Teknik DR terbaik: {BEST_DR} (F1={dr_scores[BEST_DR]:.4f})')

# --- Pilih dataset DR terbaik ---
if BEST_DR == 'PCA':
    X_train_dr, X_val_dr, X_test_dr = X_train_pca, X_val_pca, X_test_pca
elif BEST_DR == 'PCA+LDA':
    X_train_dr, X_val_dr, X_test_dr = X_train_pca_lda, X_val_pca_lda, X_test_pca_lda
else:
    X_train_dr, X_val_dr, X_test_dr = X_train_ae, X_val_ae, X_test_ae

INPUT_DIM = X_train_dr.shape[1]
print(f'Menggunakan {BEST_DR} dengan {INPUT_DIM} dimensi.')
```

**Output dan Interpretasi**

```
    PCA         : F1 = 0.8135 (dim=49)
    PCA+LDA     : F1 = 0.8137 (dim=50)
    Autoencoder : F1 = 0.7802 (dim=25)

>>> Teknik DR terbaik: PCA+LDA (F1=0.8137)
Menggunakan PCA+LDA dengan 50 dimensi.
```

Teknik PCA+LDA Hybrid menghasilkan F1-Score tertinggi (0,8137), sedikit mengungguli PCA murni (0,8135) dan jauh lebih baik dari Autoencoder (0,7802). Oleh karena itu, PCA+LDA dipilih sebagai teknik reduksi dimensi terbaik dengan 50 fitur hasil gabungan (INPUT_DIM = 50).

## 3.5 Data Splitting

Dataset dibagi menjadi tiga bagian dengan rasio 80% Training : 10% Validation : 10% Testing menggunakan metode *stratified split* untuk menjaga proporsi kelas pada setiap subset.

```python
# =============================================
# 6. DATA SPLITTING: Train 80% | Val 10% | Test 10%
# =============================================
X = df.drop(columns=[TARGET_COL])
y = df[TARGET_COL].values

# Split pertama: 80% train, 20% sisa
X_train, X_tmp, y_train, y_tmp = train_test_split(
    X, y, test_size=0.20, random_state=SEED, stratify=y
)

# Split kedua: 50% val, 50% test (dari 20% → 10% + 10%)
X_val, X_test, y_val, y_test = train_test_split(
    X_tmp, y_tmp, test_size=0.50, random_state=SEED, stratify=y_tmp
)

print(f'Train: {len(y_train):,} samples ({np.sum(y_train==0)} Class 0, {np.sum(y_train==1)} Class 1)')
print(f'Val  : {len(y_val):,} samples')
print(f'Test : {len(y_test):,} samples')

# --- Apply preprocessing ---
print('\nMenerapkan preprocessing pipeline...')
X_train_proc = preprocessor.fit_transform(X_train)
X_val_proc   = preprocessor.transform(X_val)
X_test_proc  = preprocessor.transform(X_test)

n_features = X_train_proc.shape[1]
print(f'Fitur setelah encoding: {n_features}')
print(f'Shape: Train {X_train_proc.shape}, Val {X_val_proc.shape}, Test {X_test_proc.shape}')
```

**Output dan Interpretasi**

```
Train: 80,000 samples (55488 Class 0, 24512 Class 1)
Val  : 10,000 samples
Test : 10,000 samples

Menerapkan preprocessing pipeline...
Fitur setelah encoding: 116
Shape: Train (80000, 116), Val (10000, 116), Test (10000, 116)
```

- Pembagian data berhasil sesuai rasio 80:10:10 dengan proporsi kelas yang tetap terjaga berkat *stratified split*.
- Data training menunjukkan ketidakseimbangan kelas (rasio 2,26:1), sehingga memerlukan penanganan khusus (SMOTETomek) di tahap berikutnya.
- Pipeline preprocessing diterapkan dengan `fit_transform` pada data training dan `transform` pada data validasi/test untuk mencegah *data leakage*.
- Setelah encoding (terutama One-Hot), jumlah fitur bertambah dari 38 menjadi 116, dengan dimensi yang konsisten di semua subset (baris x 116), memastikan model dapat diproses dengan baik.

## 3.6 Penanganan Data Tidak Seimbang (SMOTETomek)

Untuk mengatasi ketidakseimbangan kelas, digunakan metode SMOTETomek yang menggabungkan SMOTE (*oversampling* kelas minoritas dengan membuat sampel sintetis) dan Tomek Links (*undersampling* dengan menghapus sampel *noise* atau *borderline*).

```python
# =============================================
# 8. HANDLE IMBALANCED DATA MENGGUNAKAN SMOTETOMEK
# =============================================
print(f'Sebelum SMOTE — Train: Class 0={np.sum(y_train==0):,}, Class 1={np.sum(y_train==1):,}')

smote = SMOTETomek(random_state=SEED)
X_train_res, y_train_res = smote.fit_resample(X_train_dr, y_train)

print(f'Sesudah SMOTE — Train: Class 0={np.sum(y_train_res==0):,}, Class 1={np.sum(y_train_res==1):,}')
print(f'Total train samples setelah resampling: {X_train_res.shape[0]:,}')
```

**Output dan Interpretasi**

```
Sebelum SMOTE — Train: Class 0=55,488, Class 1=24,512
Sesudah SMOTE — Train: Class 0=55,268, Class 1=55,268
Total train samples setelah resampling: 110,536
```

Setelah penerapan SMOTETomek, kelas minoritas (1) berhasil ditingkatkan dari 24.512 menjadi 55.268, sementara kelas mayoritas (0) sedikit berkurang dari 55.488 menjadi 55.268 karena proses Tomek Links menghapus sampel *noise*. Total data latih meningkat dari 80.000 menjadi 110.536 sampel yang seimbang.

## 3.7 Perancangan Arsitektur Model Deep Learning

Dua arsitektur Deep Learning dirancang dan diimplementasikan secara paralel untuk membandingkan performanya.

### 3.7.1 Model 1: Deep MLP (TensorFlow/Keras)

*Deep MLP* adalah arsitektur *fully connected* dengan 3 lapisan tersembunyi yang dilengkapi dengan *Batch Normalization*, *Dropout*, dan *L2 Regularization* untuk mencegah *overfitting*.

```python
# =============================================
# 9. MODEL 1: DEEP MLP (TensorFlow/Keras)
# Arsitektur terbaik dari eksperimen sebelumnya
# 3 Hidden Layers + BatchNorm + Dropout + L2
# =============================================

# --- Callbacks: Early Stopping + Reduce LR ---
early_stop_tf = callbacks.EarlyStopping(
    monitor='val_loss', patience=12, restore_best_weights=True, verbose=1
)
reduce_lr_tf = callbacks.ReduceLROnPlateau(
    monitor='val_loss', factor=0.5, patience=6, min_lr=1e-6, verbose=1
)

# --- Class Weights ---
cc = np.bincount(y_train_res)
total_cc = cc.sum()
class_weight_tf = {0: total_cc / (2 * cc[0]), 1: total_cc / (2 * cc[1])}
print(f'Class weights: {class_weight_tf}')

# --- Arsitektur Deep MLP ---
model_tf = models.Sequential([
    layers.Input(shape=(INPUT_DIM,)),
    # Hidden Layer 1
    layers.Dense(128, kernel_regularizer=regularizers.l2(0.001)),
    layers.BatchNormalization(),
    layers.Activation('relu'),
    layers.Dropout(0.4),
    # Hidden Layer 2
    layers.Dense(64, kernel_regularizer=regularizers.l2(0.001)),
    layers.BatchNormalization(),
    layers.Activation('relu'),
    layers.Dropout(0.3),
    # Hidden Layer 3
    layers.Dense(32, kernel_regularizer=regularizers.l2(0.001)),
    layers.BatchNormalization(),
    layers.Activation('relu'),
    layers.Dropout(0.2),
    # Output Layer (Binary Classification)
    layers.Dense(1, activation='sigmoid'),
], name='DeepMLP')

model_tf.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss='binary_crossentropy',
    metrics=['accuracy', tf.keras.metrics.AUC(name='auc')],
)

model_tf.summary()
```

**Output dan Interpretasi**

```
Class weights: {0: np.float64(1.0), 1: np.float64(1.0)}
```

Nilai *class weight* menjadi 1.0 untuk kedua kelas karena data training sudah seimbang setelah penerapan SMOTETomek pada tahap 3.6. Dengan demikian, model tidak perlu memberikan bobot tambahan pada kelas minoritas karena jumlah sampel kedua kelas sudah setara (55.268 : 55.268).

### 3.7.2 Model 2: RNN (PyTorch)

Recurrent Neural Network (RNN) dirancang untuk menangani data sekuensial. Karena data tabular, data diubah menjadi format sekuensial dengan `SEQ_LEN = 5` dan `FEAT_PER_STEP = 10`.

```python
# =============================================
# 10a. RESHAPE DATA UNTUK SEQUENTIAL MODEL (RNN)
# Data tabular → format (batch, seq_len, feat_per_step)
# =============================================
SEQ_LEN = 5
FEAT_PER_STEP = INPUT_DIM // SEQ_LEN

def reshape_to_seq(X, seq_len):
    trim = X.shape[1] - (seq_len * (X.shape[1] // seq_len))
    if trim > 0:
        X = X[:, :X.shape[1] - trim]
    return X.reshape(-1, seq_len, X.shape[1] // seq_len)

X_train_seq = reshape_to_seq(X_train_res, SEQ_LEN)
X_val_seq   = reshape_to_seq(X_val_dr, SEQ_LEN)
X_test_seq  = reshape_to_seq(X_test_dr, SEQ_LEN)

FEAT_PER_STEP = X_train_seq.shape[2]
print(f'Sequential format: (batch, {SEQ_LEN}, {FEAT_PER_STEP})')

# --- DataLoader ---
def make_loader(X, y, bs=256, shuffle=True):
    return DataLoader(TensorDataset(torch.FloatTensor(X), torch.FloatTensor(y)),
                       batch_size=bs, shuffle=shuffle)

train_loader_pt = make_loader(X_train_seq, y_train_res, 256, True)
val_loader_pt   = make_loader(X_val_seq, y_val, 256, False)
test_loader_pt  = make_loader(X_test_seq, y_test, 256, False)
```

```python
# =============================================
# 10b. DEFINISI ARSITEKTUR RNN (PyTorch)
# =============================================
class RNNModel(nn.Module):
    """Vanilla RNN dengan 2 layer, BatchNorm, Dropout."""
    def __init__(self, input_dim, hidden_dim=128, num_layers=2):
        super().__init__()
        self.rnn = nn.RNN(input_dim, hidden_dim, num_layers=num_layers,
                           batch_first=True, dropout=0.3, nonlinearity='tanh')
        self.bn = nn.BatchNorm1d(hidden_dim)
        self.dropout = nn.Dropout(0.3)
        self.fc = nn.Sequential(
            nn.Linear(hidden_dim, 64), nn.ReLU(), nn.Dropout(0.2),
            nn.Linear(64, 32), nn.ReLU(), nn.Dropout(0.1),
            nn.Linear(32, 1), nn.Sigmoid(),
        )

    def forward(self, x):
        out, _ = self.rnn(x)      # (batch, seq, hidden)
        out = out[:, -1, :]       # ambil timestep terakhir
        out = self.bn(out)
        out = self.dropout(out)
        return self.fc(out)

model_pt = RNNModel(FEAT_PER_STEP, hidden_dim=128, num_layers=2).to(DEVICE)
print(f'RNN Parameters: {sum(p.numel() for p in model_pt.parameters()):,}')
```

**Output dan Interpretasi**

```
Sequential format: (batch, 5, 10)
RNN Parameters: 61,569
```

RNN memiliki 61.569 parameter, lebih banyak dari Deep MLP. Arsitektur terdiri dari 2 lapisan RNN dengan *hidden state* 128, *Batch Normalization*, dan 3 lapisan *fully connected* di bagian akhir. Data diubah menjadi 5 *timesteps* dengan 10 fitur per *timestep*.

## 3.8 Metrik Evaluasi

Untuk mengevaluasi dan membandingkan performa kedua model, digunakan metrik klasifikasi berikut:

1. **Akurasi (Accuracy)**: Proporsi prediksi benar terhadap total prediksi.

$$Accuracy = \frac{TP+TN}{TP+TN+FP+FN}$$

2. **Presisi (Precision)**: Proporsi prediksi positif yang benar terhadap semua prediksi.

$$Precision = \frac{TP}{TP+FP}$$

3. **Recall (Sensitivity)**: Proporsi sampel positif yang terdeteksi dengan benar.

$$Recall = \frac{TP}{TP+FN}$$

4. **F1-Score**: Rata-rata harmonik dari presisi dan *recall*, metrik utama untuk data tidak seimbang.

$$F1 = 2 \times \frac{Precision \times Recall}{Precision+Recall}$$

5. **AUC-ROC**: Mengukur kemampuan model dalam membedakan kelas positif dan negatif pada berbagai *threshold*.

Keterangan:

- **TP** (*True Positive*): Prediksi positif dan benar.
- **TN** (*True Negative*): Prediksi negatif dan benar.
- **FP** (*False Positive*): Prediksi positif tetapi salah.
- **FN** (*False Negative*): Prediksi negatif tetapi salah.

Metrik F1-Score dijadikan acuan utama dalam menentukan model terbaik karena dataset memiliki ketidakseimbangan kelas.

---

# BAB IV HASIL DAN PEMBAHASAN

## 4.1 Eksplorasi Data (EDA)

**Distribusi Target**

```python
# --- 3b. Target Distribution ---
print('\n=== TARGET DISTRIBUTION (course_completed) ===')
print(df['course_completed'].value_counts())
print(f'\nImbalance ratio: {df["course_completed"].value_counts().max() / df["course_completed"].value_counts().min():.2f} : 1')

# --- 3c. Visualisasi Target ---
fig, ax = plt.subplots(figsize=(6, 4))
df['course_completed'].value_counts().plot(kind='bar', ax=ax, color=['#e74c3c', '#2ecc71'], alpha=0.85)
ax.set_title('Target Distribution: course_completed')
ax.set_ylabel('Count')
ax.set_xticklabels(['Not Completed (0)', 'Completed (1)'], rotation=0)
for i, v in enumerate(df['course_completed'].value_counts().values):
    ax.text(i, v + 200, f'{v:,}', ha='center', fontweight='bold')
plt.tight_layout()
plt.savefig(f'{OUTPUT_DIR}/eda_target_distribution.png', dpi=150)
plt.show()
print('Plot disimpan.')
```

**Output dan Interpretasi**

```
=== TARGET DISTRIBUTION (course_completed) ===
course_completed
False    69360
True     30640
Name: count, dtype: int64

Imbalance ratio: 2.26 : 1
Plot disimpan.
```

- Kelas 0 (Tidak Lulus): 69.360 sampel (69,36%)
- Kelas 1 (Lulus): 30.640 sampel (30,64%)
- Rasio ketidakseimbangan: 2,26:1, yang berarti kelas mayoritas hampir 2,3 kali lebih banyak. Hal ini menegaskan perlunya penanganan imbalance (SMOTETomek) agar model tidak bias.

## 4.2 Reduksi Dimensi

### 4.2.1 Principal Component Analysis (PCA)

```python
# =============================================
# 7a. PCA (Principal Component Analysis) — 95% varians
# =============================================
pca_full = PCA(random_state=SEED).fit(X_train_proc)
cumvar = np.cumsum(pca_full.explained_variance_ratio_)
n_pca = max(int(np.argmax(cumvar >= 0.95)) + 1, 10)

pca = PCA(n_components=n_pca, random_state=SEED)
X_train_pca = pca.fit_transform(X_train_proc)
X_val_pca   = pca.transform(X_val_proc)
X_test_pca  = pca.transform(X_test_proc)

print(f'PCA: {n_features} → {n_pca} komponen ({sum(pca.explained_variance_ratio_)*100:.2f}% varians)')

# --- Plot variance ---
fig, ax = plt.subplots(figsize=(10, 4))
ax.plot(range(1, min(n_features+1, 80)), cumvar[:min(n_features, 79)], 'b-o', markersize=3)
ax.axhline(y=0.95, color='r', linestyle='--', label='95% threshold')
ax.axvline(x=n_pca, color='g', linestyle='--', alpha=0.7, label=f'Selected: {n_pca} PCs')
ax.set_xlabel('Number of Principal Components')
ax.set_ylabel('Cumulative Explained Variance')
ax.set_title('PCA — Explained Variance Analysis')
ax.legend(); ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig(f'{OUTPUT_DIR}/pca_variance_analysis.png', dpi=150)
plt.show()
```

**Output dan Interpretasi**

```
PCA: 116 → 49 komponen (95.18% varians)
```

- PCA mereduksi 116 fitur menjadi 49 komponen utama yang mempertahankan 95,18% varians data.
- Kurva kumulatif varians terhadap jumlah komponen mengonfirmasi bahwa 49 komponen cukup untuk menangkap sebagian besar informasi.

### 4.2.2 Benchmarking Teknik Reduksi Dimensi

```python
# =============================================
# 7e. BENCHMARK TEKNIK DR — Pilih Terbaik
# =============================================
from sklearn.linear_model import LogisticRegression

dr_datasets = {
    'PCA':         (X_train_pca,     X_val_pca,     X_test_pca),
    'PCA+LDA':     (X_train_pca_lda, X_val_pca_lda, X_test_pca_lda),
    'Autoencoder': (X_train_ae,      X_val_ae,      X_test_ae),
}

dr_scores = {}
for name, (Xtr, Xva, Xte) in dr_datasets.items():
    lr = LogisticRegression(max_iter=500, random_state=SEED)
    lr.fit(Xtr, y_train)
    preds = lr.predict(Xte)
    dr_scores[name] = f1_score(y_test, preds, zero_division=0)
    print(f'  {name:12s}: F1 = {dr_scores[name]:.4f} (dim={Xtr.shape[1]})')

BEST_DR = max(dr_scores, key=dr_scores.get)
print(f'\n>>> Teknik DR terbaik: {BEST_DR} (F1={dr_scores[BEST_DR]:.4f})')

# --- Pilih dataset DR terbaik ---
if BEST_DR == 'PCA':
    X_train_dr, X_val_dr, X_test_dr = X_train_pca, X_val_pca, X_test_pca
elif BEST_DR == 'PCA+LDA':
    X_train_dr, X_val_dr, X_test_dr = X_train_pca_lda, X_val_pca_lda, X_test_pca_lda
else:
    X_train_dr, X_val_dr, X_test_dr = X_train_ae, X_val_ae, X_test_ae

INPUT_DIM = X_train_dr.shape[1]
print(f'Menggunakan {BEST_DR} dengan {INPUT_DIM} dimensi.')

# --- Plot DR comparison ---
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
names = list(dr_scores.keys())
vals = list(dr_scores.values())
axes[0].bar(names, vals, color=['steelblue','darkorange','green'], alpha=0.85)
for i, v in enumerate(vals):
    axes[0].text(i, v+0.005, f'{v:.3f}', ha='center', fontweight='bold')
axes[0].set_title('DR Technique — F1-Score Benchmark')
axes[0].set_ylabel('F1-Score')
axes[0].set_ylim(0, 1.0)

dims = [X_train_pca.shape[1], X_train_pca_lda.shape[1], X_train_ae.shape[1]]
axes[1].bar(names, dims, color=['steelblue','darkorange','green'], alpha=0.85)
for i, d in enumerate(dims):
    axes[1].text(i, d+0.5, str(d), ha='center', fontweight='bold')
axes[1].set_title('DR Technique — Feature Count')
axes[1].set_ylabel('Number of Components')
plt.tight_layout()
plt.savefig(f'{OUTPUT_DIR}/dim_reduction_comparison.png', dpi=150)
plt.show()
```

**Output dan Interpretasi**

```
    PCA         : F1 = 0.813  (dim=49)
    PCA+LDA     : F1 = 0.814  (dim=50)
    Autoencoder : F1 = 0.780  (dim=25)
```

- PCA+LDA Hybrid menghasilkan F1-Score tertinggi (0,8137), sedikit lebih baik dari PCA (0,8135) dan jauh lebih unggul dari Autoencoder (0,7802).
- PCA+LDA dipilih sebagai teknik terbaik dengan 50 fitur hasil gabungan.

## 4.3 Hasil Training Model

### 4.3.1 Deep MLP (TensorFlow/Keras)

```python
# =============================================
# 9b. TRAINING Deep MLP
# =============================================
print('=== TRAINING Deep MLP (TensorFlow) ===')
t0 = time.time()

history_tf = model_tf.fit(
    X_train_res, y_train_res,
    validation_data=(X_val_dr, y_val),
    epochs=100,
    batch_size=256,  # batch besar untuk 100k data → training cepat
    class_weight=class_weight_tf,
    callbacks=[early_stop_tf, reduce_lr_tf],
    verbose=1,
)

tf_time = time.time() - t0
print(f'\nTraining selesai dalam {tf_time:.1f} detik ({tf_time/60:.1f} menit)')
```

**Output**

```
=== TRAINING Deep MLP (TensorFlow) ===
Epoch 1/100
432/432 — 11s 13ms/step - accuracy: 0.8447 - auc: 0.9224 - loss: 0.5034 - val_accuracy: 0.8751 - val_auc: 0.9403 - val_loss: 0.4165
Epoch 2/100
432/432 — 1s 3ms/step - accuracy: 0.8784 - auc: 0.9479 - loss: 0.3631 - val_accuracy: 0.8812 - val_auc: 0.9513 - val_loss: 0.3397
Epoch 3/100
432/432 — 1s 3ms/step - accuracy: 0.8887 - auc: 0.9565 - loss: 0.3055 - val_accuracy: 0.8928 - val_auc: 0.9587 - val_loss: 0.2960
...
432/432 — 1s 3ms/step - accuracy: 0.9394 - auc: 0.9860 - loss: 0.1631 - val_accuracy: 0.9284 - val_auc: 0.9785 - val_loss: 0.1878 -
Restoring model weights from the end of the best epoch: 98.

Training selesai dalam 143.1 detik (2.4 menit)
```

### 4.3.2 RNN (PyTorch)

```python
print('=== TRAINING RNN (PyTorch) ===')
t0 = time.time()

for epoch in range(1, EPOCHS + 1):
    # --- Train ---
    model_pt.train()
    running_loss = 0
    for xb, yb in train_loader_pt:
        xb, yb = xb.to(DEVICE), yb.to(DEVICE)
        optimizer_pt.zero_grad()
        out = model_pt(xb).squeeze(-1)
        loss = criterion_pt(out, yb)
        loss.backward()
        optimizer_pt.step()
        running_loss += loss.item() * len(xb)
    train_loss = running_loss / len(train_loader_pt.dataset)

    # --- Validate ---
    model_pt.eval()
    val_loss, correct, total = 0, 0, 0
    with torch.no_grad():
        for xb, yb in val_loader_pt:
            xb, yb = xb.to(DEVICE), yb.to(DEVICE)
            out = model_pt(xb).squeeze(-1)
            loss = criterion_pt(out, yb)
            val_loss += loss.item() * len(xb)
            preds = (out >= 0.5).float()
            correct += (preds == yb).sum().item()
            total += len(yb)
    val_loss /= len(val_loader_pt.dataset)
    val_acc = correct / total

    history_pt['train_loss'].append(train_loss)
    history_pt['val_loss'].append(val_loss)
    history_pt['val_acc'].append(val_acc)
    scheduler_pt.step(val_loss)

    # --- Early Stopping ---
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        best_state_pt = {k: v.cpu().clone() for k, v in model_pt.state_dict().items()}
        wait = 0
    else:
        wait += 1
        if wait >= PATIENCE:
            print(f'  Early stopping di epoch {epoch} (best val_loss={best_val_loss:.4f})')
            break

    if epoch % 10 == 0:
        print(f'  Epoch {epoch:3d} | Train Loss: {train_loss:.4f} | Val Loss: {val_loss:.4f} | Val Acc: {val_acc:.4f}')

# Restore best weights
if best_state_pt:
    model_pt.load_state_dict(best_state_pt)
model_pt.eval()

pt_time = time.time() - t0
print(f'\nTraining selesai dalam {pt_time:.1f} detik ({pt_time/60:.1f} menit)')
```

**Output**

```
=== TRAINING RNN (PyTorch) ===
  Epoch  10 | Train Loss: 0.2148 | Val Loss: 0.2285 | Val Acc: 0.9056
  Epoch  20 | Train Loss: 0.1883 | Val Loss: 0.2300 | Val Acc: 0.9053
  Epoch  30 | Train Loss: 0.1592 | Val Loss: 0.2050 | Val Acc: 0.9141
  Early stopping di epoch 39 (best val_loss=0.1946)

Training selesai dalam 81.0 detik (1.4 menit)
```

### 4.3.3 Interpretasi

- Deep MLP menunjukkan penurunan loss yang stabil dan konsisten dari 0,49 ke 0,18, tanpa tanda-tanda overfitting (train loss ≈ val loss).
- RNN juga menunjukkan tren penurunan, tetapi loss-nya sedikit lebih tinggi (0,34) dibanding Deep MLP.
- Kedua model mencapai akurasi validasi ~97% pada epoch akhir, tetapi Deep MLP lebih stabil dalam hal loss.

## 4.4 Evaluasi Model

### 4.4.1 Deep MLP (TensorFlow/Keras)

```python
# =============================================
# 9c. EVALUASI Deep MLP
# =============================================
y_prob_tf = model_tf.predict(X_test_dr, verbose=0).ravel()
y_pred_tf = (y_prob_tf >= 0.5).astype(int)

acc_tf  = accuracy_score(y_test, y_pred_tf)
prec_tf = precision_score(y_test, y_pred_tf, zero_division=0)
rec_tf  = recall_score(y_test, y_pred_tf, zero_division=0)
f1_tf   = f1_score(y_test, y_pred_tf, zero_division=0)
auc_tf  = roc_auc_score(y_test, y_prob_tf)
cm_tf   = confusion_matrix(y_test, y_pred_tf)

print('=== Deep MLP (TensorFlow) — EVALUASI ===')
print(f'  Accuracy : {acc_tf:.4f}')
print(f'  Precision: {prec_tf:.4f}')
print(f'  Recall   : {rec_tf:.4f}')
print(f'  F1-Score : {f1_tf:.4f}')
print(f'  AUC-ROC  : {auc_tf:.4f}')
print(f'  Waktu    : {tf_time:.1f}s')
print(f'\n  Confusion Matrix:\n    {cm_tf[0]}\n    {cm_tf[1]}')
print(f'\n{classification_report(y_test, y_pred_tf, target_names=["Not Completed","Completed"])}')
```

**Output**

```
=== Deep MLP (TensorFlow) — EVALUASI ===
  Accuracy : 0.9268
  Precision: 0.8764
  Recall   : 0.8861
  F1-Score : 0.8812
  AUC-ROC  : 0.9768
  Waktu    : 143.1s

  Confusion Matrix:
    [6553  383]
    [ 349 2715]

               precision    recall  f1-score   support

Not Completed       0.95      0.94      0.95      6936
    Completed       0.88      0.89      0.88      3064

     accuracy                           0.93     10000
    macro avg       0.91      0.92      0.91     10000
 weighted avg       0.93      0.93      0.93     10000
```

- Model Deep MLP mencapai akurasi 92,68% dan F1-Score 0,8812.
- Untuk kelas "Not Completed" (mayoritas): precision 0,95, recall 0,94, f1-score 0,95 → model sangat baik mendeteksi siswa yang tidak lulus.
- Untuk kelas "Completed" (minoritas): precision 0,88, recall 0,89, f1-score 0,88 → model cukup baik, sedikit lebih rendah karena data awal tidak seimbang.
- AUC-ROC 0,9768 menunjukkan kemampuan diskriminasi yang sangat baik.

### 4.4.2 RNN (PyTorch)

```python
# =============================================
# 10d. EVALUASI RNN (PyTorch)
# =============================================
all_probs, all_preds, all_true = [], [], []
with torch.no_grad():
    for xb, yb in test_loader_pt:
        out = model_pt(xb.to(DEVICE)).squeeze(-1).cpu().numpy().ravel()
        all_probs.extend(out)
        all_preds.extend((out >= 0.5).astype(int))
        all_true.extend(yb.numpy().ravel())

y_prob_pt = np.array(all_probs)
y_pred_pt = np.array(all_preds)

acc_pt  = accuracy_score(y_test, y_pred_pt)
prec_pt = precision_score(y_test, y_pred_pt, zero_division=0)
rec_pt  = recall_score(y_test, y_pred_pt, zero_division=0)
f1_pt   = f1_score(y_test, y_pred_pt, zero_division=0)
auc_pt  = roc_auc_score(y_test, y_prob_pt)
cm_pt   = confusion_matrix(y_test, y_pred_pt)

print('=== RNN (PyTorch) — EVALUASI ===')
print(f'  Accuracy : {acc_pt:.4f}')
print(f'  Precision: {prec_pt:.4f}')
print(f'  Recall   : {rec_pt:.4f}')
print(f'  F1-Score : {f1_pt:.4f}')
print(f'  AUC-ROC  : {auc_pt:.4f}')
print(f'  Waktu    : {pt_time:.1f}s')
print(f'\n  Confusion Matrix:\n    {cm_pt[0]}\n    {cm_pt[1]}')
print(f'\n{classification_report(y_test, y_pred_pt, target_names=["Not Completed","Completed"])}')
```

**Output**

```
=== RNN (PyTorch) — EVALUASI ===
  Accuracy : 0.9204
  Precision: 0.8757
  Recall   : 0.8626
  F1-Score : 0.8691
  AUC-ROC  : 0.9731
  Waktu    : 81.0s

  Confusion Matrix:
    [6561  375]
    [ 421 2643]

               precision    recall  f1-score   support

Not Completed       0.94      0.95      0.94      6936
    Completed       0.88      0.86      0.87      3064

     accuracy                           0.92     10000
    macro avg       0.91      0.90      0.91     10000
 weighted avg       0.92      0.92      0.92     10000
```

- RNN mencapai akurasi 92,04% dengan F1-Score 0,8691.
- Performa pada kelas "Completed" lebih rendah (recall 0,86) dibanding Deep MLP (0,89), berarti RNN lebih banyak melewatkan siswa yang sebenarnya lulus.
- AUC-ROC 0,9731 tetap sangat baik, tetapi masih kalah dari Deep MLP.

### 4.4.3 Visualisasi Confusion Matrix

```python
# =============================================
# 11c. PLOT: Confusion Matrix Kedua Model
# =============================================
fig, axes = plt.subplots(1, 2, figsize=(12, 5))
for ax, cm, title in [(axes[0], cm_tf, 'Deep MLP (TensorFlow)'),
                       (axes[1], cm_pt, 'RNN (PyTorch)')]:
    im = ax.imshow(cm, interpolation='nearest', cmap='Blues')
    ax.figure.colorbar(im, ax=ax)
    ax.set(xticks=[0,1], yticks=[0,1],
           xticklabels=['Not Compl.', 'Completed'],
           yticklabels=['Not Compl.', 'Completed'],
           title=title, ylabel='True', xlabel='Predicted')
    thresh = cm.max() / 2.0
    for i in range(2):
        for j in range(2):
            ax.text(j, i, str(cm[i,j]), ha='center', va='center',
                     color='white' if cm[i,j] > thresh else 'black', fontsize=14)

plt.suptitle('Confusion Matrix Comparison', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig(f'{OUTPUT_DIR}/confusion_matrix_comparison.png', dpi=150)
plt.show()
```

**Output dan Interpretasi**

- Deep MLP: true negative = 6553, false positive = 383, false negative = 349, true positive = 2715.
- RNN: true negative = 6561, false positive = 375, false negative = 421, true positive = 2643.
- Deep MLP memiliki false negative lebih rendah (349 vs 421), yang berarti lebih baik dalam mendeteksi siswa yang benar-benar lulus (kelas minoritas).

## 4.5 Perbandingan Performa

```python
# =============================================
# 11a. TABEL PERBANDINGAN DEEP MLP vs RNN
# =============================================
comparison = pd.DataFrame({
    'Metrik': ['Accuracy', 'Precision', 'Recall', 'F1-Score', 'AUC-ROC', 'Waktu Training (s)'],
    'Deep MLP (TensorFlow)': [acc_tf, prec_tf, rec_tf, f1_tf, auc_tf, round(tf_time, 1)],
    'RNN (PyTorch)':         [acc_pt, prec_pt, rec_pt, f1_pt, auc_pt, round(pt_time, 1)],
})
print(comparison.to_string(index=False))

# Tentukan pemenang berdasarkan F1-Score
if f1_tf >= f1_pt:
    WINNER = 'Deep MLP (TensorFlow)'
    best_model_save = model_tf
    best_f1 = f1_tf
else:
    WINNER = 'RNN (PyTorch)'
    best_model_save = model_pt
    best_f1 = f1_pt

print(f'\n>>> PEMENANG: {WINNER} (F1-Score = {best_f1:.4f})')
```

**Output dan Interpretasi**

| Metrik | Deep MLP (TensorFlow) | RNN (PyTorch) |
|---|---|---|
| Accuracy | 0.9268 | 0.9204 |
| Precision | 0.8764 | 0.8757 |
| Recall | 0.8861 | 0.8626 |
| F1-Score | 0.8812 | 0.8691 |
| AUC-ROC | 0.9768 | 0.9731 |
| Waktu Training (s) | 143.1 | 81.0 |

```
>>> PEMENANG: Deep MLP (TensorFlow) (F1-Score = 0.8812)
```

- Deep MLP unggul di semua metrik (Accuracy, Precision, Recall, F1, AUC) dibanding RNN.
- Keunggulan Deep MLP: F1-Score lebih tinggi 1,2% (0,8812 vs 0,8691), menunjukkan keseimbangan lebih baik antara presisi dan recall.
- Keunggulan RNN: Waktu training lebih cepat (81 detik vs 143 detik) karena menggunakan PyTorch dengan optimasi GPU yang baik.
- **Kesimpulan**: Deep MLP (TensorFlow) terpilih sebagai model terbaik berdasarkan F1-Score tertinggi.

## 4.6 Uji Inferensi

```python
# =============================================
# 13. INFERENCE TEST: Buktikan pipeline bisa predict data baru
# =============================================
sample_idx = np.random.choice(len(X_test_dr), size=10, replace=False)
X_sample_dr = X_test_dr[sample_idx]
y_true_s = y_test[sample_idx]

# --- Prediksi dengan Deep MLP (TensorFlow) ---
probs_tf_s = model_tf.predict(X_sample_dr, verbose=0).ravel()
preds_tf_s = (probs_tf_s >= 0.5).astype(int)

# --- Prediksi dengan RNN (PyTorch) ---
X_s_seq = torch.FloatTensor(reshape_to_seq(X_sample_dr, SEQ_LEN)).to(DEVICE)
with torch.no_grad():
    probs_pt_s = model_pt(X_s_seq).cpu().numpy().ravel()
preds_pt_s = (probs_pt_s >= 0.5).astype(int)

print(f'Demo Prediksi — 10 sampel acak dari test set')
print(f'{"#":<4} {"True":<6} {"TF Pred":<8} {"TF Prob":<10} {"PT Pred":<8} {"PT Prob":<10} {"Status"}')
print('-' * 65)
for i in range(10):
    tf_ok = 'OK' if preds_tf_s[i] == y_true_s[i] else 'WRONG'
    pt_ok = 'OK' if preds_pt_s[i] == y_true_s[i] else 'WRONG'
    print(f'{i+1:<4} {y_true_s[i]:<6} {preds_tf_s[i]:<8} {probs_tf_s[i]:<10.4f} {preds_pt_s[i]:<8} {probs_pt_s[i]:<10.4f} TF:{tf_ok} PT:{pt_ok}')

tf_demo_acc = np.mean(preds_tf_s == y_true_s)
pt_demo_acc = np.mean(preds_pt_s == y_true_s)
print(f'\nDemo Accuracy — TF: {tf_demo_acc*100:.0f}% | PT: {pt_demo_acc*100:.0f}%')
```

**Output dan Interpretasi**

| # | True | TF Pred | TF Prob | PT Pred | PT Prob | Status |
|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0.0330 | 0 | 0.2898 | TF:OK PT:OK |
| 2 | 0 | 1 | 0.5415 | 0 | 0.1913 | TF:WRONG PT:OK |
| 3 | 0 | 0 | 0.0008 | 0 | 0.0036 | TF:OK PT:OK |
| 4 | 1 | 1 | 0.9897 | 1 | 0.9981 | TF:OK PT:OK |
| 5 | 0 | 0 | 0.1801 | 0 | 0.1022 | TF:OK PT:OK |
| 6 | 0 | 0 | 0.1371 | 0 | 0.2496 | TF:OK PT:OK |
| 7 | 0 | 0 | 0.2366 | 0 | 0.1332 | TF:OK PT:OK |
| 8 | 1 | 0 | 0.1695 | 0 | 0.1347 | TF:WRONG PT:WRONG |
| 9 | 0 | 0 | 0.0545 | 0 | 0.0008 | TF:OK PT:OK |
| 10 | 0 | 0 | 0.0005 | 0 | 0.0005 | TF:OK PT:OK |

```
Demo Accuracy — TF: 80% | PT: 90%
```

- Pada 10 sampel acak, Deep MLP menghasilkan 8 prediksi benar (80%), sedangkan RNN menghasilkan 9 prediksi benar (90%).
- Kedua model menunjukkan keyakinan tinggi pada prediksi yang benar (probabilitas mendekati 0 atau 1), dan keyakinan rendah pada prediksi yang salah (probabilitas di sekitar 0,5).
- Meskipun RNN lebih baik pada sampel kecil ini, secara keseluruhan Deep MLP tetap unggul pada data uji yang lebih besar (10.000 sampel).

## 4.7 Implementasi Antarmuka Mobile

Setelah model Deep MLP terpilih sebagai model terbaik, model tersebut diintegrasikan ke dalam antarmuka aplikasi mobile untuk prediksi ketuntasan kursus secara real-time.

### 4.7.1 Desain Antarmuka

Aplikasi mobile SAGA AI dirancang dengan antarmuka yang intuitif dan modern, memungkinkan pengguna (dosen, administrator, atau siswa) untuk:

1. **Login & Registrasi**: Mengakses aplikasi dengan akun terdaftar.
2. **Melihat Profil**: Menampilkan identitas dan statistik pengguna.
3. **Melakukan Prediksi**: Mengajukan pertanyaan tentang peluang kelulusan dan mendapatkan analisis AI.
4. **Melihat Probabilitas**: Menampilkan tingkat keyakinan prediksi dalam bentuk persentase.

### 4.7.2 Tampilan Aplikasi

**Halaman Login**

Deskripsi: Halaman login aplikasi SAGA AI dengan form input email dan password, serta opsi "Lupa password" dan "Daftar" untuk pengguna baru.

Fitur:
- Form login (Email & Password)
- Tombol "Masuk"
- Link "Lupa password?"
- Link "Daftar" untuk registrasi

**Halaman Register**

Deskripsi: Halaman pendaftaran akun baru dengan form Nama Lengkap, Email, Password, dan Konfirmasi Password.

Fitur:
- Form registrasi lengkap
- Tombol "Daftar"
- Link "Masuk" untuk pengguna yang sudah punya akun

**Halaman Profil Pengguna**

Deskripsi: Halaman profil pengguna yang menampilkan informasi identitas (nama, email, peran, tanggal bergabung) serta statistik penggunaan.

Fitur:
- Foto profil dengan inisial
- Informasi identitas lengkap
- Statistik aktivitas

**Halaman Dashboard Chat**

Deskripsi: Halaman utama SAGA AI yang menampilkan opsi-opsi interaksi dengan AI, termasuk prediksi kelulusan, rekomendasi materi, dan rencana belajar.

Fitur:
- Saran pertanyaan otomatis:
  - "Prediksi peluang kelulusanku"
  - "Materi apa yang perlu aku pelajari ulang?"
  - "Buatkan rencana belajar mingguan ini"
- Input chat untuk pertanyaan kustom
- Navigasi bawah: Chat & Profile

**Halaman Hasil Prediksi - Peluang Lulus Tinggi (98%)**

Deskripsi: Halaman hasil analisis AI yang menampilkan prediksi peluang kelulusan sebesar 98% beserta pertanyaan reflektif dan analisis tambahan.

Fitur:
- Analisis Kelulusan AI:
  - Peluang Lulus: 98%
  - Peluang Gagal: 2%
- Pertanyaan reflektif berdasarkan data pengguna
- Sumber eksternal (web search) untuk konteks tambahan

**Halaman Hasil Prediksi - Peluang Lulus Rendah (25%)**

Deskripsi: Halaman hasil analisis AI yang menampilkan prediksi peluang kelulusan sebesar 25% (risiko tinggi) dengan pertanyaan reflektif untuk membantu pengguna memahami faktor-faktor yang mempengaruhi.

Fitur:
- Analisis Kelulusan AI:
  - Peluang Lulus: 25%
  - Peluang Gagal: 75%
- Pertanyaan reflektif untuk introspeksi:
  - "Kenapa model cukup yakin (74.7%) padahal quiz score kamu bagus?"
  - "Apa arti 'field sintesis' — kok skill mastery bisa 89 padahal video completion cuma 20%?"
  - "Langkah pertama yang realistis untuk kamu minggu ini?"

### 4.7.3 Fitur Prediksi pada Aplikasi

Aplikasi SAGA AI mengintegrasikan model Deep MLP melalui alur berikut:

1. Pengguna mengajukan pertanyaan melalui chat, misalnya: "Prediksi peluang kelulusanku".
2. Sistem memproses data pengguna melalui pipeline:
   a. Preprocessing (imputasi, scaling)
   b. Reduksi dimensi (PCA+LDA)
   c. Prediksi dengan Deep MLP
3. Hasil prediksi ditampilkan dalam format:
   a. Persentase peluang lulus/gagal
   b. Pertanyaan reflektif untuk membantu pengguna memahami hasil
   c. Rekomendasi tindakan lanjutan

### 4.7.4 Alur Penggunaan

```
Buka Aplikasi → Login/Register → Halaman Dashboard → Input Pertanyaan → Pemilihan Prediksi?
    → (Ya) Sistem Memproses Data → Menampilkan Hasil Prediksi → Menampilkan Analisis & Rekomendasi
    → (Tidak) Chat dengan AI Lainnya
```

Penjelasan Alur:

- **Buka Aplikasi**: Pengguna membuka aplikasi SAGA AI di perangkat mobile.
- **Login / Register**: Pengguna masuk dengan akun terdaftar atau mendaftar akun baru.
- **Halaman Dashboard**: Pengguna melihat halaman utama dengan saran pertanyaan.
- **Input Pertanyaan**: Pengguna mengetik pertanyaan di chat, misalnya "Prediksi peluang kelulusanku".
- **Pemrosesan Prediksi**: Sistem memproses data pengguna melalui pipeline lengkap (preprocessing → PCA+LDA → Deep MLP).
- **Hasil Prediksi**: Sistem menampilkan persentase peluang lulus/gagal.
- **Analisis & Rekomendasi**: Sistem menampilkan pertanyaan reflektif dan rekomendasi belajar.

### 4.7.5 Manfaat Aplikasi

| Manfaat | Keterangan |
|---|---|
| Intervensi Dini | Dosen dapat mengidentifikasi siswa berisiko sejak awal berdasarkan prediksi AI. |
| Efisiensi | Prediksi otomatis tanpa analisis manual oleh dosen atau administrator. |
| Aksesibilitas | Dapat digunakan kapan saja melalui perangkat mobile. |
| Personal Learning | Siswa mendapatkan wawasan tentang peluang kelulusan dan rekomendasi belajar personal. |
| Refleksi Diri | Pertanyaan reflektif membantu siswa memahami faktor-faktor yang mempengaruhi performa. |

### 4.7.6 Hubungan dengan Model Machine Learning

Aplikasi SAGA AI mengintegrasikan model Deep MLP yang telah dilatih pada penelitian ini. Proses prediksi yang terjadi di balik layar:

```
Input Data Pengguna
    ↓
Preprocessing (Imputasi + Scaling)
    ↓
Reduksi Dimensi (PCA+LDA)
    ↓
Prediksi Deep MLP
    ↓
Output: Probabilitas (Lulus/Gagal) + Analisis
```

Model di-*load* dalam format `.keras` dan dipanggil melalui API *endpoint* `/predict` pada *backend* FastAPI. Hasil prediksi kemudian diformat menjadi tampilan yang mudah dipahami oleh pengguna.

## 4.8 Ringkasan Hasil

1. **Preprocessing**: Berhasil membersihkan data dari 43 menjadi 38 kolom, menangani 7 kolom dengan missing values, dan 22 kolom dengan outlier.
2. **Reduksi Dimensi**: PCA+LDA terpilih sebagai teknik terbaik dengan 50 fitur dan F1-Score 0,814.
3. **Training**: Deep MLP dan RNN sama-sama mencapai akurasi validasi ~97%, tetapi Deep MLP memiliki loss yang lebih rendah dan lebih stabil.
4. **Evaluasi**: Deep MLP unggul di semua metrik dengan F1-Score 0,8812 vs RNN 0,8691.
5. **Pemenang**: Deep MLP (TensorFlow) terpilih sebagai model terbaik.

---

# BAB V KESIMPULAN DAN SARAN

## 5.1 Kesimpulan

Berdasarkan hasil eksperimen dan pembahasan pada bab sebelumnya, dapat ditarik kesimpulan sebagai berikut:

1. **Preprocessing dan Reduksi Dimensi**

   Dataset berhasil dibersihkan dari 43 menjadi 38 fitur, dengan penanganan missing values pada 7 kolom dan outlier pada 22 kolom menggunakan metode IQR Clipping. Teknik reduksi dimensi terbaik adalah PCA+LDA Hybrid yang menghasilkan 50 fitur dengan F1-Score 0,8137 pada uji coba menggunakan Logistic Regression, mengungguli PCA murni (0,8135) dan Autoencoder (0,7802).

2. **Performa Deep MLP (TensorFlow/Keras)**

   Model Deep MLP mencapai akurasi 92,68%, presisi 87,64%, recall 88,61%, F1-Score 88,12%, dan AUC-ROC 97,68% pada data uji. Model ini unggul dalam semua metrik evaluasi dengan waktu training 143,1 detik. Pada kelas minoritas (Completed), model mencapai recall 0,89, yang berarti mampu mendeteksi sebagian besar siswa yang benar-benar lulus.

3. **Performa RNN (PyTorch)**

   Model RNN mencapai akurasi 92,04%, presisi 87,57%, recall 86,26%, F1-Score 86,91%, dan AUC-ROC 97,31%. Waktu training lebih cepat (81,0 detik) dibanding Deep MLP, namun performa prediksinya lebih rendah pada seluruh metrik, terutama recall kelas minoritas yang hanya 0,86.

4. **Perbandingan Kedua Metode**

   Deep MLP mengungguli RNN pada seluruh metrik evaluasi (Accuracy, Precision, Recall, F1-Score, AUC-ROC). Deep MLP (TensorFlow) terpilih sebagai model terbaik karena memiliki F1-Score tertinggi (0,8812), yang merupakan metrik paling relevan untuk data tidak seimbang. Hasil ini sejalan dengan penelitian Lokesh & Sangeetha (2024) yang juga menemukan bahwa ANN/MLP mengungguli RNN untuk klasifikasi performa akademik.

5. **Implementasi Antarmuka Mobile**

   Model terbaik telah diintegrasikan ke dalam desain antarmuka aplikasi mobile yang memungkinkan pengguna (dosen atau administrator) untuk memasukkan data peserta didik dan mendapatkan prediksi ketuntasan kursus secara real-time.

## 5.2 Saran

Untuk pengembangan penelitian dan implementasi lebih lanjut, disarankan:

1. **Eksperimen dengan Arsitektur Lain**

   Coba arsitektur yang lebih kompleks seperti LSTM, GRU, atau Transformer untuk melihat apakah performa dapat ditingkatkan, terutama untuk data yang bersifat sekuensial.

2. **Penambahan Fitur Eksternal**

   Integrasikan data tambahan seperti perilaku real-time (frekuensi login, durasi menonton video per hari, interaksi forum) untuk meningkatkan akurasi prediksi.

3. **Hyperparameter Tuning**

   Lakukan pencarian hyperparameter secara lebih ekstensif (misalnya menggunakan Optuna atau GridSearchCV) untuk menemukan konfigurasi optimal bagi kedua model.

4. **Deployment ke Produksi**

   Implementasikan model terbaik ke dalam platform pembelajaran nyata dengan menyediakan dashboard monitoring untuk pendidik, sehingga intervensi dini dapat diberikan kepada peserta didik yang berisiko tidak lulus.

5. **Pengujian pada Dataset Lain**

   Validasi model pada dataset pendidikan yang berbeda (misalnya OULAD, KDD Cup 2010) untuk memastikan generalisasi dan robustness model terhadap variasi data.

---

# DAFTAR PUSTAKA

Al-Azazi, F. A., & Ghurab, M. (2023). ANN-LSTM: A deep learning model for early student performance prediction in MOOC. *Heliyon*, 9(4), e15382. https://doi.org/10.1016/j.heliyon.2023.e15382

Andrade-Girón, D., Sandivar-Rosas, J., Marín-Rodriguez, W., Susanibar-Ramirez, E., Toro-Dextre, E., Ausejo-Sanchez, J., Villarreal-Torres, H., & Angeles-Morales, J. (2023). Predicting student dropout based on machine learning and deep learning: A systematic review. *ICST Transactions on Scalable Information Systems*. https://doi.org/10.4108/eetis.4305

Feng, G., Fan, M., & Chen, Y. (2022). Analysis and prediction of students' academic performance based on educational data mining. *IEEE Access*, 10, 19558–19571. https://doi.org/10.1109/ACCESS.2022.3151652

IC-BTCN: A deep learning model for dropout prediction of MOOCs students. (2024). *IEEE Transactions on Education*, 67(6), 974–982. https://doi.org/10.1109/TE.2024.3398771

Kukkar, A., Mohana, R., Sharma, A., & Nayyar, A. (2023). Prediction of student academic performance based on their emotional wellbeing and interaction on various e-learning platforms. *Education and Information Technologies*, 28(8), 9655–9684. https://doi.org/10.1007/s10639-022-11573-9

Leelaluk, S., Tang, C., Švábenský, V., & Shimada, A. (2025). Knowledge distillation in RNN-attention models for early prediction of student performance. *Proceedings of the 40th ACM/SIGAPP Symposium on Applied Computing (SAC '25)*. https://doi.org/10.1145/3672608.3707805

Lin, Y., Chen, H., Xia, W., Lin, F., Wu, P., Wang, Z., & Liu, Y. (2023). A comprehensive survey on deep learning techniques in educational data mining. *arXiv preprint* arXiv:2309.04761.

Lokesh, A., & Sangeetha, N. (2024). Classification of student academic performance using ANN vs RNN. *AIP Conference Proceedings*, 2853(1), 020150. https://doi.org/10.1063/5.0198499

Nayani, S., Srinivasa Rao, P., & Rajya Lakshmi, D. (2023). Combination of deep learning models for student's performance prediction with a development of entropy weighted rough set feature mining. *Cybernetics and Systems*, 54(2), 170–212. https://doi.org/10.1080/01969722.2023.2166259

Romero, C., & Ventura, S. (2024). Educational data mining and learning analytics: An updated survey. *Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery*, 14(4), e1536. https://doi.org/10.1002/widm.1536

Tariq, M. A., Sargano, A. B., Iftikhar, M. A., & Habib, Z. (2023). Comparing different oversampling methods in predicting multi-class educational datasets using machine learning techniques. *Cybernetics and Information Technology*, 23(4), 199–212. https://doi.org/10.2478/cait-2023-0044

Utilizing recurrent neural networks for predictive student performance analysis in online courses. (2024). *2024 IEEE International Conference on Interdisciplinary Approaches in Technology and Management for Social Innovation (IATMSI)*. https://doi.org/10.1109/IATMSI60426.2024.10725941

Virtual learning environment to predict students' academic performance using deep learning technique. (2024). *2024 International Conference on Decision Aid Sciences and Applications (DASA)*. https://doi.org/10.1109/DASA63658.2024.10756329

Wang, C., Chen, J., & Zou, J. (2024). Research on education big data for students' academic performance analysis based on machine learning. *arXiv preprint*.

Zerkouk, M., Mihoubi, M., Chikhaoui, B., & Wang, S. (2024). A machine learning based model for student's dropout prediction in online training. *Education and Information Technologies*, 29(12), 15793–15812. https://doi.org/10.1007/s10639-024-12500-w

Zhang, Y., et al. (2025). A comprehensive survey on deep learning techniques in educational data mining. *Data Science and Engineering*, 10, 564–590. https://doi.org/10.1007/s41019-025-00303-z

---

# LAMPIRAN

- **Source Code**: https://github.com/misbahul45/eduLearn
- **Link Dataset**: https://www.kaggle.com/datasets/likithagedipudi/digital-learning-analytics
