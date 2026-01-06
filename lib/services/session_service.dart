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
    _userRole = null;
    _isLoggedIn = false;
  }
}
