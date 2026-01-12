import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

   // 🔥 Mascotas del refugio que tienen favoritos
  Future<List<PetModel>> getShelterFavoritePets() async {
    final shelterId = _supabase.auth.currentUser?.id;
    if (shelterId == null) return [];

    final response = await _supabase
        .from('pets')
        .select('*, favorites!inner(pet_id)')
        .eq('refugio_id', shelterId);

    return response.map<PetModel>((e) => PetModel.fromJson(e)).toList();
  }


  /// Verifica si una mascota ya está en favoritos
  Future<bool> isFavorite(String petId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', user.id)
        .eq('pet_id', petId)
        .maybeSingle();

    return response != null;
  }

  /// Agregar a favoritos
  Future<void> addFavorite(String petId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _supabase.from('favorites').insert({
      'user_id': user.id,
      'pet_id': petId,
    });
  }

  /// Quitar de favoritos
  Future<void> removeFavorite(String petId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('pet_id', petId);
  }

  /// Obtener IDs de mascotas favoritas
  Future<List<String>> getFavoritePetIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('favorites')
        .select('pet_id')
        .eq('user_id', user.id);

    return response.map<String>((e) => e['pet_id'] as String).toList();
  }
}
