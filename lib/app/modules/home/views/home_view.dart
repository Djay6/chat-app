import 'package:chat_app/app/controllers/home_controller.dart';
import 'package:chat_app/app/modules/chat/views/chat_list_view.dart';
import 'package:chat_app/app/modules/profile/views/profile_view.dart';
import 'package:chat_app/app/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          ChatListView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).primaryColor,
        child: TabBar(
          controller: controller.tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(.5),
          unselectedLabelStyle: TextStyle(color: Colors.white.withOpacity(.5)),
          tabs: const [
            Tab(
              icon: Icon(
                Icons.chat,
              ),
              text: 'Chats',
            ),
            Tab(
              icon: Icon(
                Icons.person,
              ),
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
