import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToDatabase(user);
        Get.offAllNamed('/home');
      }
    } catch (error) {
      print('Error during Google sign in: $error');
      Get.snackbar(
        'Error',
        'Failed to sign in with Google',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    try {
      final userRef =
          FirebaseDatabase.instance.ref().child('users/${user.uid}');

      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'lastSeen': DateTime.now().toIso8601String(),
        'isOnline': true,
        'fcmToken': await FirebaseMessaging.instance.getToken(),
      });
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
