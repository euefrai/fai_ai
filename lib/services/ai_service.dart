import 'dart:convert';

import 'package:http/http.dart' as http;

/// Serviço responsável por conversar com IA remota (Gemini)
/// e preparado para futuro fallback de IA local/offline.
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Endpoint oficial da API Gemini (modelo pode ser trocado sem quebrar camadas acima).
  static const String _geminiModel = 'gemini-1.5-flash';

  /// Envia uma pergunta para Gemini.
  ///
  /// [apiKey] pode vir de variável de ambiente, arquivo seguro ou backend.
  Future<String> askGemini({
    required String prompt,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      return 'Não encontrei a chave da API Gemini. Configure para ativar respostas avançadas.';
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$apiKey',
    );

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        final text = parts != null && parts.isNotEmpty
            ? (parts.first['text'] as String? ?? '').trim()
            : '';
        if (text.isNotEmpty) {
          return text;
        }
      }
      return 'Recebi uma resposta vazia da IA.';
    }

    return 'Não consegui responder agora (erro ${response.statusCode}).';
  }

  /// Stub de expansão para IA local no futuro.
  Future<String> askOfflineModel(String prompt) async {
    return 'Modo offline ainda não implementado. Pedido recebido: "$prompt"';
  }

  void dispose() {
    _client.close();
  }
}
