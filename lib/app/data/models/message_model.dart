class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    String? messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.imageUrl,
    DateTime? timestamp,
    this.isRead = false,
  })  : this.messageId =
            messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        this.timestamp = timestamp ?? DateTime.now();

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
