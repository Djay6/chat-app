import 'dart:io';

import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:chat_app/app/data/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final userId = _authController.user.value!.uid;
    FirebaseDatabase.instance
        .ref()
        .child('users/$userId')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        currentUser.value = UserModel.fromJson(
            Map<String, dynamic>.from(event.snapshot.value as Map));
        nameController.text = currentUser.value!.name;
      }
    });
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;

      await FirebaseDatabase.instance.ref().child('users/$userId').update({
        'name': nameController.text.trim(),
      });

      isEditing.value = false;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfilePicture() async {
    try {
      isLoading.value = true;
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        final String imageUrl =
            await _firebaseService.uploadImage(File(image.path));

        final userId = _authController.user.value!.uid;
        await FirebaseDatabase.instance.ref().child('users/$userId').update({
          'photoUrl': imageUrl,
        });

        Get.snackbar('Success', 'Profile picture updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile picture');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authController.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
