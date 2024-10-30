import 'package:chat_app/app/controllers/chat_controller.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/widgets/message_tile.dart';
import 'package:chat_app/app/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Users'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildAllUsers(),
                  _buildMessages(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllUsers() {
    return Obx(() => ListView.builder(
          itemCount: controller.allUsers.length,
          itemBuilder: (context, index) {
            final user = controller.allUsers[index];
            return UserListTile(user: user);
          },
        ));
  }

  Widget _buildMessages() {
    return Obx(() {
      if (controller.chatRooms.isEmpty) {
        return Center(child: Text('No messages yet'));
      }

      return ListView.builder(
        itemCount: controller.chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = controller.chatRooms[index];
          final otherUserId = chatRoom.participants.firstWhere(
              (id) => id != controller.authController.user.value?.uid);
          final otherUser = controller.allUsers.firstWhere(
            (user) => user.uid == otherUserId,
            orElse: () => UserModel(
              uid: otherUserId,
              email: '',
              name: 'Unknown User',
              photoUrl: '',
              lastSeen: DateTime.now().toIso8601String(),
            ),
          );

          return MessageTile(
            otherUser: otherUser,
            chatRoom: chatRoom,
            currentUserId: controller.authController.user.value!.uid,
          );
        },
      );
    });
  }
}
