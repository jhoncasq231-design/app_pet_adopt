import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../home/home_adoptant_page.dart';
import '../shelter_admin/shelter_dashboard_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Quién eres?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _RoleCard(
              title: 'Adoptante',
              description: 'Encuentra a tu mascota ideal',
              icon: Icons.home,
              color: AppColors.primaryOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeAdoptantPage()),
              ),
            ),

            const SizedBox(height: 20),

            _RoleCard(
              title: 'Refugio',
              description: 'Gestiona mascotas y solicitudes',
              icon: Icons.local_hospital,
              color: AppColors.primaryTeal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShelterDashboardPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(description),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
