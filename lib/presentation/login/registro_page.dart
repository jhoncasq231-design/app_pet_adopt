import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/auth_service.dart';
import '../routes/app_routes.dart';

class RegistroPage extends StatefulWidget {
  final String selectedRole;

  const RegistroPage({super.key, this.selectedRole = 'adoptante'});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  late String _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Por favor completa todos los campos');
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _passwordConfirmController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (result['success']) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro exitoso! Inicia sesión')),
      );
      // Volver a login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crear Cuenta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('Regístrate para encontrar tu mascota'),

            const SizedBox(height: 30),

            // EMAIL
            const Text('EMAIL'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'tu@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONTRASEÑA
            const Text('CONTRASEÑA'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONFIRMAR CONTRASEÑA
            const Text('CONFIRMAR CONTRASEÑA'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordConfirmController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••••••',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // MOSTRAR ROL SELECCIONADO
            const Text('Tipo de Cuenta'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedRole == 'adoptante'
                      ? AppColors.primaryOrange
                      : AppColors.primaryTeal,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color:
                    (_selectedRole == 'adoptante'
                            ? AppColors.primaryOrange
                            : AppColors.primaryTeal)
                        .withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedRole == 'adoptante'
                        ? Icons.home_outlined
                        : Icons.local_hospital_outlined,
                    color: _selectedRole == 'adoptante'
                        ? AppColors.primaryOrange
                        : AppColors.primaryTeal,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRole == 'adoptante' ? 'Adoptante' : 'Refugio',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _selectedRole == 'adoptante'
                            ? 'Busca tu mascota ideal'
                            : 'Gestiona tu refugio',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MENSAJE DE ERROR
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // BOTÓN REGISTRAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Registrarse', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
