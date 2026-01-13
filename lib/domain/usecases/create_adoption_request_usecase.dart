import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class CreateAdoptionRequestUseCase
    implements UseCase<String, CreateAdoptionRequestParams> {
  @override
  Future<Either<Failure, String>> call(
    CreateAdoptionRequestParams params,
  ) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}

class CreateAdoptionRequestParams {
  final String petId;
  final String? mensaje;

  CreateAdoptionRequestParams({required this.petId, this.mensaje});
}
