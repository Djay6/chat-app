import 'dart:io';

import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/data/models/message_model.dart';
import 'package:chat_app/app/data/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image_picker/image_picker.dart';

class MessageController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;

  late String chatId;
  late String receiverId;

  @override
  void onInit() {
    super.onInit();
    receiverId = Get.arguments['userId'];
    chatId = Get.arguments['chatId'];
    _loadMessages();
  }

  void _loadMessages() {
    _firebaseService.getMessages(chatId).listen((messagesList) {
      messages.value = messagesList;
      _markMessagesAsRead();
    });
  }

  Future<void> sendMessage({String? imageUrl}) async {
    if (messageController.text.trim().isEmpty && imageUrl == null) return;

    final message = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _authController.user.value!.uid,
      receiverId: receiverId,
      content: messageController.text.trim(),
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    await FirebaseDatabase.instance
        .ref()
        .child('chats/$chatId/messages/${message.messageId}')
        .set(message.toJson());

    // Update user chats
    await _updateUserChats();

    messageController.clear();
    await _sendPushNotification(message);
  }

  Future<void> _updateUserChats() async {
    final currentUserId = _authController.user.value!.uid;
    await FirebaseDatabase.instance
        .ref()
        .child('userChats/$currentUserId/$receiverId')
        .set(true);
    await FirebaseDatabase.instance
        .ref()
        .child('userChats/$receiverId/$currentUserId')
        .set(true);
  }

  Future<void> sendImage() async {
    try {
      isLoading.value = true;
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final imageUrl = await _firebaseService.uploadImage(File(image.path));
        await sendMessage(imageUrl: imageUrl);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = _authController.user.value!.uid;
    final unreadMessages = messages
        .where(
            (message) => message.receiverId == currentUserId && !message.isRead)
        .toList();

    for (var message in unreadMessages) {
      await FirebaseDatabase.instance
          .ref()
          .child('chats/$chatId/messages/${message.messageId}')
          .update({'isRead': true});
    }
  }

  Future<void> _sendPushNotification(MessageModel message) async {
    final receiverSnapshot =
        await FirebaseDatabase.instance.ref().child('users/$receiverId').get();

    if (receiverSnapshot.value != null) {
      final receiverData =
          Map<String, dynamic>.from(receiverSnapshot.value as Map);
      final fcmToken = receiverData['fcmToken'];

      if (fcmToken != null) {
        // Implement your push notification logic here
      }
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
