import 'dart:convert';
import 'dart:io';

import 'package:chat_app/app/data/models/chat_room.dart';
import 'package:chat_app/app/data/models/message_model.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class FirebaseService extends GetxService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        await updateFCMToken(token);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground messages
        // _showLocalNotification(message);
      });

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
  }

  Future<void> updateFCMToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _dbRef.child('users/${user.uid}/fcmToken').set(token);
    }
  }

  Future<String> uploadImage(File file) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = _storage.ref().child('chat_images/$fileName');
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Stream<List<UserModel>> getAllUsers() {
    return _dbRef.child('users').onValue.map((event) {
      final Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (values == null) return [];

      return values.entries
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e.value)))
          .toList();
    });
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _dbRef.child('chats/$chatId/messages').onValue.map((event) {
      if (event.snapshot.value == null) return [];

      try {
        final messagesMap =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        final messages = messagesMap.entries.map((entry) {
          return MessageModel.fromJson(Map<String, dynamic>.from(entry.value));
        }).toList();

        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return messages;
      } catch (e) {
        print('Error parsing messages: $e');
        return [];
      }
    });
  }

  Stream<List<ChatRoom>> getUserChats(String userId) {
    return _dbRef.child('chats').onValue.map((event) {
      if (event.snapshot.value == null) return [];

      try {
        final allChats = Map<String, dynamic>.from(event.snapshot.value as Map);
        final List<ChatRoom> chatRooms = [];

        for (var chatEntry in allChats.entries) {
          final chatData = Map<String, dynamic>.from(chatEntry.value);
          final participants = List<String>.from(chatData['participants']);

          // Only include chats where the current user is a participant
          if (participants.contains(userId)) {
            chatRooms.add(ChatRoom.fromJson(chatData));
          }
        }

        // Sort by last message time
        chatRooms
            .sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return chatRooms;
      } catch (e) {
        print('Error fetching chat rooms: $e');
        return [];
      }
    });
  }

  Future<void> createOrUpdateChatRoom(ChatRoom chatRoom) async {
    final updates = {
      'chats/${chatRoom.chatId}/chatId': chatRoom.chatId,
      'chats/${chatRoom.chatId}/participants': chatRoom.participants,
      'chats/${chatRoom.chatId}/lastMessage': chatRoom.lastMessage,
      'chats/${chatRoom.chatId}/lastMessageType': chatRoom.lastMessageType,
      'chats/${chatRoom.chatId}/lastMessageTime':
          chatRoom.lastMessageTime.toIso8601String(),
      'chats/${chatRoom.chatId}/lastMessageSenderId':
          chatRoom.lastMessageSenderId,
      'chats/${chatRoom.chatId}/unreadCount': chatRoom.unreadCount,
    };

    // Update participants' chatIds
    for (String userId in chatRoom.participants) {
      final userRef = _dbRef.child('users/$userId');
      final snapshot = await userRef.get();

      if (snapshot.value != null) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final user = UserModel.fromJson(userData);

        if (!user.chatIds.contains(chatRoom.chatId)) {
          updates['users/$userId/chatIds'] = [...user.chatIds, chatRoom.chatId];
          updates['users/$userId/updatedAt'] = DateTime.now().toIso8601String();
        }
      }
    }

    await _dbRef.update(updates);
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      // 1. Generate a unique key for the message
      final newMessageRef = _dbRef.child('chats/$chatId/messages').push();
      final messageId = newMessageRef.key!;

      // 2. Create message data with the generated key
      final messageData = {
        ...message.toJson(),
        'messageId': messageId,
      };

      // 3. Get current chat data
      final chatSnapshot = await _dbRef.child('chats/$chatId').get();
      if (chatSnapshot.value != null) {
        final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
        final participants = List<String>.from(chatData['participants']);
        final receiverId =
            participants.firstWhere((id) => id != message.senderId);
        final currentUnreadCount =
            ((chatData['unreadCount'] as Map?)?[receiverId] ?? 0) as int;

        // 4. Create updates map with correct paths
        final updates = {
          // Update message
          'chats/$chatId/messages/$messageId': messageData,

          // Update chat metadata
          'chats/$chatId/lastMessage': message.content,
          'chats/$chatId/lastMessageType':
              message.imageUrl != null ? 'image' : 'text',
          'chats/$chatId/lastMessageTime': message.timestamp.toIso8601String(),
          'chats/$chatId/lastMessageSenderId': message.senderId,

          // Update unread count for receiver
          'chats/$chatId/unreadCount/$receiverId': currentUnreadCount + 1,
        };

        // Add timestamp updates for participants
        for (String userId in participants) {
          updates['users/$userId/updatedAt'] = DateTime.now().toIso8601String();
        }

        // 5. Perform the update
        await _dbRef.update(updates);
      }

      // Get receiver's FCM token
      final receiverSnapshot =
          await _dbRef.child('users/${message.receiverId}/fcmToken').get();

      if (receiverSnapshot.value != null) {
        final receiverToken = receiverSnapshot.value.toString();

        // Get sender's name
        final senderSnapshot =
            await _dbRef.child('users/${message.senderId}/name').get();

        final senderName = senderSnapshot.value?.toString() ?? 'Someone';

        // Send notification using HTTP v1
        await sendFcmNotification(
          receiverToken,
          senderName,
          message.imageUrl != null ? '📷 Image' : message.content,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _dbRef
        .child('chats/$chatId/messages/$messageId')
        .update({'isRead': true});
  }

  Future<void> updateChatRoomUnreadCount(
      String chatId, Map<String, int> unreadCount) async {
    await _dbRef.child('chats/$chatId').update({'unreadCount': unreadCount});
  }

  Future<void> sendPushNotification(
      String receiverId, MessageModel message) async {
    final receiverSnapshot = await _dbRef.child('users/$receiverId').get();

    if (receiverSnapshot.value != null) {
      final receiverData =
          Map<String, dynamic>.from(receiverSnapshot.value as Map);
      final fcmToken = receiverData['fcmToken'];

      if (fcmToken != null) {
        // Implement your push notification logic here
      }
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final serviceAccount =
          await rootBundle.loadString('assets/json/service-account.json');
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(credentials, scopes);
      return client.credentials.accessToken.data;
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  Future<void> sendFcmNotification(
      String receiverFcmToken, String senderName, String message) async {
    try {
      final accessToken = await _getAccessToken();
      final projectId = 'chat-app-b4470';

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': receiverFcmToken,
            'notification': {
              'title': senderName,
              'body': message,
            },
            'android': {
              'notification': {
                'sound': 'default',
                'channel_id': 'messages',
                'notification_priority': 'PRIORITY_HIGH',
              },
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'category': 'message',
                },
              },
            },
            'data': {
              'type': 'message',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('FCM notification failed: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages
}
