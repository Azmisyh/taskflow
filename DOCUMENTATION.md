# 📚 TaskFlow - Dokumentasi Lengkap

## 🎯 Overview
TaskFlow adalah aplikasi manajemen tugas harian yang dibangun dengan Flutter dan Supabase. Aplikasi ini memiliki 8 halaman dinamis dengan fitur CRUD lengkap, autentikasi, dan statistik real-time.

---

## 📱 Daftar Halaman Dinamis

### 1️⃣ **Splash Screen** (`splash_screen.dart`)
**Fungsi:**
- Menampilkan animasi saat aplikasi pertama kali dibuka
- Mengecek status autentikasi user
- Redirect otomatis ke Login atau Home berdasarkan status login

**Data Dinamis:**
- Status autentikasi dari Supabase
- Animasi fade dan scale untuk UX yang lebih baik

**Fitur:**
- ✅ Animasi loading dengan fade & scale
- ✅ Auto-redirect berdasarkan auth state
- ✅ Gradient background yang menarik

---

### 2️⃣ **Login Page** (`login_page.dart`)
**Fungsi:**
- Autentikasi user dengan email & password menggunakan Supabase Auth
- Validasi form input
- Redirect ke Home setelah login berhasil

**Data Dinamis:**
- Status login dari Supabase
- Error message dari Supabase Auth
- Loading state saat proses login

**Fitur:**
- ✅ Form validation (email format, password min 6 karakter)
- ✅ Toggle visibility password
- ✅ Error handling dengan pesan yang jelas
- ✅ Loading indicator
- ✅ Navigasi ke Register Page
- ✅ Gradient background

---

### 3️⃣ **Register Page** (`register_page.dart`)
**Fungsi:**
- Pendaftaran user baru
- Menyimpan profil user ke Supabase (username, email, created_at)
- Auto-login setelah registrasi berhasil

**Data Dinamis:**
- Response dari Supabase Auth
- Success/error message
- Loading state

**Fitur:**
- ✅ Form validation lengkap
- ✅ Konfirmasi password
- ✅ Toggle visibility untuk kedua password field
- ✅ Success message sebelum redirect
- ✅ Error handling
- ✅ Auto-create user profile di database

---

### 4️⃣ **Home / Dashboard Page** (`home_page.dart`)
**Fungsi:**
- Menampilkan ringkasan tugas harian
- Progress tracking dengan completion rate
- Organisasi tugas berdasarkan prioritas (Today, Upcoming, Overdue)

**Data Dinamis:**
- Fetch tasks dari Mock API berdasarkan user ID
- Statistik dihitung real-time:
  - Total tugas
  - Tugas selesai
  - Tugas pending
  - Completion rate (persentase)
- Today's tasks (tugas dengan deadline hari ini)
- Upcoming tasks (tugas dalam 3 hari ke depan)
- Overdue tasks (tugas yang melewati deadline)

**Fitur:**
- ✅ **Progress Card** dengan completion rate dan progress bar
- ✅ **Statistik Cards** (Total, Selesai, Pending) dengan gradient
- ✅ **Overdue Alert Card** untuk tugas terlambat
- ✅ **Today's Tasks Section** - tugas hari ini yang belum selesai
- ✅ **Upcoming Tasks Section** - tugas mendatang (3 hari)
- ✅ **Recent Tasks** - tugas terbaru jika tidak ada today/upcoming
- ✅ **Empty State** dengan call-to-action
- ✅ **Skeleton Loading** untuk better UX
- ✅ **Pull to Refresh**
- ✅ **Search Button** di AppBar
- ✅ **Statistics Button** di AppBar
- ✅ **Profile Button** di AppBar
- ✅ **FloatingActionButton** untuk tambah tugas

---

### 5️⃣ **Task List Page** (`task_list_page.dart`)
**Fungsi:**
- Menampilkan semua tugas user
- Filter berdasarkan status (Semua, Selesai, Belum Selesai)
- Navigasi ke detail atau tambah tugas

**Data Dinamis:**
- GET task list dari Mock API
- Filter dinamis berdasarkan status
- Update UI saat status berubah

**Fitur:**
- ✅ **Filter Chips** (Semua, Selesai, Belum Selesai)
- ✅ **Task Cards** dengan informasi lengkap:
  - Icon kategori dengan warna
  - Judul tugas
  - Badge kategori
  - Deadline dengan format smart (Hari ini, Besok, atau tanggal)
  - Status indicator (check, warning, atau unchecked)
- ✅ **Empty State** yang informatif
- ✅ **Skeleton Loading**
- ✅ **Pull to Refresh**
- ✅ **FloatingActionButton** untuk tambah tugas
- ✅ **Haptic Feedback** pada interaksi

---

