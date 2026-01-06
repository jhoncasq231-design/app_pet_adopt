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
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  
  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  setState(() {
    _errorMessage = null;
    _isLoading = true;
  });

  final result = await AuthService.register(
    email: _emailController.text.trim(),
    password: _passwordController.text,
    confirmPassword: _passwordConfirmController.text,
    role: _selectedRole,
    nombre: _nombreController.text.trim(),
    telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
    ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
  );

  if (!mounted) return;

  setState(() => _isLoading = false);

  if (result['success']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  } else {
    setState(() => _errorMessage = result['message']);
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _selectedRole == 'refugio' ? 'Registro de Refugio' : 'Crear Cuenta',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO Y DESCRIPCIÓN
              Text(
                _selectedRole == 'refugio' 
                    ? 'Registra tu Refugio'
                    : 'Crear Cuenta',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _selectedRole == 'refugio'
                    ? 'Gestiona y publica mascotas en adopción'
                    : 'Regístrate para encontrar tu mascota',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              // TIPO DE CUENTA (VISUAL)
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
                  color: (_selectedRole == 'adoptante'
                          ? AppColors.primaryOrange
                          : AppColors.primaryTeal)
                      .withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedRole == 'adoptante'
                          ? Icons.favorite_outline
                          : Icons.home_work_outlined,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // NOMBRE COMPLETO / NOMBRE DEL REFUGIO
              Text(
                _selectedRole == 'refugio' 
                    ? 'NOMBRE DEL REFUGIO *' 
                    : 'NOMBRE COMPLETO *',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: _selectedRole == 'refugio'
                      ? 'Ej: Refugio Patitas Felices'
                      : 'Ej: Juan Pérez',
                  prefixIcon: Icon(
                    _selectedRole == 'refugio' 
                        ? Icons.business 
                        : Icons.person_outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // EMAIL
              const Text(
                'EMAIL *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'tu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email inválido';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // TELÉFONO (OPCIONAL PARA ADOPTANTE, RECOMENDADO PARA REFUGIO)
              Text(
                _selectedRole == 'refugio' 
                    ? 'TELÉFONO *' 
                    : 'TELÉFONO (OPCIONAL)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ej: +593987654321',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (_selectedRole == 'refugio' && 
                      (value == null || value.trim().isEmpty)) {
                    return 'El teléfono es requerido para refugios';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // UBICACIÓN (OPCIONAL PARA ADOPTANTE, RECOMENDADO PARA REFUGIO)
              Text(
                _selectedRole == 'refugio' 
                    ? 'DIRECCIÓN *' 
                    : 'CIUDAD (OPCIONAL)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ubicacionController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: _selectedRole == 'refugio'
                      ? 'Ej: Av. 6 de Diciembre N34-56, Quito'
                      : 'Ej: Quito, Ecuador',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (_selectedRole == 'refugio' && 
                      (value == null || value.trim().isEmpty)) {
                    return 'La dirección es requerida para refugios';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // CONTRASEÑA
              const Text(
                'CONTRASEÑA *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // CONFIRMAR CONTRASEÑA
              const Text(
                'CONFIRMAR CONTRASEÑA *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordConfirmController,
                obscureText: _obscureConfirmPassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() => _errorMessage = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              // MENSAJE DE ERROR
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // BOTÓN REGISTRAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole == 'adoptante'
                        ? AppColors.primaryOrange
                        : AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
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
                      : Text(
                          _selectedRole == 'refugio'
                              ? 'Registrar Refugio'
                              : 'Crear Cuenta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // LINK A LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                    child: Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: _selectedRole == 'adoptante'
                            ? AppColors.primaryOrange
                            : AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}