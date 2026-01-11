import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/models/pet_model.dart';
import '../../data/services/pet_service.dart';
import '../pet_detail/pet_detail_page.dart';

class HomeAdoptantPage extends StatefulWidget {
  const HomeAdoptantPage({super.key});

  @override
  State<HomeAdoptantPage> createState() => _HomeAdoptantPageState();
}

class _HomeAdoptantPageState extends State<HomeAdoptantPage> {
  int _selectedCategory = 0;
  Future<List<PetModel>>? _petsFuture;

  @override
  void initState() {
    super.initState();
    _petsFuture = PetService().getAllPets();
  }

  List<PetModel> _filterPets(List<PetModel> pets) {
    if (_selectedCategory == 1) {
      return pets.where((p) => p.especie == 'Perro').toList();
    }
    if (_selectedCategory == 2) {
      return pets.where((p) => p.especie == 'Gato').toList();
    }
    return pets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola 👋', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              'Encuentra tu mascota',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 SEARCH (visual, aún no filtra)
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar mascota...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🐶 CATEGORIES
            Row(
              children: [
                _CategoryChip(
                  label: 'Todos',
                  selected: _selectedCategory == 0,
                  onTap: () => setState(() => _selectedCategory = 0),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Perros',
                  selected: _selectedCategory == 1,
                  onTap: () => setState(() => _selectedCategory = 1),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Gatos',
                  selected: _selectedCategory == 2,
                  onTap: () => setState(() => _selectedCategory = 2),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🐾 PET GRID (SUPABASE)
            Expanded(
              child: FutureBuilder<List<PetModel>>(
                future: _petsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final pets = _filterPets(snapshot.data ?? []);

                  if (pets.isEmpty) {
                    return const Center(
                      child: Text('No hay mascotas disponibles'),
                    );
                  }

                  return GridView.builder(
                    itemCount: pets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (_, index) {
                      final pet = pets[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetDetailPage(pet: pet),
                            ),
                          );
                        },
                        child: _PetCard(
                          name: pet.name,
                          breed: '${pet.breed} • ${pet.age}',
                          distance: pet.distance,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= COMPONENTS =================

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        backgroundColor: selected ? AppColors.primaryOrange : Colors.white,
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final String name;
  final String breed;
  final String distance;

  const _PetCard({
    required this.name,
    required this.breed,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Center(child: Icon(Icons.pets, size: 60)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.favorite_border, color: AppColors.primaryOrange),
                  ],
                ),
                const SizedBox(height: 4),
                Text(breed),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(distance),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
