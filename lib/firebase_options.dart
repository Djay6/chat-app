// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDS7W3VqywKhZGG3Xm7KGhW71lkKxgGQWc',
    appId: '1:921159563809:android:69779d8a99376fd9a8c160',
    messagingSenderId: '921159563809',
    projectId: 'chat-app-b4470',
    databaseURL: 'https://chat-app-b4470-default-rtdb.firebaseio.com',
    storageBucket: 'chat-app-b4470.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgGxoJhFlMv_fIPicFvZVOEcZZ6pV-7aA',
    appId: '1:921159563809:ios:70e4f5287f3fadbfa8c160',
    messagingSenderId: '921159563809',
    projectId: 'chat-app-b4470',
    databaseURL: 'https://chat-app-b4470-default-rtdb.firebaseio.com',
    storageBucket: 'chat-app-b4470.appspot.com',
    iosClientId: '921159563809-l50icuuouv743kuenpuou645vtjiump2.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatApp',
  );
}