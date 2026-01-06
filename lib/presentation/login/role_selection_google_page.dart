import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/google_auth_service.dart';
import '../../presentation/routes/app_routes.dart';

class RoleSelectionGooglePage extends StatefulWidget {
  const RoleSelectionGooglePage({super.key});

  @override
  State<RoleSelectionGooglePage> createState() =>
      _RoleSelectionGooglePageState();
}

class _RoleSelectionGooglePageState extends State<RoleSelectionGooglePage> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signInWithGoogle(String rol) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await GoogleAuthService.signInWithGoogle(rol: rol);

    if (!mounted) return;

    if (result['success']) {
      if (rol == 'adoptante') {
        Navigator.pushReplacementNamed(context, AppRoutes.homeAdoptant);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.homeShelter);
      }
    } else {
      setState(() {
        _error = result['message'];
        _isLoading = false;
      });
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

            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
