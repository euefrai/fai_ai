import 'package:hive/hive.dart';

import '../models/message_model.dart';

/// Serviço para persistência de memória (histórico de conversas e ações).
class MemoryService {
  static const String _boxName = 'fai_memory';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }

  Future<void> saveMessage(MessageModel message) async {
    final box = await _openBox();
    await box.add(message.toJson());
  }

  Future<void> saveAction(String actionDescription) async {
    final box = await _openBox();
    await box.add({
      'text': '[AÇÃO] $actionDescription',
      'isUser': false,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<MessageModel>> loadMessages() async {
    final box = await _openBox();
    return box.values
        .map((item) => MessageModel.fromJson(Map<dynamic, dynamic>.from(item)))
        .toList();
  }
}
