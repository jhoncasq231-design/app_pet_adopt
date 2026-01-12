//app_pet_adopt\lib\data\services\adoption_request_service.dart
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
            fecha_respuesta, 
            profiles:profiles!adoptions_user_id_fkey (
              id,
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
          .eq('user_id', userId)
          .order('fecha_solicitud', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener solicitudes de adopción: $e');
      return [];
    }
  }

  /// correcion opcion1
  /// Obtener solicitudes recibidas por el refugio
  /// Obtener solicitudes recibidas por el refugio, con perfiles de usuarios
 Future<List<Map<String, dynamic>>> getShelterAdoptionRequests() async {
  try {
    final shelterProfileId = await AuthService.getShelterIdForCurrentUser();
    if (shelterProfileId == null) return [];

    final pets = await _supabase
        .from('pets')
        .select('id')
        .eq('refugio_id', shelterProfileId);

    final petIds = pets.map((p) => p['id']).toList();
    if (petIds.isEmpty) return [];

    final response = await _supabase
        .from('adoptions')
        .select('id, status, pet_id, user_id, fecha_solicitud, fecha_respuesta')
        .inFilter('pet_id', petIds)
        .order('fecha_solicitud', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error refugio solicitudes: $e');
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
            fecha_respuesta,
            profiles:profiles!adoptions_user_id_fkey (
              id,
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
    final cleanId = requestId.trim();
    print('DEBUG: Aprobando solicitud con ID: "$cleanId"');

    // 1️⃣ Obtener solicitud (para saber pet_id)
    final request = await _supabase
        .from('adoptions')
        .select('id, pet_id, status')
        .eq('id', cleanId)
        .maybeSingle();

    if (request == null) {
      print('ERROR: Solicitud no encontrada');
      return false;
    }

    final petId = request['pet_id'];

    // 2️⃣ Aprobar solicitud
    await _supabase.from('adoptions').update({
      'status': 'aprobada',
      'fecha_respuesta': DateTime.now().toIso8601String(),
    }).eq('id', cleanId);

    // 3️⃣ Marcar mascota como adoptada
    await _supabase.from('pets').update({
      'estado': 'adoptado',
    }).eq('id', petId);

    // 4️⃣ Rechazar otras solicitudes de esa mascota
    await _supabase
        .from('adoptions')
        .update({
          'status': 'rechazada',
          'fecha_respuesta': DateTime.now().toIso8601String(),
        })
        .eq('pet_id', petId)
        .neq('id', cleanId);

    print('DEBUG: Solicitud aprobada y mascota adoptada');
    return true;
  } catch (e) {
    print('Error al aprobar solicitud: $e');
    return false;
  }
}


  /// Rechazar una solicitud de adopción (para refugios)
  Future<bool> rejectAdoptionRequest(String requestId) async {
    try {
      // Limpiar espacios invisibles
      final cleanId = requestId.trim();
      print('DEBUG: Rechazando solicitud con ID: "$cleanId"');

      // Primero verificar que el registro existe
      final existingRecord = await _supabase
          .from('adoptions')
          .select('id, status')
          .eq('id', cleanId)
          .maybeSingle();

      if (existingRecord == null) {
        print('ERROR: No se encontró solicitud con ID: $cleanId');
        return false;
      }

      print(
        'DEBUG: Registro encontrado. Status actual: ${existingRecord['status']}',
      );

      // Ahora actualizar usando .select() para confirmar
      final updatedRecord = await _supabase
          .from('adoptions')
          .update({
            'status': 'rechazada',
            'fecha_respuesta': DateTime.now().toIso8601String(),
          })
          .eq('id', cleanId)
          .select('id, status, fecha_respuesta');

      print('DEBUG: Registro actualizado: $updatedRecord');

      // Verificar que realmente cambió
      if (updatedRecord.isNotEmpty) {
        final updated = updatedRecord[0];
        print('DEBUG: Nuevo status: ${updated['status']}');
        return updated['status'] == 'rechazada';
      }

      return false;
    } catch (e) {
      print('Error al rechazar solicitud: $e');
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
            fecha_respuesta,
            profiles:profiles!adoptions_user_id_fkey (
              id,
              nombre,
              telefono,
              ubicacion,
              email
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
