import 'package:chat_app/app/bindings/auth_binding.dart';
import 'package:chat_app/app/bindings/home_binding.dart';
import 'package:chat_app/app/bindings/message_binding.dart';
import 'package:chat_app/app/middleware/auth_middleware.dart';
import 'package:chat_app/app/modules/auth/views/login_view.dart';
import 'package:chat_app/app/modules/chat/views/chat_room_view.dart';
import 'package:chat_app/app/modules/home/views/home_view.dart';
import 'package:chat_app/app/modules/splash/bindings/splash_binding.dart';
import 'package:chat_app/app/modules/splash/views/splash_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => const ChatRoomView(),
      binding: MessageBinding(),
    ),
  ];
}

abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const CHAT = '/chat';
}
