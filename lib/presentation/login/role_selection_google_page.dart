import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/google_auth_service.dart';

class RoleSelectionGooglePage extends StatefulWidget {
  const RoleSelectionGooglePage({super.key});

  @override
  State<RoleSelectionGooglePage> createState() =>
      _RoleSelectionGooglePageState();
}

class _RoleSelectionGooglePageState extends State<RoleSelectionGooglePage> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle(String rol) async {
    setState(() => _isLoading = true);

    try {
      // Inicia el flujo OAuth Web de Supabase
      await GoogleAuthService.signInWithGoogle(rol: rol);
      // La redirección y navegación se maneja en onAuthStateChange del main.dart
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu rol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Cómo deseas usar la app?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _RoleCard(
              title: 'Adoptante',
              description: 'Buscar y adoptar mascotas',
              icon: Icons.favorite_outline,
              color: AppColors.primaryOrange,
              onTap: _isLoading ? null : () => _signInWithGoogle('adoptante'),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              title: 'Refugio',
              description: 'Gestionar mascotas y adopciones',
              icon: Icons.home_work_outlined,
              color: AppColors.primaryTeal,
              onTap: _isLoading ? null : () => _signInWithGoogle('refugio'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 30),
              const Center(child: CircularProgressIndicator()),
            ],
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
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
