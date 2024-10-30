import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

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
