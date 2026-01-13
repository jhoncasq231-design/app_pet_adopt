import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

class SendChatMessageUseCase implements UseCase<String, SendChatMessageParams> {
  @override
  Future<Either<Failure, String>> call(SendChatMessageParams params) async {
    // Implementación pendiente
    throw UnimplementedError();
  }
}

class SendChatMessageParams {
  final String message;

  SendChatMessageParams({required this.message});
}
