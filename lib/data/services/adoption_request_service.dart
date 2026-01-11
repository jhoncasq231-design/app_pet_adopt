import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class AdoptionRequestService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtener todas las solicitudes del user actual
  Future<List<Map<String, dynamic>>> getUserAdoptionRequests() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return [];

      final response = await _supabase
          .from('adoptions')
          .select('''
            id,
            user_id,
            pet_id,
            status,
            fecha_solicitud,
            fecha_aprobacion,
            pets (
              id,
              nombre,
              especie,
              foto_principal,
              refugio_id
            )
          ''')
          .eq('user_id', userId)
          .order('fecha_solicitud', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener solicitudes de adopción: $e');
      return [];
    }
  }

  /// Obtener solicitudes para un refugio (para ver las solicitudes que recibió)
  Future<List<Map<String, dynamic>>> getShelterAdoptionRequests() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return [];

      final response = await _supabase
          .from('adoptions')
          .select('''
            id,
            user_id,
            pet_id,
            status,
            fecha_solicitud,
            fecha_aprobacion,
            profiles (
              nombre,
              telefono,
              ubicacion,
              email
            ),
            pets (
              id,
              nombre,
              especie,
              foto_principal,
              refugio_id
            )
          ''')
          .eq('pets.refugio_id', userId)
          .order('fecha_solicitud', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener solicitudes del refugio: $e');
      return [];
    }
  }

  /// Obtener solicitudes filtradas por estado
  Future<List<Map<String, dynamic>>> getRequestsByStatus(String status) async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return [];

      final response = await _supabase
          .from('adoptions')
          .select('''
            id,
            user_id,
            pet_id,
            status,
            fecha_solicitud,
            fecha_aprobacion,
            pets (
              id,
              nombre,
              especie,
              foto_principal,
              refugio_id
            )
          ''')
          .eq('user_id', userId)
          .eq('status', status)
          .order('fecha_solicitud', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener solicitudes por estado: $e');
      return [];
    }
  }

  /// Crear una nueva solicitud de adopción
  Future<bool> createAdoptionRequest({required String mascotaId}) async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return false;

      await _supabase.from('adoptions').insert({
        'user_id': userId,
        'pet_id': mascotaId,
        'status': 'pendiente',
        'fecha_solicitud': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error al crear solicitud de adopción: $e');
      return false;
    }
  }

  /// Aprobar una solicitud de adopción (para refugios)
  Future<bool> approveAdoptionRequest(String requestId) async {
    try {
      await _supabase
          .from('adoptions')
          .update({
            'status': 'aprobada',
            'fecha_aprobacion': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      return true;
    } catch (e) {
      print('Error al aprobar solicitud: $e');
      return false;
    }
  }

  /// Rechazar una solicitud de adopción (para refugios)
  Future<bool> rejectAdoptionRequest(String requestId) async {
    try {
      await _supabase
          .from('adoptions')
          .update({
            'status': 'rechazada',
            'fecha_aprobacion': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      return true;
    } catch (e) {
      print('Error al rechazar solicitud: $e');
      return false;
    }
  }

  /// Eliminar una solicitud de adopción
  Future<bool> deleteAdoptionRequest(String requestId) async {
    try {
      await _supabase.from('adoptions').delete().eq('id', requestId);

      return true;
    } catch (e) {
      print('Error al eliminar solicitud: $e');
      return false;
    }
  }

  /// Obtener detalles de una solicitud específica
  Future<Map<String, dynamic>?> getAdoptionRequestDetails(
    String requestId,
  ) async {
    try {
      final response = await _supabase
          .from('adoptions')
          .select('''
            id,
            user_id,
            pet_id,
            status,
            fecha_solicitud,
            fecha_aprobacion,
            profiles (
              nombre,
              telefono,
              ubicacion
            ),
            pets (
              id,
              nombre,
              especie,
              raza,
              tamano,
              edad_meses,
              sexo,
              descripcion,
              foto_principal,
              refugio_id
            )
          ''')
          .eq('id', requestId)
          .single();

      return response;
    } catch (e) {
      print('Error al obtener detalles de solicitud: $e');
      return null;
    }
  }
}
