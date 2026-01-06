import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para gestionar notificaciones de solicitudes de adopción
class AdoptionNotificationService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Guardar token FCM del usuario en la base de datos
  static Future<bool> saveFCMTokenForUser(
    String userId,
    String fcmToken,
  ) async {
    try {
      // Crear o actualizar registro de FCM token
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

  /// Enviar notificación cuando se crea una nueva solicitud de adopción
  static Future<bool> notifyNewAdoptionRequest(
    String petId,
    String petName,
    String shelterId,
    String shelterName,
    String adoptantName,
  ) async {
    try {
      // Obtener token FCM del refugio
      final response = await _supabase
          .from('user_fcm_tokens')
          .select('fcm_token')
          .eq('user_id', shelterId)
          .maybeSingle();

      if (response != null && response['fcm_token'] != null) {
        // En una aplicación real, esto enviaría a un servidor backend
        // que usa el SDK de Firebase Admin para enviar notificaciones
        print(
          'Notificar a refugio: Nueva solicitud para $petName de $adoptantName',
        );
        // TODO: Implementar envío de notificación vía backend
        return true;
      }

      return false;
    } catch (e) {
      print('Error al notificar solicitud de adopción: $e');
      return false;
    }
  }

  /// Enviar notificación cuando se actualiza el estado de una solicitud
  static Future<bool> notifyAdoptionRequestStatusChange(
    String adoptantId,
    String petName,
    String newStatus,
    String shelterName,
  ) async {
    try {
      // Obtener token FCM del adoptante
      final response = await _supabase
          .from('user_fcm_tokens')
          .select('fcm_token')
          .eq('user_id', adoptantId)
          .maybeSingle();

      if (response != null && response['fcm_token'] != null) {
        final statusMessage = _getStatusMessage(newStatus, petName);
        print('Notificar a adoptante: $statusMessage desde $shelterName');
        // TODO: Implementar envío de notificación vía backend
        return true;
      }

      return false;
    } catch (e) {
      print('Error al notificar cambio de estado: $e');
      return false;
    }
  }

  /// Suscribir a cambios en solicitudes de adopción
  static void listenToAdoptionRequests(
    String userId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    try {
      print('Escuchando cambios en solicitudes para refugio: $userId');
    } catch (e) {
      print('Error al escuchar cambios: $e');
    }
  }

  /// Suscribir a cambios en el estado de solicitudes del adoptante
  static void listenToMyAdoptionRequests(
    String adoptantId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    try {
      print('Escuchando cambios en mis solicitudes: $adoptantId');
    } catch (e) {
      print('Error al escuchar cambios: $e');
    }
  }

  /// Obtener mensaje de estado personalizado
  static String _getStatusMessage(String status, String petName) {
    switch (status) {
      case 'aprobada':
        return '¡Felicidades! Tu solicitud para $petName ha sido aprobada 🎉';
      case 'rechazada':
        return 'Lamentablemente, tu solicitud para $petName fue rechazada.';
      case 'en_revision':
        return 'Tu solicitud para $petName está siendo revisada.';
      case 'pendiente':
        return 'Tu solicitud para $petName ha sido registrada.';
      default:
        return 'Actualización en tu solicitud para $petName.';
    }
  }

  /// Limpiar tokens FCM cuando el usuario cierra sesión
  static Future<bool> removeFCMToken(String userId) async {
    try {
      await _supabase.from('user_fcm_tokens').delete().eq('user_id', userId);
      print('Token FCM removido para usuario: $userId');
      return true;
    } catch (e) {
      print('Error al remover token FCM: $e');
      return false;
    }
  }
}
