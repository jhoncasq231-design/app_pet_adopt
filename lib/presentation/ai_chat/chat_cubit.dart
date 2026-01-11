import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';
import '../../data/models/message.dart';
import '../../data/services/gemini_service.dart';

class ChatCubit extends Cubit<ChatState> {
  final GeminiService geminiService;

  ChatCubit({required this.geminiService}) : super(const ChatInitial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Copiar mensajes actuales y agregar mensaje del usuario
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(ChatMessage(text: text, isUser: true));

    emit(ChatLoading(messages: updatedMessages));

    try {
      // ✨ MEJORA: Enviar todo el historial para mantener contexto
      final response = await geminiService.sendMessage(
        text,
        conversationHistory: state.messages, // Enviar historial previo
      );

      updatedMessages.add(ChatMessage(text: response, isUser: false));
      emit(ChatLoaded(messages: updatedMessages));
    } catch (e) {
      emit(
        ChatError(
          errorMessage: 'Error al comunicarse con Gemini: $e',
          messages: updatedMessages,
        ),
      );
    }
  }
}
