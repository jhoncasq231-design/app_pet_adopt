import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class AdoptionRequestService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtener todas las solicitudes del usuario actual
  Future<List<Map<String, dynamic>>> getUserAdoptionRequests() async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) return [];

      final response = await _supabase
          .from('solicitud_adopcion')
          .select('''
            id,
            usuario_id,
            mascota_id,
            estado,
            fecha_solicitud,
            fecha_aprobacion,
            pets (
              id,
              nombre,
              especie,
              foto_principal,
              refugio_id,
              shelters (
                nombre,
                telefono
              )
            )
          ''')
          .eq('usuario_id', userId)
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
          .from('solicitud_adopcion')
          .select('''
            id,
            usuario_id,
            mascota_id,
            estado,
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
          .from('solicitud_adopcion')
          .select('''
            id,
            usuario_id,
            mascota_id,
            estado,
            fecha_solicitud,
            fecha_aprobacion,
            pets (
              id,
              nombre,
              especie,
              foto_principal,
              refugio_id,
              shelters (
                nombre
              )
            )
          ''')
          .eq('usuario_id', userId)
          .eq('estado', status)
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

      await _supabase.from('solicitud_adopcion').insert({
        'usuario_id': userId,
        'mascota_id': mascotaId,
        'estado': 'pendiente',
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
          .from('solicitud_adopcion')
          .update({
            'estado': 'aprobada',
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
          .from('solicitud_adopcion')
          .update({
            'estado': 'rechazada',
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
      await _supabase.from('solicitud_adopcion').delete().eq('id', requestId);

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
          .from('solicitud_adopcion')
          .select('''
            id,
            usuario_id,
            mascota_id,
            estado,
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
