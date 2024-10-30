import 'package:chat_app/app/controllers/chat_controller.dart';
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: controller.searchUsers,
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
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
    return Obx(() => ListView.builder(
          itemCount: controller.chatUsers.length,
          itemBuilder: (context, index) {
            final user = controller.chatUsers[index];
            return UserListTile(
              user: user,
              showLastMessage: true,
            );
          },
        ));
  }
}
