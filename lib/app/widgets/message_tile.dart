import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/data/models/chat_room.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:chat_app/app/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageTile extends StatelessWidget {
  final UserModel otherUser;
  final ChatRoom chatRoom;
  final String currentUserId;

  const MessageTile({
    Key? key,
    required this.otherUser,
    required this.chatRoom,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: otherUser.photoUrl.isNotEmpty
            ? CachedNetworkImageProvider(otherUser.photoUrl)
            : null,
        child: otherUser.photoUrl.isEmpty
            ? Text(otherUser.name[0].toUpperCase())
            : null,
      ),
      title: Text(otherUser.name),
      subtitle: Text(
        chatRoom.lastMessageType == 'image' ? '📷 Image' : chatRoom.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            TimeFormatter.formatMessageTime(chatRoom.lastMessageTime),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if ((chatRoom.unreadCount[currentUserId] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                (chatRoom.unreadCount[currentUserId] ?? 0).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Get.toNamed(
          Routes.CHAT,
          arguments: {
            'userId': otherUser.uid,
            'chatId': chatRoom.chatId,
            'userName': otherUser.name,
          },
        );
      },
    );
  }
}
