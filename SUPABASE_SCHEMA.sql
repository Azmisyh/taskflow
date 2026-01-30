-- ============================================
-- SUPABASE DATABASE SCHEMA UNTUK TASKFLOW
-- ============================================
-- 
-- Import file ini ke Supabase SQL Editor untuk membuat tabel yang diperlukan
-- 
-- Langkah:
-- 1. Buka Supabase Dashboard
-- 2. Pilih project Anda
-- 3. Buka SQL Editor
-- 4. Copy paste script ini
-- 5. Jalankan (Run)
-- ============================================

-- Tabel untuk menyimpan profil user
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa melihat dan edit profil mereka sendiri
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Function untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk auto-update updated_at
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- CATATAN PENTING:
-- ============================================
-- 
-- 1. Tabel 'tasks' dan 'categories' menggunakan Mock API Service
--    (disimulasikan di dalam aplikasi Flutter)
-- 
-- 2. Jika ingin menggunakan Supabase untuk tasks juga, 
--    buat tabel berikut:
-- 
-- CREATE TABLE IF NOT EXISTS tasks (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
--   title TEXT NOT NULL,
--   description TEXT,
--   category_id TEXT NOT NULL,
--   category_name TEXT NOT NULL,
--   is_completed BOOLEAN DEFAULT FALSE,
--   deadline TIMESTAMP WITH TIME ZONE,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- 
-- CREATE TABLE IF NOT EXISTS categories (
--   id TEXT PRIMARY KEY,
--   name TEXT NOT NULL,
--   color TEXT NOT NULL DEFAULT '#2196F3'
-- );
-- 
-- -- RLS untuk tasks
-- ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
-- 
-- CREATE POLICY "Users can view own tasks"
--   ON tasks FOR SELECT
--   USING (auth.uid() = user_id);
-- 
-- CREATE POLICY "Users can insert own tasks"
--   ON tasks FOR INSERT
--   WITH CHECK (auth.uid() = user_id);
-- 
-- CREATE POLICY "Users can update own tasks"
--   ON tasks FOR UPDATE
--   USING (auth.uid() = user_id);
-- 
-- CREATE POLICY "Users can delete own tasks"
--   ON tasks FOR DELETE
--   USING (auth.uid() = user_id);
-- 
-- -- Insert default categories
-- INSERT INTO categories (id, name, color) VALUES
--   ('1', 'Work', '#FF5722'),
--   ('2', 'Personal', '#2196F3'),
--   ('3', 'Shopping', '#4CAF50'),
--   ('4', 'Health', '#9C27B0'),
--   ('5', 'Education', '#FF9800')
-- ON CONFLICT (id) DO NOTHING;
-- 
-- ============================================
