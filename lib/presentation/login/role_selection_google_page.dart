import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/google_auth_service.dart';
import '../routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleSelectionGooglePage extends StatefulWidget {
  const RoleSelectionGooglePage({super.key});

  @override
  State<RoleSelectionGooglePage> createState() =>
      _RoleSelectionGooglePageState();
}

class _RoleSelectionGooglePageState extends State<RoleSelectionGooglePage> {
  bool _isLoading = false;

  // Solo inicia sesión con Google, sin rol
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await GoogleAuthService.signInWithGoogle();
      // La navegación se maneja en main.dart -> _InitialRoutePage
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Selección de rol después de iniciar sesión
  Future<void> _selectRole(String rol) async {
    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no autenticado')),
      );
      return;
    }

    try {
      // Upsert: crea o actualiza el rol si falta
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'rol': rol,
        'nombre': user.email?.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
      });

      // Redirige al dashboard según rol
      Navigator.pushReplacementNamed(
        context,
        rol == 'adoptante' ? AppRoutes.homeAdoptant : AppRoutes.homeShelter,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creando perfil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
              onTap: _isLoading ? null : () => _selectRole('adoptante'),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              title: 'Refugio',
              description: 'Gestionar mascotas y adopciones',
              icon: Icons.home_work_outlined,
              color: AppColors.primaryTeal,
              onTap: _isLoading ? null : () => _selectRole('refugio'),
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
