import 'dart:convert';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.content,
    required super.timestamp,
    super.actionChips,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return ChatMessageModel(
      id: map['id'] as String,
      sender: map['sender'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as String,
      actionChips: parseList(map['action_chips']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'timestamp': timestamp,
      'action_chips': jsonEncode(actionChips),
    };
  }
}
