/// Excepciones personalizadas para la aplicación
abstract class AppException implements Exception {
  final String message;
  const AppException({required this.message});

  @override
  String toString() => message;
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  const AuthException({required String message}) : super(message: message);
}

/// Excepción para errores de servidor/API
class ServerException extends AppException {
  const ServerException({required String message}) : super(message: message);
}

/// Excepción para errores de base de datos
class DatabaseException extends AppException {
  const DatabaseException({required String message}) : super(message: message);
}

/// Excepción para errores de conexión
class ConnectionException extends AppException {
  const ConnectionException({required String message})
    : super(message: message);
}

/// Excepción para errores genéricos
class CacheException extends AppException {
  const CacheException({required String message}) : super(message: message);
}
