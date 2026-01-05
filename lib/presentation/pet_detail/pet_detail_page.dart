import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/models/pet_model.dart';

class PetDetailPage extends StatelessWidget {
  final PetModel pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Solicitar Adopción 🧡',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),

      body: ListView(
        children: [
          // 🐕 IMAGEN / CAROUSEL SIMULADO
          Container(
            height: 260,
            color: Colors.orange.shade100,
            child: const Center(
              child: Icon(Icons.pets, size: 120),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🐾 NOMBRE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: const Text('Disponible'),
                      backgroundColor: Colors.green.shade100,
                    ),
                  ],
                ),

                Text(
                  pet.breed,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 16),

                // 📊 INFO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoBox(title: pet.age, subtitle: 'Edad'),
                    _InfoBox(title: pet.sex, subtitle: 'Sexo'),
                    _InfoBox(title: pet.size, subtitle: 'Tamaño'),
                  ],
                ),

                const SizedBox(height: 24),

                // 🏠 REFUGIO
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.home)),
                    title: const Text('Refugio Patitas Felices'),
                    subtitle: Text('${pet.distance} de distancia'),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {},
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 📝 DESCRIPCIÓN
                const Text(
                  'Sobre Luna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Es una mascota muy cariñosa, juguetona y perfecta para familias.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================
// INFO BOX
// ======================
class _InfoBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoBox({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
