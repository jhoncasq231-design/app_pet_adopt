// Modelo de usuario
class User {
  final String email;
  final String password;
  final String role; // 'adoptante' o 'refugio'

  User({required this.email, required this.password, required this.role});
}

// Servicio de autenticación
class AuthService {
  // Base de datos simulada de usuarios
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

  // Usuario actualmente logueado
  static User? _currentUser;

  /// Registra un nuevo usuario
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Validaciones
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email y contraseña son requeridos'};
    }

    if (password != confirmPassword) {
      return {'success': false, 'message': 'Las contraseñas no coinciden'};
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'La contraseña debe tener al menos 6 caracteres',
      };
    }

    if (!email.contains('@')) {
      return {'success': false, 'message': 'Email inválido'};
    }

    if (_users.containsKey(email)) {
      return {'success': false, 'message': 'Este email ya está registrado'};
    }

    if (role != 'adoptante' && role != 'refugio') {
      return {'success': false, 'message': 'Rol inválido'};
    }

    // Crear nuevo usuario
    final newUser = User(email: email, password: password, role: role);

    _users[email] = newUser;

    return {
      'success': true,
      'message': 'Registro exitoso. Por favor inicia sesión',
    };
  }

  /// Inicia sesión de un usuario
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Validar campos vacíos
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email y contraseña son requeridos'};
    }

    // Buscar usuario
    if (!_users.containsKey(email)) {
      return {'success': false, 'message': 'Email o contraseña incorrectos'};
    }

    final user = _users[email]!;

    // Verificar contraseña
    if (user.password != password) {
      return {'success': false, 'message': 'Email o contraseña incorrectos'};
    }

    // Login exitoso
    _currentUser = user;

    return {'success': true, 'message': 'Inicio de sesión exitoso'};
  }

  /// Cierra la sesión actual
  static Future<void> logout() async {
    _currentUser = null;
  }

  /// Obtiene el usuario actualmente logueado
  static User? getCurrentUser() {
    return _currentUser;
  }

  /// Obtiene el rol del usuario actualmente logueado
  static String? getUserRole() {
    return _currentUser?.role;
  }

  /// Obtiene el email del usuario actualmente logueado
  static String? getUserEmail() {
    return _currentUser?.email;
  }

  /// Verifica si hay un usuario logueado
  static Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }
}
