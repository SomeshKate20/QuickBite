import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('QuickBite background notification: ${message.messageId}');
}

class NotificationService {
  FirebaseMessaging? _messaging;
  bool _firebaseInitialized = false;

  bool get firebaseAvailable => _firebaseInitialized;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      _firebaseInitialized = true;
      await _requestPermissions();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          'QuickBite foreground notification: ${message.notification?.title}',
        );
      });
      final token = await _messaging!.getToken();
      debugPrint('QuickBite FCM token: $token');
    } catch (e) {
      _firebaseInitialized = false;
      debugPrint('Firebase not available for notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (_messaging != null) {
      await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }
}
