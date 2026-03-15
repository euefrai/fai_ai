import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Serviço de voz: reconhecimento contínuo + síntese de fala.
///
/// Ele mantém uma estratégia de "escuta sempre ativa" no nível do app:
/// quando a sessão de escuta termina, ele rearma automaticamente.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;
  bool _alwaysOnMode = false;
  Timer? _rearmTimer;

  Future<bool> init() async {
    if (_initialized) return true;

    final available = await _speech.initialize();
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _initialized = available;
    return available;
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Inicia uma sessão de escuta (single session) e entrega resultados.
  Future<void> startListening({
    required Function(String text, bool finalResult) onResult,
  }) async {
    await init();

    if (!_speech.isListening) {
      await _speech.listen(
        localeId: 'pt_BR',
        listenMode: ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        listenMode: ListenMode.confirmation,
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
      );
    }
  }

  /// Modo "sempre ativo": rearma escuta automaticamente ao terminar.
  Future<void> startAlwaysListening({
    required Function(String text, bool finalResult) onResult,
  }) async {
    _alwaysOnMode = true;
    await _ensureListeningLoop(onResult);
  }

  Future<void> _ensureListeningLoop(
    Function(String text, bool finalResult) onResult,
  ) async {
    if (!_alwaysOnMode) return;

    await startListening(onResult: onResult);

    _rearmTimer?.cancel();
    _rearmTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_alwaysOnMode) {
        timer.cancel();
        return;
      }

      if (!_speech.isListening) {
        await startListening(onResult: onResult);
      }
    });
  }

  Future<void> stopListening() async {
    _alwaysOnMode = false;
    _rearmTimer?.cancel();
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
  bool get alwaysOnMode => _alwaysOnMode;

  void dispose() {
    _alwaysOnMode = false;
    _rearmTimer?.cancel();

  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}
