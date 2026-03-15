/// Modelo simples para armazenar mensagens no chat e memória.
class MessageModel {
  MessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageModel.fromJson(Map<dynamic, dynamic> json) => MessageModel(
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
}
