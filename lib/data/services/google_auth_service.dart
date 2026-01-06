import 'package:app_pet_adopt/presentation/login/role_selection_google_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Iniciar sesión con Google
  static Future<Map<String, dynamic>> signInWithGoogle({
  required String rol,
}) async {
    try {
      // Obtener cuenta de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Inicio de sesión cancelado'};
      }

      // Obtener tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Usar el token de Google con Supabase
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      if (response.user == null) {
        return {'success': false, 'message': 'Error al autenticar con Google'};
      }

      final userId = response.user!.id;
      final userEmail = response.user!.email ?? googleUser.email;

      // Verificar o crear perfil del usuario
      try {
        await _supabase.from('profiles').select().eq('id', userId).single();

        // El perfil ya existe
        return {
          'success': true,
          'message': 'Autenticación exitosa con Google',
          'user': response.user,
        };
      } catch (e) {
        // El perfil no existe, crear uno nuevo
        // Usar 'adoptante' como rol por defecto para OAuth
        try {
  await _supabase.from('profiles').insert({
    'id': userId,
    'email': userEmail,
    'rol': RoleSelectionGooglePage, // ✅ rol elegido por el usuario
    'nombre': googleUser.displayName ?? userEmail.split('@')[0],
    'foto_perfil': googleUser.photoUrl,
  });
} catch (profileError) {
  print('Error al crear perfil: $profileError');
  // Si el perfil ya existe, continuamos
}


        return {
          'success': true,
          'message': 'Autenticación exitosa con Google',
          'user': response.user,
        };
      }
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return {
        'success': false,
        'message': 'Error al iniciar sesión con Google: $e',
      };
    }
  }

  /// Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Obtener usuario actual de Google
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }

  /// Verificar si el usuario está autenticado con Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
