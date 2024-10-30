import 'package:get/instance_manager.dart';
import '../controllers/chat_controller.dart';

class MessageBinding extends Bindings {
  @override
  void dependencies() {
    // We'll reuse the existing ChatController instance
    Get.find<ChatController>();
  }
}
