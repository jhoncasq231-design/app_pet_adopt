import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/pet_entity.dart';

class GetPetByIdUseCase implements UseCase<PetEntity, String> {
  @override
  Future<Either<Failure, PetEntity>> call(String petId) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}
