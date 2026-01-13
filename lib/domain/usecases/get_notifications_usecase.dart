import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class GetNotificationsUseCase
    implements UseCase<List<Map<String, dynamic>>, NoParams> {
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    NoParams params,
  ) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}
