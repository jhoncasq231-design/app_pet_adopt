import '../../presentation/login/role_selection_google_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Iniciar sesión con Google
  static Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
      queryParams: {
        'access_type': 'offline',
        'prompt': 'consent',
      },
    );
  }
}
 