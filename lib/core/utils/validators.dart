/// Validadores para formularios y datos
class AppValidators {
  /// Valida que un email sea válido
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email no puede estar vacío';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida que la contraseña cumpla requisitos mínimos
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida que dos campos sean iguales (ej: contraseña y confirmar)
  static String? validateMatch(String? value, String? otherValue) {
    if (value != otherValue) {
      return 'Los campos no coinciden';
    }
    return null;
  }

  /// Valida que un campo no esté vacío
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName no puede estar vacío';
    }
    return null;
  }

  /// Valida nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Valida teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono no puede estar vacío';
    }
    if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }
    return null;
  }
}
