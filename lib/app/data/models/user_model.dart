class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final String lastSeen;
  final bool isOnline;
  final List<String> chatIds;
  final DateTime updatedAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.lastSeen,
    this.isOnline = false,
    this.chatIds = const [],
    DateTime? updatedAt,
    this.fcmToken,
  }) : this.updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var chatIdsData = json['chatIds'];
    List<String> chatIdsList = [];

    if (chatIdsData != null) {
      if (chatIdsData is List) {
        chatIdsList = List<String>.from(chatIdsData);
      } else if (chatIdsData is Map) {
        chatIdsList = chatIdsData.keys.toList().cast<String>();
      }
    }

    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      lastSeen: json['lastSeen'] ?? '',
      isOnline: json['isOnline'] ?? false,
      chatIds: chatIdsList,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'chatIds': chatIds,
      'updatedAt': updatedAt.toIso8601String(),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}
