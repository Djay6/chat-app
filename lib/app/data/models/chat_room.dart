import 'package:chat_app/app/data/models/message_model.dart';

class ChatRoom {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageType;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount; // {userId: count}
  final Map<String, MessageModel>? messages;

  ChatRoom({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
    this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatId: json['chatId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageType: json['lastMessageType'] ?? 'text',
      lastMessageTime: DateTime.parse(
          json['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
      messages: json['messages'] != null
          ? Map<String, MessageModel>.from(json['messages']
              .map((key, value) => MapEntry(key, MessageModel.fromJson(value))))
          : null,
    );
  }
}
