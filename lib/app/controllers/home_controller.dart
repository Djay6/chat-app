import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final AuthController authController = Get.find<AuthController>();

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);
    _updateFcmToken();
  }

  Future<void> _updateFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final userId = authController.user.value?.uid;
      if (userId != null && fcmToken != null) {
        await FirebaseDatabase.instance
            .ref()
            .child('users/$userId')
            .update({'fcmToken': fcmToken});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  void _handleTabChange() {
    if (!tabController.indexIsChanging) {
      currentIndex.value = tabController.index;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
    tabController.animateTo(index);
  }

  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      changeTab(0);
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    super.onClose();
  }
}
