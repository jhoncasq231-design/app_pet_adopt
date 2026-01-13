import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

// Servicio de sesión (mock sin SharedPreferences por ahora)
class SessionService {
  static String? _userRole;
  static bool _isLoggedIn = false;

  // Guardar rol (adoptante o refugio)
  static Future<void> setRole(String role) async {
    _userRole = role;
    _isLoggedIn = true;
  }

  // Obtener rol guardado
  static Future<String?> getRole() async {
    return _userRole;
  }

  // Verificar si está logueado
  static Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      // Cerrar sesión en AuthService (que también limpia _currentUser)
      await AuthService.logout();
    } catch (e) {
      print('Error cerrando sesión en AuthService: $e');
      try {
        // Si AuthService falla, intentar cerrar en Supabase directamente
        await Supabase.instance.client.auth.signOut();
      } catch (e2) {
        print('Error cerrando sesión en Supabase: $e2');
      }
    }

    // Limpiar variables locales de SessionService
    _userRole = null;
    _isLoggedIn = false;
  }
}