### 6️⃣ **Add / Edit Task Page** (`add_edit_task_page.dart`)
**Fungsi:**
- Tambah tugas baru
- Edit tugas yang sudah ada
- Pilih kategori dan set deadline

**Data Dinamis:**
- POST/PUT ke Mock API
- Data kategori dari API
- Pre-fill data saat edit mode

**Fitur:**
- ✅ **Form Validation** untuk judul dan kategori
- ✅ **Category Dropdown** dengan icon dan warna
- ✅ **Date & Time Picker** untuk deadline
- ✅ **Remove Deadline** button
- ✅ **Loading State** saat save
- ✅ **Success/Error Snackbar**
- ✅ **Haptic Feedback**
- ✅ **Auto-navigate back** setelah save

---

### 7️⃣ **Task Detail Page** (`task_detail_page.dart`)
**Fungsi:**
- Menampilkan detail lengkap tugas
- Tandai selesai/belum selesai
- Hapus tugas
- Edit tugas

**Data Dinamis:**
- GET task by ID dari Mock API
- PATCH status selesai (toggle)
- DELETE task

**Fitur:**
- ✅ **Status Badge** (Selesai/Belum Selesai) dengan warna
- ✅ **Category Card** dengan icon dan warna
- ✅ **Description Card** (jika ada)
- ✅ **Deadline Card** dengan indikator overdue (warna merah)
- ✅ **Info Cards** (Dibuat, Diupdate)
- ✅ **Toggle Status Button** dengan loading state
- ✅ **Delete Button** dengan konfirmasi dialog
- ✅ **Edit Button** di AppBar
- ✅ **Haptic Feedback**
- ✅ **Success/Error Snackbar**

---

### 8️⃣ **Profile Page** (`profile_page.dart`)
**Fungsi:**
- Menampilkan data user (email, username, tanggal bergabung)
- Edit username
- Logout

**Data Dinamis:**
- Data user dari Supabase (user_profiles table)
- Update username ke database
- State login/logout

**Fitur:**
- ✅ **Avatar** dengan gradient border
- ✅ **Email Card** (read-only)
- ✅ **Username Card** dengan inline editing
- ✅ **Join Date Card**
- ✅ **Logout Button** dengan konfirmasi
- ✅ **Loading State**
- ✅ **Success/Error Snackbar**

---

### 9️⃣ **Statistics Page** (`statistics_page.dart`) - BONUS
**Fungsi:**
- Menampilkan statistik detail tugas
- Analisis berdasarkan kategori
- Statistik mingguan

**Data Dinamis:**
- Fetch semua tasks dari Mock API
- Kalkulasi statistik real-time:
  - Completion rate
  - Tasks by category
  - Completed this week
  - Overdue count

**Fitur:**
- ✅ **Overall Stats Cards** (Total, Selesai, Pending)
- ✅ **Completion Rate Card** dengan progress bar dan emoji indicator
- ✅ **Weekly Stats** (Selesai minggu ini, Terlambat)
- ✅ **Tasks by Category** dengan progress bar per kategori
- ✅ **Pull to Refresh**

---

## 🎨 Widgets & Components

### **Custom Widgets:**

1. **EmptyState** (`widgets/empty_state.dart`)
   - Widget reusable untuk empty state
   - Support icon, title, message, dan action button

2. **SkeletonLoader** (`widgets/skeleton_loader.dart`)
   - Loading animation dengan shimmer effect
   - TaskCardSkeleton untuk preview struktur

3. **CustomSnackBar** (`widgets/custom_snackbar.dart`)
   - Success, Error, dan Info snackbar
   - Dengan icon dan styling yang konsisten

---

## 🔧 Services & Models

### **Services:**

1. **SupabaseService** (`services/supabase_service.dart`)
   - Authentication (signUp, signIn, signOut)
   - User Profile management (getUserProfile, updateUsername)
   - Auth state changes listener

2. **MockApiService** (`services/mock_api_service.dart`)
   - Simulasi API untuk tasks dan categories
   - In-memory storage untuk demo
   - CRUD operations untuk tasks

3. **TaskService** (`services/task_service.dart`)
   - Wrapper untuk MockApiService
   - Business logic untuk task operations
   - Filter tasks by status

### **Models:**

1. **Task** (`models/task.dart`)
   - id, title, description
   - categoryId, categoryName
   - isCompleted
   - deadline (nullable)
   - createdAt, updatedAt
   - userId

2. **Category** (`models/category.dart`)
   - id, name, color

3. **UserProfile** (`models/user_profile.dart`)
   - id, email, username
   - createdAt

---

## 🎯 Fitur Utama Aplikasi

### **1. Authentication & Authorization**
- ✅ Supabase Auth integration
- ✅ Email & Password login
- ✅ User registration
- ✅ Auto-login setelah registrasi
- ✅ Logout dengan konfirmasi
- ✅ Auth state persistence

