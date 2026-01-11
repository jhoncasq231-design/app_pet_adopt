import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';
import '../../data/services/gemini_service.dart';

class ChatCubit extends Cubit<ChatState> {
  final GeminiService geminiService;

  ChatCubit({required this.geminiService}) : super(ChatInitial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) {
      print('⚠️ Mensaje vacío, no se envía');
      return;
    }

    print('📤 Enviando mensaje: $text');

    // Agregar mensaje del usuario
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(text: text, isUser: true));

    // Emitir estado de carga
    emit(ChatLoading(messages: updatedMessages));
    print(
      '📥 Estado emitido: ChatLoading con ${updatedMessages.length} mensajes',
    );

    try {
      // Llamar al servicio
      print('🔄 Llamando a GeminiService...');
      final response = await geminiService.sendMessage(text);

      print('✅ Respuesta recibida: $response');

      // Agregar respuesta del bot
      updatedMessages.add(ChatMessage(text: response, isUser: false));

      // Emitir estado cargado
      emit(ChatLoaded(messages: updatedMessages));
      print(
        '📥 Estado emitido: ChatLoaded con ${updatedMessages.length} mensajes',
      );
    } catch (e) {
      print('❌ Error: $e');
      emit(ChatError(errorMessage: e.toString(), messages: updatedMessages));
      print('📥 Estado emitido: ChatError - ${e.toString()}');
    }
  }
}
