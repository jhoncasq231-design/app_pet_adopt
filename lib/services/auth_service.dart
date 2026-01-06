// Modelo de usuario
class User {
  final String email;
  final String password;
  final String role; // 'adoptante' o 'refugio'

  User({required this.email, required this.password, required this.role});
}

// Servicio de autenticación (mock)
class AuthService {
  // Base de datos en memoria (mock)
  static final Map<String, User> _users = {
    'adoptante@test.com': User(
      email: 'adoptante@test.com',
      password: '123456',
      role: 'adoptante',
    ),
    'refugio@test.com': User(
      email: 'refugio@test.com',
      password: '123456',
      role: 'refugio',
    ),
  };

  static User? _currentUser;

  // Registrar nuevo usuario
  static Future<bool> register({
    required String email,
    required String password,
    required String role,
  }) async {
    // Verificar si el email ya existe
    if (_users.containsKey(email)) {
      return false; // Email ya registrado
    }

    // Crear nuevo usuario
    _users[email] = User(email: email, password: password, role: role);

    return true; // Registro exitoso
  }

  // Login
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final user = _users[email];

    if (user != null && user.password == password) {
      _currentUser = user;
      return true; // Login exitoso
    }

    return false; // Credenciales inválidas
  }

  // Obtener usuario actual
  static Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  // Obtener rol del usuario actual
  static Future<String?> getUserRole() async {
    return _currentUser?.role;
  }

  // Logout
  static Future<void> logout() async {
    _currentUser = null;
  }

  // Verificar si está logueado
  static Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }
}
