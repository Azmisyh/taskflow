# TaskFlow - Aplikasi Manajemen Tugas Harian

Aplikasi pencatat tugas harian dengan kategori, status, dan statistik sederhana. Dibangun dengan Flutter menggunakan Supabase untuk autentikasi dan Mock API untuk simulasi data tugas.

## 🚀 Fitur

- ✅ **7 Halaman Dinamis**
  1. Login Page - Autentikasi dengan email & password
  2. Register Page - Daftar user baru
  3. Home/Dashboard - Ringkasan tugas dan statistik
  4. Task List - Daftar semua tugas dengan filter
  5. Add/Edit Task - Tambah dan edit tugas
  6. Task Detail - Detail tugas, tandai selesai, hapus
  7. Profile - Data user dan logout

- 🔐 **Autentikasi** - Menggunakan Supabase Auth
- 📊 **Statistik** - Total tugas, selesai, dan belum selesai
- 🏷️ **Kategori** - Work, Personal, Shopping, Health, Education
- 📅 **Deadline** - Set deadline untuk setiap tugas
- 🔄 **Real-time Ready** - Struktur siap untuk real-time updates

## 📋 Prerequisites

- Flutter SDK (3.10.7 atau lebih tinggi)
- Dart SDK
- Supabase Account (gratis di [supabase.com](https://supabase.com))

## 🛠️ Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd taskflownew
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

1. Buat project baru di [Supabase Dashboard](https://app.supabase.com)
2. Buka SQL Editor di Supabase Dashboard
3. Copy dan paste isi file `SUPABASE_SCHEMA.sql` ke SQL Editor
4. Jalankan script untuk membuat tabel `user_profiles`
5. Ambil **URL** dan **Anon Key** dari Settings > API

### 4. Konfigurasi Supabase di Aplikasi

Edit file `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co'; // Ganti dengan URL Anda
  static const String supabaseAnonKey = 'your-anon-key-here'; // Ganti dengan Anon Key Anda
}
```

### 5. Jalankan Aplikasi

```bash
flutter run
```

## 📁 Struktur Project

```
lib/
├── config/
│   └── supabase_config.dart      # Konfigurasi Supabase
├── models/
│   ├── task.dart                  # Model Task
│   ├── category.dart              # Model Category
│   └── user_profile.dart          # Model User Profile
├── services/
│   ├── supabase_service.dart      # Service untuk Supabase Auth & Profile
│   ├── mock_api_service.dart      # Mock API untuk simulasi data tugas
│   └── task_service.dart          # Service untuk operasi CRUD tugas
├── pages/
│   ├── login_page.dart            # Halaman Login
│   ├── register_page.dart         # Halaman Register
│   ├── home_page.dart             # Halaman Home/Dashboard
│   ├── task_list_page.dart        # Halaman Daftar Tugas
│   ├── add_edit_task_page.dart    # Halaman Tambah/Edit Tugas
│   ├── task_detail_page.dart      # Halaman Detail Tugas
│   └── profile_page.dart          # Halaman Profile
└── main.dart                      # Entry point aplikasi
```

## 🗄️ Database Schema

File `SUPABASE_SCHEMA.sql` berisi schema untuk:
- Tabel `user_profiles` - Menyimpan profil user
- Row Level Security (RLS) policies
- Auto-update trigger untuk `updated_at`

**Catatan:** Tugas dan kategori saat ini menggunakan Mock API (in-memory). Jika ingin menggunakan Supabase untuk tasks juga, uncomment bagian yang ada di file `SUPABASE_SCHEMA.sql`.

## 🎨 Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Supabase** - Backend untuk autentikasi dan database
- **Mock API Service** - Simulasi API untuk tugas dan kategori
- **Material Design 3** - Design system

## 📱 Screenshots

(Tambahkan screenshot aplikasi di sini)

## 🔄 Migrasi ke Real Database

Jika ingin menggunakan Supabase untuk menyimpan tasks (bukan Mock API):

1. Uncomment bagian tasks di `SUPABASE_SCHEMA.sql`
2. Update `mock_api_service.dart` untuk menggunakan Supabase client
3. Atau buat `supabase_task_service.dart` baru

## 📝 License

MIT License

## 👨‍💻 Author

Dibuat untuk portfolio project dengan CRUD lengkap, auth, dan realtime-ready structure.
