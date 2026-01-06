import 'package:flutter/material.dart';
import '../../core/colors.dart';

// ✅ IMPORTA LOS CONTENEDORES (CON TABS)
import '../home/home_container_adoptant_page.dart';
import '../shelter_admin/home_container_shelter_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Quién eres?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el tipo de cuenta que deseas crear',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 145, 141, 138),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 🐾 ADOPTANTE
            _RoleCard(
              title: 'Adoptante',
              description: 'Encuentra a tu mascota ideal',
              icon: Icons.home_outlined,
              color: AppColors.primaryOrange,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeContainerAdoptantPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🏥 REFUGIO
            _RoleCard(
              title: 'Refugio',
              description: 'Gestiona mascotas y solicitudes',
              icon: Icons.local_hospital_outlined,
              color: AppColors.primaryTeal,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeContainerShelterPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

///
/// 🔹 CARD DE SELECCIÓN DE ROL
///
class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 30,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
