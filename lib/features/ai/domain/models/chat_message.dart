enum MessageType {
  user,
  ai,
}

class ChatMessage {
  final String? id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id ?? map['id'],
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.ai,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
