import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/models/pet_model.dart';
import '../../data/services/pet_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/adoption_request_service.dart';
import 'new_pet_form_page.dart';
import '../pet_detail/pet_detail_page.dart';

class ShelterDashboardPage extends StatefulWidget {
  const ShelterDashboardPage({super.key});

  @override
  State<ShelterDashboardPage> createState() => _ShelterDashboardPageState();
}

class _ShelterDashboardPageState extends State<ShelterDashboardPage> {
  final _petService = PetService();
  final _adoptionService = AdoptionRequestService();
  List<PetModel> shelterPets = [];
  List<Map<String, dynamic>> recentRequests = [];
  String shelterName = 'Mi Refugio';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShelterData();
  }

  Future<void> _loadShelterData() async {
    try {
      final shelterId = await AuthService.getShelterIdForCurrentUser();
      if (shelterId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el ID del refugio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final profile = await AuthService.getUserProfile();
      if (profile != null) {
        setState(() {
          shelterName = profile['nombre'] ?? 'Mi Refugio';
        });
      }

      final pets = await _petService.getPetsByRefugioId(shelterId);
      final requests = await _adoptionService.getShelterAdoptionRequests();
      setState(() {
        shelterPets = pets;
        recentRequests = requests.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar datos del refugio: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    _loadShelterData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        color: AppColors.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryTeal,
                      AppColors.primaryTeal.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shelterName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Panel de administración',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: shelterPets.length.toString(),
                            label: 'Mascotas',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: recentRequests
                                .where((r) => r['estado'] == 'pendiente')
                                .length
                                .toString(),
                            label: 'Pendientes',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            value: shelterPets
                                .where((p) => p.estado == 'adoptado')
                                .length
                                .toString(),
                            label: 'Adoptadas',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SOLICITUDES RECIENTES
              if (recentRequests.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Solicitudes Recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navegar a todas las solicitudes
                            },
                            child: const Text('Ver todas'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: recentRequests.map((request) {
                          final petName =
                              request['pets']?['nombre'] ??
                              'Mascota desconocida';
                          final userName =
                              request['profiles']?['nombre'] ??
                              'Usuario desconocido';
                          final status =
                              (request['estado'] as String? ?? 'pendiente')
                                  .toLowerCase();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Solicitud para $petName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'De: $userName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (status == 'pendiente') ...[
                                  IconButton(
                                    icon: const Icon(Icons.check, size: 20),
                                    onPressed: () {
                                      // Aprobar solicitud
                                    },
                                    color: Colors.green,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () {
                                      // Rechazar solicitud
                                    },
                                    color: Colors.red,
                                  ),
                                ] else
                                  Chip(
                                    label: Text(
                                      status[0].toUpperCase() +
                                          status.substring(1),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: status == 'aprobada'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Mascotas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewPetFormPage(),
                          ),
                        );
                        if (result == true) {
                          _refreshData();
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (shelterPets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'No hay mascotas registradas aún',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: shelterPets
                        .map(
                          (pet) => _PetItem(
                            pet: pet,
                            onDelete: () async {
                              await _petService.deletePet(pet.id);
                              _refreshData();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetItem extends StatelessWidget {
  final PetModel pet;
  final Future<void> Function()? onDelete;

  const _PetItem({required this.pet, this.onDelete});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar mascota'),
          content: Text('¿Estás seguro de que deseas eliminar a ${pet.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (onDelete != null) {
                  await onDelete!();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mascota eliminada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: pet.fotoPrincipal != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pet.fotoPrincipal!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.pets, color: AppColors.primaryTeal),
                    ),
                  )
                : Icon(Icons.pets, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${pet.especie}${pet.raza != null ? ' - ${pet.raza}' : ''}',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryTeal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Estado: ${pet.estado}',
                  style: TextStyle(
                    fontSize: 10,
                    color: pet.estado == 'disponible'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, size: 20),
            color: Colors.grey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PetDetailPage(pet: pet)),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NewPetFormPage(pet: pet)),
              );
              if (result == true) {
                // Refrescar la lista después de editar
                // Notificar al padre (ShelterDashboardPage) para refrescar
                final shelterState = context
                    .findAncestorStateOfType<_ShelterDashboardPageState>();
                shelterState?._refreshData();
              }
            },
            color: Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _showDeleteDialog(context),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
