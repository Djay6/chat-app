import 'dart:io';

import 'package:chat_app/app/data/models/message_model.dart';
import 'package:chat_app/app/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

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
    return _dbRef
        .child('chats/$chatId/messages')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (values == null) return [];

      return values.entries
          .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e.value)))
          .toList();
    });
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages
}
