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

      // Crear usuario en Supabase Auth
      print('📝 Creando usuario con datos:');
      print('   - Email: $email');
      print('   - Rol: $role');
      print('   - Nombre: ${nombre ?? email.split('@')[0]}');
      print('   - Teléfono: $telefono');

      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'rol': role,
          'nombre': nombre ?? email.split('@')[0],
          'telefono': telefono,
        },
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'Error al crear usuario'};
      }

      final userId = authResponse.user!.id;
      print('✅ Usuario creado con ID: $userId');

      // Insertar datos en la tabla profiles (SIN ubicacion, lat, long)
      print('📍 Guardando datos en tabla profiles...');

      try {
        final profileData = {
          'id': userId,
          'email': email,
          'rol': role,
          'nombre': nombre ?? email.split('@')[0],
          'telefono': telefono,
        };

        print('   📤 Payload a insertar:');
        profileData.forEach((key, value) {
          print('      - $key: $value');
        });

        await _supabase.from('profiles').insert(profileData);

        print('✅ Datos insertados correctamente en profiles');
      } catch (insertError) {
        print('❌ Error al insertar en profiles: $insertError');
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

  /// Obtener perfil de usuario por ID
  static Future<Map<String, dynamic>?> getUserProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle(); // <- aquí
      return response;
    } catch (e) {
      print('Error al obtener perfil de usuario $userId: $e');
      return null;
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
  /// Obtener ID del refugio (usamos el ID del perfil del usuario refugio)
  static Future<String?> getShelterIdForCurrentUser() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('Error: No hay usuario autenticado');
        return null;
      }

      // Verificar que el usuario es un refugio
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Error: Usuario no encontrado');
        return null;
      }

      final role = user.userMetadata?['rol'] ?? user.userMetadata?['role'];
      if (role != 'refugio') {
        print('Error: El usuario no es un refugio. Rol: $role');
        return null;
      }

      // El shelter ID es el mismo que el profile ID del usuario
      return userId;
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

  /// Actualizar ubicación de refugio (SOLO para refugios)
  /// Actualiza: ubicacion (nombre del sector), lat (latitud), long (longitud)
  static Future<Map<String, dynamic>> updateShelterLocation({
    required String ubicacion,
    required double lat,
    required double long,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      // Verificar que es un refugio
      final currentRole = _currentUser?.role ?? getUserRole();
      if (currentRole != 'refugio') {
        return {
          'success': false,
          'message': 'Solo refugios pueden actualizar ubicación',
        };
      }

      // Validaciones
      if (ubicacion.trim().isEmpty) {
        return {'success': false, 'message': 'Ubicación no puede estar vacía'};
      }

      if (lat < -90 || lat > 90) {
        return {
          'success': false,
          'message': 'Latitud inválida (debe estar entre -90 y 90)',
        };
      }

      if (long < -180 || long > 180) {
        return {
          'success': false,
          'message': 'Longitud inválida (debe estar entre -180 y 180)',
        };
      }

      print('📍 Actualizando ubicación de refugio:');
      print('   - ID: $userId');
      print('   - Ubicación: $ubicacion');
      print('   - Lat: $lat');
      print('   - Long: $long');

      await _supabase
          .from('profiles')
          .update({'ubicacion': ubicacion.trim(), 'lat': lat, 'long': long})
          .eq('id', userId);

      print('✅ Ubicación actualizada correctamente');

      return {
        'success': true,
        'message': 'Ubicación actualizada correctamente',
        'data': {'ubicacion': ubicacion, 'lat': lat, 'long': long},
      };
    } catch (e) {
      print('❌ Error al actualizar ubicación: $e');
      return {'success': false, 'message': 'Error al actualizar: $e'};
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

  /// Guardar token FCM para notificaciones push
  static Future<bool> saveFCMToken(String fcmToken) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        print('Usuario no autenticado para guardar token FCM');
        return false;
      }

      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'fcm_token': fcmToken,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      print('Token FCM guardado para usuario: $userId');
      return true;
    } catch (e) {
      print('Error al guardar token FCM: $e');
      return false;
    }
  }
}
