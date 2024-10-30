# Chat App

A real-time chat application built with Flutter and Firebase.

## Features

- Google Sign-In Authentication
- Real-time messaging
- Image sharing in chats
- User online/offline status
- Profile management
- Push notifications
- Message read status
- User search functionality

## Dependencies

- get: ^4.6.6 (State Management)
- firebase_core: ^3.6.0
- firebase_auth: ^5.3.1
- google_sign_in: ^6.2.1
- firebase_database: ^11.1.4
- firebase_messaging: ^15.1.3
- firebase_storage: ^12.3.4
- timeago: ^3.6.0
- cached_network_image: ^3.3.1
- image_picker: ^1.0.7
- intl: ^0.19.0
- permission_handler: ^11.2.0
- googleapis_auth: ^1.6.0
- flutter_local_notifications: 17.2.1+2

## Setup

1. Create a Firebase project
2. Add your Firebase configuration files:
   - For Android: `android/app/google-services.json`
   - For iOS: `ios/Runner/GoogleService-Info.plist`
3. Enable Authentication with Google Sign-In
4. Enable Realtime Database
5. Enable Storage
6. Enable Cloud Messaging
7. Run `flutter pub get`
8. Run the app

## Architecture

This project follows the MVVM architecture pattern using GetX:

- Models: Data models
- Views: UI components
- ViewModels: Controllers using GetX
- Services: Firebase and other services

