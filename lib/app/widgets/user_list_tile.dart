import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/controllers/chat_controller.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final bool showLastMessage;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const UserListTile({
    Key? key,
    required this.user,
    this.showLastMessage = false,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
        child: user.photoUrl.isEmpty ? Text(user.name[0].toUpperCase()) : null,
      ),
      title: Text(user.name),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLastMessage && lastMessageTime != null)
            Text(
              TimeFormatter.formatMessageTime(lastMessageTime!),
              style: const TextStyle(fontSize: 12),
            ),
          if (showLastMessage && unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          if (!showLastMessage)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: user.isOnline ? Colors.green : Colors.grey,
              ),
            ),
        ],
      ),
      onTap: () => Get.find<ChatController>().startNewChat(user),
    );
  }
}
