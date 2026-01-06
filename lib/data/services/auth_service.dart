import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de usuario
class User {
  final String id;
  final String email;
  final String role; // 'adoptante' o 'refugio'
  final String? nombre;
  final String? ubicacion;
  final String? telefono;
  final String? fotoPerfil;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.nombre,
    this.ubicacion,
    this.telefono,
    this.fotoPerfil,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['rol'],
      nombre: json['nombre'],
      ubicacion: json['ubicacion'],
      telefono: json['telefono'],
      fotoPerfil: json['foto_perfil'],
    );
  }
}

/// Servicio de autenticación
class AuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;
  static User? _currentUser;

  /// Registro de usuario
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? nombre,
    String? ubicacion,
    String? telefono,
  }) async {
    try {
      // Validaciones locales
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email y contraseña son requeridos',
        };
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
      if (role != 'adoptante' && role != 'refugio') {
        return {'success': false, 'message': 'Rol inválido'};
      }

      // Crear usuario en Supabase Auth con metadata personalizada
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'rol': role,
          'nombre': nombre ?? email.split('@')[0],
          'ubicacion': ubicacion,
          'telefono': telefono,
        },
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'Error al crear usuario'};
      }

      final userId = authResponse.user!.id;

      try {
        // El trigger en Supabase crea automáticamente el perfil
        // Actualizar perfil con datos adicionales si es necesario
        await _supabase
            .from('profiles')
            .update({
              'nombre': nombre ?? email.split('@')[0],
              'ubicacion': ubicacion,
              'telefono': telefono,
            })
            .eq('id', userId);
      } catch (e) {
        print('Error al actualizar perfil: $e');
        // No es crítico si falla la actualización
      }

      // Crear entrada en 'shelters' solo si es refugio
      if (role == 'refugio') {
        try {
          await _supabase.from('shelters').insert({
            'profile_id': userId,
            'nombre': nombre ?? email.split('@')[0],
            'email': email,
            'telefono': telefono,
            'direccion': ubicacion,
          });
        } catch (e) {
          print('Advertencia: No se pudo crear entrada de refugio: $e');
          // No fallar el registro por esto
        }
      }

      return {
        'success': true,
        'message': 'Registro exitoso. Por favor confirma tu email',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.message)};
    } catch (e) {
      print('Error en registro: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  /// Iniciar sesión
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email y contraseña son requeridos',
        };
      }

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'Email o contraseña incorrectos'};
      }

      final profile = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      if (profile == null) {
        return {
          'success': false,
          'message':
              'Perfil de usuario no encontrado. Por favor intenta registrarte nuevamente',
        };
      }

      _currentUser = User(
        id: authResponse.user!.id,
        email: authResponse.user!.email!,
        role: profile['rol'],
        nombre: profile['nombre'],
        ubicacion: profile['ubicacion'],
        telefono: profile['telefono'],
        fotoPerfil: profile['foto_perfil'],
      );

      return {'success': true, 'message': 'Inicio de sesión exitoso'};
    } on AuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.message)};
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar sesión: $e'};
    }
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  /// Obtener usuario actual
  static User? getCurrentUser() => _currentUser;
  static String? getUserRole() => _currentUser?.role;
  static String? getUserEmail() => _currentUser?.email;
  static String? getCurrentUserId() =>
      _currentUser?.id ?? _supabase.auth.currentUser?.id;

  /// Verifica si hay sesión activa
  static Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && _currentUser == null) {
        await _loadCurrentUser();
      }
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Carga el usuario actual desde Supabase
  static Future<void> _loadCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final profile = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        print('Perfil no encontrado para usuario: ${user.id}');
        return;
      }

      _currentUser = User(
        id: user.id,
        email: user.email!,
        role: profile['rol'],
        nombre: profile['nombre'],
        ubicacion: profile['ubicacion'],
        telefono: profile['telefono'],
        fotoPerfil: profile['foto_perfil'],
      );
    } catch (e) {
      print('Error al cargar usuario: $e');
    }
  }

  /// Obtener ID del refugio si el usuario es refugio
  static Future<String?> getShelterIdForCurrentUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final response = await _supabase
          .from('shelters')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();
      return response?['id'];
    } catch (e) {
      print('Error al obtener ID del refugio: $e');
      return null;
    }
  }

  /// Obtener perfil del usuario
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  /// Actualizar perfil
  static Future<bool> updateProfile({
    String? nombre,
    String? ubicacion,
    String? telefono,
    String? fotoPerfil,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (ubicacion != null) updateData['ubicacion'] = ubicacion;
      if (telefono != null) updateData['telefono'] = telefono;
      if (fotoPerfil != null) updateData['foto_perfil'] = fotoPerfil;

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          email: _currentUser!.email,
          role: _currentUser!.role,
          nombre: nombre ?? _currentUser!.nombre,
          ubicacion: ubicacion ?? _currentUser!.ubicacion,
          telefono: telefono ?? _currentUser!.telefono,
          fotoPerfil: fotoPerfil ?? _currentUser!.fotoPerfil,
        );
      }

      return true;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  /// Cambiar contraseña
  static Future<Map<String, dynamic>> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return {'success': false, 'message': 'Las contraseñas no coinciden'};
      }
      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'La contraseña debe tener al menos 6 caracteres',
        };
      }

      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.message)};
    } catch (e) {
      return {'success': false, 'message': 'Error al cambiar contraseña: $e'};
    }
  }

  /// Restablecer contraseña
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return {'success': false, 'message': 'Email inválido'};
      }

      await _supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message': 'Se ha enviado un email de recuperación',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.message)};
    } catch (e) {
      return {'success': false, 'message': 'Error al enviar email: $e'};
    }
  }

  /// Eliminar cuenta
  static Future<bool> deleteAccount() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      await _supabase.from('profiles').delete().eq('id', userId);
      await logout();
      return true;
    } catch (e) {
      print('Error al eliminar cuenta: $e');
      return false;
    }
  }

  /// Obtener errores legibles de autenticación
  static String _getAuthErrorMessage(String error) {
    if (error.contains('Invalid login credentials'))
      return 'Email o contraseña incorrectos';
    if (error.contains('Email not confirmed'))
      return 'Por favor confirma tu email';
    if (error.contains('User already registered'))
      return 'Este email ya está registrado';
    if (error.contains('Password should be at least 6 characters'))
      return 'La contraseña debe tener al menos 6 caracteres';
    if (error.contains('Invalid email')) return 'Email inválido';
    if (error.contains('weak password')) return 'La contraseña es muy débil';
    if (error.contains('Email rate limit exceeded'))
      return 'Demasiados intentos. Por favor espera un momento';
    if (error.contains('Invalid password')) return 'Contraseña incorrecta';
    return 'Error de autenticación';
  }

  /// Stream para cambios de estado de autenticación
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  /// Refrescar sesión
  static Future<bool> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      return true;
    } catch (e) {
      print('Error al refrescar sesión: $e');
      return false;
    }
  }
}
