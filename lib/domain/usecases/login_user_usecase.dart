import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class LoginUserUseCase implements UseCase<String, LoginUserParams> {
  @override
  Future<Either<Failure, String>> call(LoginUserParams params) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}

class LoginUserParams {
  final String email;
  final String password;

  LoginUserParams({required this.email, required this.password});
}
