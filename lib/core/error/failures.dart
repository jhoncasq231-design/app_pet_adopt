import 'package:equatable/equatable.dart';

/// Clase base para todas las fallas/errores en la aplicación
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

/// Falla del servidor
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Falla de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message: message);
}

/// Falla de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure({required String message}) : super(message: message);
}

/// Falla genérica
class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message: message);
}
