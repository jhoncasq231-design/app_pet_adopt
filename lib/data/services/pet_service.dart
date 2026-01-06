import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import 'storage_service.dart';

class PetService {
  final _storageService = StorageService();

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Obtener todas las mascotas disponibles (para adoptantes)
  Future<List<PetModel>> getAllPets() async {
    try {
      final response = await _supabase
          .from('pets')
          .select('*, shelter:shelters(nombre, telefono)')
          .eq('estado', 'disponible')
          .order('created_at', ascending: false);

      return response.map<PetModel>((e) => PetModel.fromJson(e)).toList();
    } catch (e) {
      print('Error al obtener mascotas: $e');
      return [];
    }
  }

  /// Obtener mascotas de un refugio específico
  Future<List<PetModel>> getPetsByRefugioId(String refugioId) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('refugio_id', refugioId)
          .order('created_at', ascending: false);

      return response.map<PetModel>((e) => PetModel.fromJson(e)).toList();
    } catch (e) {
      print('Error al obtener mascotas del refugio: $e');
      return [];
    }
  }

  /// Crear una nueva mascota
  Future<Map<String, dynamic>> createPet({
    required String nombre,
    required String especie,
    required String refugioId,
    String? raza,
    int? edadMeses,
    String? descripcion,
    String? sexo,
    String? tamano,
    bool vacunado = false,
    bool desparasitado = false,
    bool esterilizado = false,
    bool microchip = false,
    bool cuidadosEspeciales = false,
    String? notasSalud,
    List<File>? imageFiles,
    int? mainPhotoIndex,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'Usuario no autenticado'};
      }

      List<String> photoUrls = [];
      String? mainPhoto;

      if (imageFiles != null && imageFiles.isNotEmpty) {
        photoUrls = await _storageService.uploadMultiplePetImages(
          imageFiles,
          userId,
        );

        if (photoUrls.isEmpty) {
          return {'success': false, 'message': 'Error al subir las fotos'};
        }

        mainPhoto =
            (mainPhotoIndex != null && mainPhotoIndex < photoUrls.length)
            ? photoUrls[mainPhotoIndex]
            : photoUrls.first;
      }

      final petData = <String, dynamic>{
        'nombre': nombre,
        'especie': especie,
        'refugio_id': refugioId,
        'fotos': photoUrls,
        'foto_principal': mainPhoto,
        'estado': 'disponible',
        'vacunado': vacunado,
        'desparasitado': desparasitado,
        'esterilizado': esterilizado,
        'microchip': microchip,
        'cuidados_especiales': cuidadosEspeciales,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Agregar campos opcionales solo si no son null
      if (raza != null) petData['raza'] = raza;
      if (edadMeses != null) petData['edad_meses'] = edadMeses;
      if (descripcion != null) petData['descripcion'] = descripcion;
      // Solo agregar sexo si es válido (macho o hembra)
      if (sexo != null && (sexo == 'macho' || sexo == 'hembra')) {
        petData['sexo'] = sexo;
      }
      if (tamano != null) petData['tamano'] = tamano;
      if (notasSalud != null) petData['notas_salud'] = notasSalud;

      final response = await _supabase
          .from('pets')
          .insert(petData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Mascota registrada exitosamente',
        'pet': PetModel.fromJson(response),
      };
    } catch (e) {
      print('Error al crear mascota: $e');
      return {'success': false, 'message': 'Error al registrar mascota: $e'};
    }
  }

  /// Actualizar una mascota existente
  Future<Map<String, dynamic>> updatePet({
    required String petId,
    String? nombre,
    String? especie,
    String? raza,
    int? edadMeses,
    String? descripcion,
    String? sexo,
    String? tamano,
    bool? vacunado,
    bool? desparasitado,
    bool? esterilizado,
    bool? microchip,
    bool? cuidadosEspeciales,
    String? notasSalud,
    String? estado,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (nombre != null) updateData['nombre'] = nombre;
      if (especie != null) updateData['especie'] = especie;
      if (raza != null) updateData['raza'] = raza;
      if (edadMeses != null) updateData['edad_meses'] = edadMeses;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (sexo != null) updateData['sexo'] = sexo;
      if (tamano != null) updateData['tamano'] = tamano;
      if (vacunado != null) updateData['vacunado'] = vacunado;
      if (desparasitado != null) updateData['desparasitado'] = desparasitado;
      if (esterilizado != null) updateData['esterilizado'] = esterilizado;
      if (microchip != null) updateData['microchip'] = microchip;
      if (cuidadosEspeciales != null)
        updateData['cuidados_especiales'] = cuidadosEspeciales;
      if (notasSalud != null) updateData['notas_salud'] = notasSalud;
      if (estado != null) updateData['estado'] = estado;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('pets')
          .update(updateData)
          .eq('id', petId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Mascota actualizada exitosamente',
        'pet': PetModel.fromJson(response),
      };
    } catch (e) {
      print('Error al actualizar mascota: $e');
      return {'success': false, 'message': 'Error al actualizar mascota: $e'};
    }
  }

  /// Eliminar una mascota
  Future<Map<String, dynamic>> deletePet(String petId) async {
    try {
      await _supabase.from('pets').delete().eq('id', petId);

      return {'success': true, 'message': 'Mascota eliminada exitosamente'};
    } catch (e) {
      print('Error al eliminar mascota: $e');
      return {'success': false, 'message': 'Error al eliminar mascota: $e'};
    }
  }

  /// Obtener una mascota por ID
  Future<PetModel?> getPetById(String petId) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('id', petId)
          .single();

      return PetModel.fromJson(response);
    } catch (e) {
      print('Error al obtener mascota: $e');
      return null;
    }
  }

  /// Buscar mascotas por nombre o especie
  Future<List<PetModel>> searchPets(String query) async {
    try {
      final response = await _supabase
          .from('pets')
          .select('*, shelter:shelters(nombre, telefono)')
          .eq('estado', 'disponible')
          .or('nombre.ilike.%$query%,especie.ilike.%$query%');

      return response.map<PetModel>((e) => PetModel.fromJson(e)).toList();
    } catch (e) {
      print('Error al buscar mascotas: $e');
      return [];
    }
  }
}
