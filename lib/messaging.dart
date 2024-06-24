// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class MessagingService with ChangeNotifier {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   MessagingService() {
//     _firebaseMessaging.requestPermission();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     });
//   }

//   Future<String?> getToken() async {
//     return await _firebaseMessaging.getToken();
//   }
// }
