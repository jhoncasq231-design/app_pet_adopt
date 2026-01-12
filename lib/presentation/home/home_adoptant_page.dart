import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/models/pet_model.dart';
import '../../data/services/pet_service.dart';
import '../../data/services/favorite_service.dart';
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
      return pets.where((p) => p.especie.toLowerCase() == 'perro').toList();
    }
    if (_selectedCategory == 2) {
      return pets.where((p) => p.especie.toLowerCase() == 'gato').toList();
    }
    return pets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 BUSCADOR (visual)
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar mascota...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🐾 CATEGORÍAS
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

            // 🐶 GRID DE MASCOTAS
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
                        child: PetCard(pet: pet),
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
class PetCard extends StatefulWidget {
  final PetModel pet;
  const PetCard({super.key, required this.pet});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final fav = await _favoriteService.isFavorite(widget.pet.id);
    setState(() {
      _isFavorite = fav;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.pet.id);
    } else {
      await _favoriteService.addFavorite(widget.pet.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ IMAGEN REAL DESDE SUPABASE
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                widget.pet.imagenPrincipal,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.pets, size: 60)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ❤️ NOMBRE + FAVORITO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_loading)
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${widget.pet.breed} • ${widget.pet.age}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryOrange : Colors.grey.shade300,
          ),
        ),
        child: Text(
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