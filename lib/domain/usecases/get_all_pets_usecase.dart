import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/pet_entity.dart';

class GetAllPetsUseCase implements UseCase<List<PetEntity>, NoParams> {
  @override
  Future<Either<Failure, List<PetEntity>>> call(NoParams params) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}
