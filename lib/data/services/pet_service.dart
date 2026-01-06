import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import 'storage_service.dart';

class PetService {
  final _storageService = StorageService();

  // ✅ Getter seguro
  SupabaseClient get _supabase => Supabase.instance.client;

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

  Future<PetModel?> createPet({
    required String nombre,
    required String especie,
    required String refugioId,
    List<File>? imageFiles,
    int? mainPhotoIndex,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Usuario no autenticado';

      List<String> photoUrls = [];
      String? mainPhoto;

      if (imageFiles != null && imageFiles.isNotEmpty) {
        photoUrls = await _storageService.uploadMultiplePetImages(
          imageFiles,
          userId,
        );

        if (photoUrls.isNotEmpty) {
          mainPhoto = (mainPhotoIndex != null &&
                  mainPhotoIndex < photoUrls.length)
              ? photoUrls[mainPhotoIndex]
              : photoUrls.first;
        }
      }

      final response = await _supabase.from('pets').insert({
        'nombre': nombre,
        'especie': especie,
        'refugio_id': refugioId,
        'fotos': photoUrls,
        'foto_principal': mainPhoto,
        'estado': 'disponible',
      }).select().single();

      return PetModel.fromJson(response);
    } catch (e) {
      print('Error al crear mascota: $e');
      return null;
    }
  }
}
