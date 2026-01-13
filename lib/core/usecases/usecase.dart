import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Clase abstracta base para todos los casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Parámetros vacíos para casos de uso sin parámetros
class NoParams {
  @override
  bool operator ==(Object other) => identical(this, other) || other is NoParams;

  @override
  int get hashCode => runtimeType.hashCode;
}
