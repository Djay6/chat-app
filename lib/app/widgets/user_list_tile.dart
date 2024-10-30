import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/controllers/chat_controller.dart';
import 'package:chat_app/app/data/models/message_model.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:chat_app/app/utils/time_formatter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final bool showLastMessage;

  const UserListTile({
    Key? key,
    required this.user,
    this.showLastMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
        child: user.photoUrl.isEmpty ? Text(user.name[0].toUpperCase()) : null,
      ),
      title: Text(user.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          if (showLastMessage)
            FutureBuilder<String?>(
              future: _getLastMessage(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return const SizedBox();
              },
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.isOnline ? Colors.green : Colors.grey,
            ),
          ),
          if (!user.isOnline)
            Text(
              TimeFormatter.formatMessageTime(DateTime.parse(user.lastSeen)),
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      onTap: () => _openChat(user),
    );
  }

  void _openChat(UserModel user) {
    final chatController = Get.find<ChatController>();
    final chatId = chatController.getChatId(user.uid);
    Get.toNamed(
      Routes.CHAT,
      arguments: {
        'userId': user.uid,
        'chatId': chatId,
        'userName': user.name,
      },
    );
  }

  Future<String?> _getLastMessage(String userId) async {
    final chatController = Get.find<ChatController>();
    final chatId = chatController.getChatId(userId);
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/messages')
        .limitToLast(1)
        .get();

    if (snapshot.value != null) {
      final message = MessageModel.fromJson(
          Map<String, dynamic>.from((snapshot.value as Map).values.first));
      return message.content;
    }
    return null;
  }
}
