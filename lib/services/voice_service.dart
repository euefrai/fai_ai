import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Serviço de voz: reconhecimento contínuo + síntese de fala.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;

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

  Future<void> startListening({
    required Function(String text, bool finalResult) onResult,
  }) async {
    await init();

    if (!_speech.isListening) {
      await _speech.listen(
        localeId: 'pt_BR',
        listenMode: ListenMode.confirmation,
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
      );
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;

  void dispose() {
    _speech.cancel();
    _tts.stop();
  }
}
