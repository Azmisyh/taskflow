import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Auth Methods
  static Future<AuthResponse> signUp(String email, String password, String username) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Simpan profil user ke database
      await _client.from('user_profiles').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // User Profile Methods
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUsername(String userId, String username) async {
    await _client
        .from('user_profiles')
        .update({'username': username})
        .eq('id', userId);
  }
}
