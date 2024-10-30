import 'package:chat_app/app/controllers/chat_controller.dart';
import 'package:chat_app/app/controllers/home_controller.dart';
import 'package:chat_app/app/controllers/profile_controller.dart';
import 'package:get/instance_manager.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(ChatController());
    Get.put(ProfileController());
  }
}
