import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/data/services/firebase_service.dart';
import 'package:get/instance_manager.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService());
    Get.put(AuthController());
  }
}
