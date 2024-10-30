import 'dart:io';
import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/data/models/chat_room.dart';
import 'package:chat_app/app/data/models/message_model.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_service.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController authController = Get.find<AuthController>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;

  String? currentChatId;
  String? currentReceiverId;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadChats();
  }

  void _loadUsers() {
    _firebaseService.getAllUsers().listen((users) {
      allUsers.value = users
          .where((user) => user.uid != authController.user.value?.uid)
          .toList();
    });
  }

  void _loadChats() {
    final currentUser = authController.user.value;
    if (currentUser != null) {
      _firebaseService.getUserChats(currentUser.uid).listen(
        (rooms) {
          chatRooms.value = rooms;
        },
        onError: (error) {
          print('Error loading chats: $error');
        },
      );
    }
  }

  Future<void> startNewChat(UserModel otherUser) async {
    try {
      final currentUser = authController.user.value!;
      final chatId = getChatId(otherUser.uid);

      // Check if chat already exists
      if (chatRooms.any((room) => room.chatId == chatId)) {
        _openExistingChat(chatId, otherUser);
        return;
      }

      // Create new chat room
      final newChatRoom = ChatRoom(
        chatId: chatId,
        participants: [currentUser.uid, otherUser.uid],
        lastMessage: '',
        lastMessageType: 'text',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        unreadCount: {
          currentUser.uid: 0,
          otherUser.uid: 0,
        },
      );

      await _firebaseService.createOrUpdateChatRoom(newChatRoom);
      _openExistingChat(chatId, otherUser);
    } catch (e) {
      print('Error starting chat: $e');
      Get.snackbar('Error', 'Failed to start chat');
    }
  }

  void _openExistingChat(String chatId, UserModel otherUser) {
    Get.toNamed(
      Routes.CHAT,
      arguments: {
        'userId': otherUser.uid,
        'chatId': chatId,
        'userName': otherUser.name,
      },
    );
  }

  void initChat(String receiverId, String chatId) {
    currentReceiverId = receiverId;
    currentChatId = chatId;
    _loadMessages();
  }

  void _loadMessages() {
    if (currentChatId != null) {
      _firebaseService.getMessages(currentChatId!).listen((messagesList) {
        messages.value = messagesList;
        _markMessagesAsRead();
      });
    }
  }

  String getChatId(String otherUserId) {
    final currentUserId = authController.user.value!.uid;
    final sortedIds = [currentUserId, otherUserId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<void> sendMessage({String? imageUrl}) async {
    if (messageController.text.trim().isEmpty && imageUrl == null) return;
    if (currentChatId == null || currentReceiverId == null) return;

    final message = MessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: authController.user.value!.uid,
      receiverId: currentReceiverId!,
      content: messageController.text.trim(),
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    // Create or update chat room
    final chatRoom = ChatRoom(
      chatId: currentChatId!,
      participants: [authController.user.value!.uid, currentReceiverId!],
      lastMessage: imageUrl != null ? '📷 Image' : message.content,
      lastMessageType: imageUrl != null ? 'image' : 'text',
      lastMessageTime: message.timestamp,
      lastMessageSenderId: message.senderId,
      unreadCount: {
        currentReceiverId!: (chatRooms
                    .firstWhereOrNull((room) => room.chatId == currentChatId)
                    ?.unreadCount[currentReceiverId!] ??
                0) +
            1
      },
    );

    await _firebaseService.createOrUpdateChatRoom(chatRoom);
    await _firebaseService.sendMessage(currentChatId!, message);
    messageController.clear();

    await _sendPushNotification(message);
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
    if (currentChatId == null) return;

    final currentUserId = authController.user.value!.uid;
    final unreadMessages = messages
        .where(
            (message) => message.receiverId == currentUserId && !message.isRead)
        .toList();

    for (var message in unreadMessages) {
      await _firebaseService.markMessageAsRead(
          currentChatId!, message.messageId);
    }

    // Update unread count in chat room
    final chatRoom =
        chatRooms.firstWhereOrNull((room) => room.chatId == currentChatId);
    if (chatRoom != null) {
      final updatedUnreadCount = Map<String, int>.from(chatRoom.unreadCount);
      updatedUnreadCount[currentUserId] = 0;

      await _firebaseService.updateChatRoomUnreadCount(
          currentChatId!, updatedUnreadCount);
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _loadUsers();
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    allUsers.value = allUsers
        .where((user) =>
            user.name.toLowerCase().contains(lowercaseQuery) ||
            user.email.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  Future<void> _sendPushNotification(MessageModel message) async {
    if (currentReceiverId == null) return;
    // await _firebaseService.sendPushNotification(currentReceiverId!, message);
  }

  void _openChat(UserModel user) async {
    final chatId = getChatId(user.uid);

    // Check if chat exists
    final existingRoom =
        chatRooms.firstWhereOrNull((room) => room.chatId == chatId);

    if (existingRoom != null) {
      // Chat exists, open it
      Get.toNamed(
        Routes.CHAT,
        arguments: {
          'userId': user.uid,
          'chatId': chatId,
          'userName': user.name,
        },
      );
    } else {
      // Create new chat
      await startNewChat(user);
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
