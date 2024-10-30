import 'package:chat_app/app/data/models/message_model.dart';

class ChatRoom {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageType;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
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
    Map<String, MessageModel>? messagesMap;
    if (json['messages'] != null) {
      try {
        final messagesData = json['messages'] as Map<Object?, Object?>;
        messagesMap = messagesData.map((key, value) => MapEntry(key.toString(),
            MessageModel.fromJson(Map<String, dynamic>.from(value as Map))));
      } catch (e) {
        print('Error parsing messages: $e');
        messagesMap = null;
      }
    }

    return ChatRoom(
      chatId: json['chatId']?.toString() ?? '',
      participants:
          (json['participants'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageType: json['lastMessageType']?.toString() ?? 'text',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'].toString())
          : DateTime.now(),
      lastMessageSenderId: json['lastMessageSenderId']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as Map<Object?, Object?>?)?.map(
              (key, value) =>
                  MapEntry(key.toString(), int.parse(value.toString()))) ??
          {},
      messages: messagesMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      if (messages != null)
        'messages':
            messages!.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
