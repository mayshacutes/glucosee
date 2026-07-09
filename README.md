<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/Groq-FF6F00?style=for-the-badge&logo=groq&logoColor=white" alt="Groq"/>
  <br/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS"/>
  <img src="https://img.shields.io/github/v/release/mayshacutes/glucosee?style=for-the-badge&color=00BFA6" alt="Release"/>
</div>

<br/>

<h1 align="center">Glucosee</h1>
<p align="center"><b>Smart Monitoring for Better Living</b></p>

<p align="center">
  Aplikasi monitoring gula darah untuk pasien diabetes yang terintegrasi dengan tenaga medis, keluarga, dan AI asisten kesehatan.
</p>

<p align="center">
  <a href="https://github.com/mayshacutes/glucosee/releases/latest">
    <img src="https://img.shields.io/badge/APK-Download%20Now-00BFA6?style=flat-square" alt="Download APK"/>
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"/>
  </a>
</p>

---

## Fitur Utama

### Pasien
- **Monitoring Gula Darah** — Catat & pantau kadar gula darah harian
- **AiGlo (AI Asisten)** — Tanya jawab seputar diabetes & kesehatan
- **Appointment** — Booking jadwal konsultasi dengan tenaga medis
- **Pembayaran** — BPJS (gratis) atau Mandiri (Rp 50.000)
- **Chat dengan Nakes** — Konsultasi langsung via chat saat jam appointment
- **Koneksi Keluarga** — Pantau kadar gula darah oleh anggota keluarga
- **Pengingat Obat** — Notifikasi minum obat tepat waktu
- **Artikel Edukasi** — Informasi kesehatan & diabetes

### Tenaga Medis
- **Jadwal Appointment** — Kelola & setujui permintaan konsultasi
- **Chat dengan Pasien** — Konsultasi dalam masa 1x24 jam
- **Resep Obat** — Buat resep digital untuk pasien
- **Input Gula Darah** — Catat hasil pemeriksaan pasien

### Admin
- **Dashboard** — Grafik & statistik pengguna
- **Verifikasi Nakes** — Approve akun tenaga medis
- **Verifikasi Pembayaran** — Konfirmasi pembayaran pasien
- **Artikel** — Kelola artikel edukasi

---

## Download

[Download APK v1.0.0](https://github.com/mayshacutes/glucosee/releases/latest)

---

## Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter | Framework UI cross-platform |
| Dart | Bahasa pemrograman |
| Supabase | Backend (Auth, Database, Realtime) |
| Groq API | AI chatbot (Llama 3.3 70B) |
| fl_chart | Grafik & chart |
| flutter_local_notifications | Notifikasi pengingat obat |

---

## Cara Menjalankan

```bash
git clone https://github.com/mayshacutes/glucosee.git
cd glucosee
flutter pub get
cp .env.example .env
# Isi GROQ_API_KEY di .env
flutter run
Build APK:
flutter build apk --release
Dibuat dengan ❤️ untuk membantu penderita diabetes
