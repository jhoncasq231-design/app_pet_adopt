import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // API Key tomada desde .env
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // Modelo válido de chat
  final String model = 'chat-bison-001';

  Future<String> sendMessage(String prompt) async {
    final url = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta2/models/$model:generateText',
    );

    final body = jsonEncode({
      'prompt': {'text': prompt},
      'temperature': 0.7,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      );

      // Debug: ver respuesta completa
      print('Gemini Response Status: ${response.statusCode}');
      print('Gemini Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Toma el primer candidato de respuesta
        return data['candidates']?[0]?['output'] ?? '⚠️ Sin respuesta del modelo';
      } else if (response.statusCode == 403) {
        throw Exception(
            'Error Gemini (403): API Key no autorizada o no registrada.');
      } else if (response.statusCode == 404) {
        throw Exception(
            'Error Gemini (404): Modelo no encontrado. Revisa el nombre del modelo.');
      } else {
        throw Exception(
            'Error Gemini (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error en GeminiService: $e');
      rethrow;
    }
  }
}
