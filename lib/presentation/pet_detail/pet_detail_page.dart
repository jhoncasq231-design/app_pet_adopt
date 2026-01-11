import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/models/pet_model.dart';
import '../../data/services/adoption_request_service.dart';

class PetDetailPage extends StatefulWidget {
  final PetModel pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final _adoptionService = AdoptionRequestService();
  bool _isLoading = false;

  Future<void> _requestAdoption() async {
    setState(() => _isLoading = true);

    try {
      final success = await _adoptionService.createAdoptionRequest(
        mascotaId: widget.pet.id,
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Solicitud enviada correctamente. El refugio la revisará pronto.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Esperar un poco y volver atrás
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al enviar la solicitud. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: (widget.pet.estaDisponible && !_isLoading)
              ? _requestAdoption
              : null,
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Solicitar Adopción 🧡',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),

      body: ListView(
        children: [
          // ======================
          // IMAGEN PRINCIPAL
          // ======================
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Image.network(
              widget.pet.fotoPrincipal ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Icon(Icons.pets, size: 120, color: Colors.grey),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================
                // NOMBRE + ESTADO
                // ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.pet.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        widget.pet.estado.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: widget.pet.estaDisponible
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ======================
                // RAZA / ESPECIE
                // ======================
                Text(
                  '${widget.pet.especie} • ${widget.pet.breed}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // ======================
                // INFO BOXES
                // ======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoBox(title: widget.pet.age, subtitle: 'Edad'),
                    _InfoBox(title: widget.pet.sex, subtitle: 'Sexo'),
                    _InfoBox(title: widget.pet.size, subtitle: 'Tamaño'),
                  ],
                ),

                const SizedBox(height: 24),

                // ======================
                // SALUD
                // ======================
                const Text(
                  'Estado de salud',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pet.saludResumen,
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 24),

                // ======================
                // REFUGIO
                // ======================
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryTeal,
                      child: Icon(Icons.home, color: Colors.white),
                    ),
                    title: Text(
                      widget.pet.refugioNombre ?? 'Refugio',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      widget.pet.refugioTelefono != null
                          ? '📞 ${widget.pet.refugioTelefono}'
                          : 'Contacto no disponible',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ======================
                // DESCRIPCIÓN
                // ======================
                const Text(
                  'Sobre la mascota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pet.descripcion ?? 'Sin descripción disponible.',
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 24),

                // ======================
                // GALERÍA (SI HAY MÁS FOTOS)
                // ======================
                if (widget.pet.fotos.length > 1) ...[
                  const Text(
                    'Más fotos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.pet.fotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.pet.fotos[index],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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

  const _InfoBox({required this.title, required this.subtitle});

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
            title.isNotEmpty ? title : 'N/D',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
