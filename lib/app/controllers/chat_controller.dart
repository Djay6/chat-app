import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/data/models/chat_room.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../data/models/message_model.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_service.dart';

class ChatController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> chatUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadChatUsers();
  }

  void _loadUsers() {
    _firebaseService.getAllUsers().listen((users) {
      allUsers.value = users
          .where((user) => user.uid != _authController.user.value?.uid)
          .toList();
    });
  }

  void _loadChatUsers() {
    final currentUserId = _authController.user.value!.uid;
    FirebaseDatabase.instance
        .ref()
        .child('userChats/$currentUserId')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> chats =
            event.snapshot.value as Map<dynamic, dynamic>;
        _loadChatUserDetails(chats.keys.toList());
      }
    });
  }

  Future<void> _loadChatUserDetails(List<dynamic> userIds) async {
    chatUsers.clear();
    for (String userId in userIds) {
      final snapshot =
          await FirebaseDatabase.instance.ref().child('users/$userId').get();
      if (snapshot.value != null) {
        chatUsers.add(UserModel.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map)));
      }
    }
  }

  String getChatId(String userId) {
    final currentUserId = _authController.user.value!.uid;
    var sortedIds = [currentUserId, userId];
    sortedIds.sort();
    return sortedIds.join('_');
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      _loadUsers();
    } else {
      final filteredUsers = allUsers
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
      allUsers.value = filteredUsers;
    }
  }
}
