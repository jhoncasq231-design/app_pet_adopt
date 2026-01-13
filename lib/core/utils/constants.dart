import 'package:flutter/material.dart';

/// Constantes globales de la aplicación
class AppConstants {
  // Supabase
  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Firebase/Messaging
  static const String fcmTopic = 'pet_adopt';

  // Roles de usuario
  static const String roleAdoptant = 'adoptante';
  static const String roleShelter = 'refugio';

  // Mensajes de error genéricos
  static const String errorServerMessage =
      'Error en el servidor. Por favor intenta más tarde.';
  static const String errorConnectionMessage =
      'Sin conexión. Verifica tu internet.';
  static const String errorUnknownMessage =
      'Error desconocido. Por favor intenta de nuevo.';

  // Límites
  static const int maxImageUploadSizeMB = 10;
  static const int maxDescriptionLength = 500;
}

class AppColors {
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color primaryTeal = Color(0xFF2EC4B6);
  static const Color background = Color(0xFFFFF6EE);
  static const Color textDark = Color(0xFF212529);
  static const Color pending = Colors.amber;
  static const Color approved = Colors.green;
  static const Color rejected = Colors.red;
}
