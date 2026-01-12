import 'package:flutter/material.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/services/favorite_service.dart';
import '../../../core/colors.dart';

class ShelterFavoritesPage extends StatelessWidget {
  const ShelterFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas Favoritas ❤️'),
        backgroundColor: const Color.fromARGB(255, 70, 254, 165),
      ),
      body: FutureBuilder<List<PetModel>>(
        future: FavoriteService().getShelterFavoritePets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay mascotas marcadas como favoritas',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (_, index) {
              final pet = pets[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      pet.imagenPrincipal,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, size: 40),
                    ),
                  ),
                  title: Text(pet.name),
                  subtitle: Text('${pet.especie} • ${pet.breed}'),
                  trailing: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