### **2. Task Management (CRUD)**
- ✅ **Create**: Tambah tugas baru dengan kategori & deadline
- ✅ **Read**: List semua tugas, detail tugas, filter
- ✅ **Update**: Edit tugas, toggle status selesai
- ✅ **Delete**: Hapus tugas dengan konfirmasi

### **3. Smart Organization**
- ✅ **Today's Tasks**: Tugas dengan deadline hari ini
- ✅ **Upcoming Tasks**: Tugas dalam 3 hari ke depan
- ✅ **Overdue Alert**: Notifikasi tugas terlambat
- ✅ **Category-based**: Organisasi berdasarkan kategori

### **4. Statistics & Analytics**
- ✅ **Progress Tracking**: Completion rate dengan progress bar
- ✅ **Overall Stats**: Total, Selesai, Pending
- ✅ **Weekly Stats**: Selesai minggu ini, Terlambat
- ✅ **Category Analysis**: Distribusi tugas per kategori

### **5. User Experience**
- ✅ **Skeleton Loading**: Preview struktur saat loading
- ✅ **Empty States**: Panduan saat tidak ada data
- ✅ **Haptic Feedback**: Umpan balik sentuhan
- ✅ **Pull to Refresh**: Refresh data dengan gesture
- ✅ **Smooth Animations**: Transisi antar halaman
- ✅ **Error Handling**: Pesan error yang jelas
- ✅ **Success Feedback**: Notifikasi sukses

### **6. UI/UX Enhancements**
- ✅ **Material Design 3**: Design system modern
- ✅ **Gradient Cards**: Statistik dengan gradient
- ✅ **Color-coded Categories**: Visual yang jelas
- ✅ **Smart Date Format**: "Hari ini", "Besok", atau tanggal
- ✅ **Status Indicators**: Visual untuk status tugas
- ✅ **Responsive Layout**: Adaptif untuk berbagai ukuran

---

## 🗄️ Database Schema (Supabase)

### **Table: user_profiles**
```sql
- id (UUID, Primary Key, References auth.users)
- email (TEXT, NOT NULL)
- username (TEXT, nullable)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

**Row Level Security (RLS):**
- Users hanya bisa melihat/edit profil mereka sendiri
- Auto-insert saat registrasi

---

## 🔄 Data Flow

### **Authentication Flow:**
1. User input email & password
2. Supabase Auth validates credentials
3. On success: Create/Update user_profiles
4. Navigate to Home Page

### **Task Management Flow:**
1. User creates/edits task
2. Data saved to Mock API (in-memory)
3. UI updates immediately
4. Data persists during session

### **Statistics Flow:**
1. Fetch all tasks from Mock API
2. Calculate statistics in real-time
3. Display with visual indicators
4. Update on refresh

---

## 📦 Dependencies

```yaml
- flutter: SDK
- supabase_flutter: ^2.5.6 (Authentication & Database)
- http: ^1.2.2 (HTTP requests - untuk future API integration)
- intl: ^0.19.0 (Date formatting)
- shared_preferences: ^2.2.3 (Local storage - untuk future features)
```

---

## 🚀 Setup Instructions

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Setup Supabase:**
   - Buat project di supabase.com
   - Jalankan script di `SUPABASE_SCHEMA.sql`
   - Update credentials di `lib/config/supabase_config.dart`

3. **Run Application:**
   ```bash
   flutter run
   ```

---

## 📊 Statistik Kode

- **Total Halaman**: 9 (8 dinamis + 1 splash)
- **Total Widgets**: 3 custom widgets
- **Total Services**: 3 services
- **Total Models**: 3 models
- **Lines of Code**: ~3000+ lines

---

## 🎓 Teknologi yang Digunakan

- **Flutter**: UI Framework
- **Dart**: Programming Language
- **Supabase**: Backend (Auth + Database)
- **Material Design 3**: Design System
- **Mock API**: Simulasi data untuk demo

---

## 🔮 Future Enhancements (Opsional)

- [ ] Real-time sync dengan Supabase
- [ ] Push notifications untuk deadline
- [ ] Task priorities (High, Medium, Low)
- [ ] Subtasks support
- [ ] Task attachments
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Export tasks (PDF/CSV)
- [ ] Task templates
- [ ] Recurring tasks

---

## 📝 Notes

- **Mock API**: Saat ini menggunakan in-memory storage. Untuk production, ganti dengan Supabase atau REST API.
- **Categories**: Hardcoded di MockApiService. Bisa diubah menjadi dinamis dengan database.
- **Authentication**: Menggunakan Supabase Auth dengan Row Level Security.

---

**Dibuat dengan ❤️ untuk portfolio project**
