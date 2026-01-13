import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class RegisterUserUseCase implements UseCase<String, RegisterUserParams> {
  @override
  Future<Either<Failure, String>> call(RegisterUserParams params) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}

class RegisterUserParams {
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final String? nombre;
  final String? telefono;

  RegisterUserParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.nombre,
    this.telefono,
  });
}
