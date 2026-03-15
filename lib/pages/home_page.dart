import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/message_model.dart';
import '../services/action_service.dart';
import '../services/ai_service.dart';
import '../services/memory_service.dart';
import '../services/monitor_service.dart';
import '../services/voice_service.dart';
import '../widgets/chat_bubble.dart';

/// Tela principal do app Fai AI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = [];

  final VoiceService _voiceService = VoiceService();
  final AiService _aiService = AiService();
  final MonitorService _monitorService = MonitorService();
  final ActionService _actionService = ActionService();
  final MemoryService _memoryService = MemoryService();

  bool _wakeWordDetected = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _requestPermissions();
    final oldMessages = await _memoryService.loadMessages();
    setState(() => _messages.addAll(oldMessages));
    await _voiceService.init();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.location,
      Permission.storage,
      Permission.sms,
    ].request();
  }

  Future<void> _startVoiceMode() async {
    await _voiceService.startListening(
      onResult: (text, finalResult) async {
        final recognized = text.trim();
        if (recognized.isEmpty) return;

        final lower = recognized.toLowerCase();

        // Wake word: "hey fai"
        if (lower.contains('hey fai') || lower.startsWith('fai')) {
          _wakeWordDetected = true;
          await _voiceService.speak('Estou ouvindo.');
          if (lower != 'hey fai' && lower != 'fai') {
            await _handleUserCommand(recognized);
          }
          return;
        }

        if (_wakeWordDetected && finalResult) {
          await _handleUserCommand(recognized);
          _wakeWordDetected = false;
        }
      },
    );
  }

  Future<void> _handleUserCommand(String input) async {
    final userMessage = MessageModel(
      text: input,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _appendMessage(userMessage);

    String response;

    // Comandos monitoráveis (bateria, localização e apps)
    if (input.toLowerCase().contains('bateria')) {
      final level = await _monitorService.batteryLevel();
      response = 'Sua bateria está em $level%.';
    } else if (input.toLowerCase().contains('onde estou')) {
      response = await _monitorService.currentLocationText();
    } else if (input.toLowerCase().contains('quais apps')) {
      final apps = await _monitorService.installedApps();
      response = 'Alguns apps instalados: ${apps.join(', ')}.';
    } else {
      final actionResult = await _actionService.handleCommand(input);
      if (actionResult != null) {
        response = actionResult;
        await _memoryService.saveAction(actionResult);
      } else {
        // Se nenhum comando local for detectado, usa IA remota.
        response = await _aiService.askGemini(
          prompt: 'Você é a Fai, assistente pessoal de IA. Responda em português: $input',
          apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
        );
      }
    }

    final faiMessage = MessageModel(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _appendMessage(faiMessage);
    await _voiceService.speak(response);
  }

  Future<void> _openInternalBrowser(String url) async {
    final fixedUrl = url.startsWith('http') ? url : 'https://$url';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Navegador interno Fai')),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(fixedUrl)),
          ),
        ),
      ),
    );
  }

  Future<void> _onSendPressed() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    if (text.toLowerCase().startsWith('fai abra navegador')) {
      final url = text.toLowerCase().replaceFirst('fai abra navegador', '').trim();
      if (url.isNotEmpty) {
        await _openInternalBrowser(url);
        return;
      }
    }

    await _handleUserCommand(text);
  }

  Future<void> _appendMessage(MessageModel message) async {
    setState(() => _messages.add(message));
    await _memoryService.saveMessage(message);
  }

  @override
  void dispose() {
    _controller.dispose();
    _voiceService.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fai AI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => ChatBubble(message: _messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite um comando para a Fai...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _onSendPressed,
                  icon: const Icon(Icons.send),
                ),
                IconButton(
                  onPressed: _startVoiceMode,
                  icon: Icon(
                    _voiceService.isListening ? Icons.mic : Icons.mic_none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
