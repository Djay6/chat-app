import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/controllers/profile_controller.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Obx(
            () => controller.isEditing.value
                ? IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: controller.updateProfile,
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => controller.isEditing.value = true,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(user),
              const SizedBox(height: 24),
              _buildProfileInfo(user),
              const SizedBox(height: 32),
              _buildSignOutButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage(UserModel user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          child: user.photoUrl.isEmpty
              ? Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(fontSize: 40),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: controller.updateProfilePicture,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(UserModel user) {
    return Column(
      children: [
        Obx(
          () => controller.isEditing.value
              ? TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                )
              : ListTile(
                  title: const Text('Name'),
                  subtitle: Text(user.name),
                ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Email'),
          subtitle: Text(user.email),
        ),
        ListTile(
          title: const Text('Last Seen'),
          subtitle: Text(
              TimeFormatter.formatMessageTime(DateTime.parse(user.lastSeen))),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      onPressed: controller.signOut,
    );
  }
}
