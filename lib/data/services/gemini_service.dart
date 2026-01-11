import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class GeminiService {
  static const String _supabaseFunctionUrl =
      'https://qygsuhhtijuzobuwfaxt.supabase.co/functions/v1/geminiChat';

  Future<String> sendMessage(
    String message, {
    List<ChatMessage> conversationHistory = const [],
  }) async {
    final url = Uri.parse(_supabaseFunctionUrl);

    // Construir el contexto del historial para incluirlo en el mensaje
    final contextMessage = _buildContextualMessage(
      message,
      conversationHistory,
    );

    final body = jsonEncode({'message': contextMessage});

    print('═══════════════════════════════════════════');
    print('🔵 GEMINI SERVICE - CHAT CON CONTEXTO');
    print('═══════════════════════════════════════════');
    print('💬 Mensaje: $message');
    print('📋 Historial: ${conversationHistory.length} mensajes previos');
    print('🔄 Enviando request...\n');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('🟢 RESPUESTA RECIBIDA');
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('Respuesta inválida de Gemini: ${response.body}');
        }

        final candidate = data['candidates'][0];
        final content = candidate['content'];

        String? text;
        if (content['parts'] != null && content['parts'].isNotEmpty) {
          text = content['parts'][0]['text'];
        } else if (content['text'] != null) {
          text = content['text'];
        }

        if (text == null || text.isEmpty) {
          throw Exception('No se encontró texto en la respuesta');
        }

        print('✅ Respuesta recibida\n');
        return text;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e\n');
      throw Exception('Error comunicando con Gemini: $e');
    }
  }

  /// Construye un mensaje contextual que incluye el historial
  /// Mantiene el contexto conversacional de forma compatible con Supabase
  String _buildContextualMessage(String newMessage, List<ChatMessage> history) {
    if (history.isEmpty) {
      return newMessage;
    }

    // Construir contexto del historial
    final StringBuffer context = StringBuffer();
    context.writeln(
      'Eres un asistente veterinario experto en cuidado y salud de mascotas. '
      'Responde con precisión y empatía sobre salud, cuidados y comportamiento de perros y gatos.\n',
    );

    // Agregar historial previo
    if (history.isNotEmpty) {
      context.writeln('Historial de conversación:');
      for (final msg in history) {
        final role = msg.isUser ? 'Usuario' : 'Asistente';
        context.writeln('$role: ${msg.text}');
      }
      context.writeln('');
    }

    // Agregar mensaje actual
    context.writeln('Usuario: $newMessage');
    context.writeln('Asistente:');

    return context.toString();
  }
}
