import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/data_provider/database_config.dart';

/// Top-level function to handle background messages
/// This must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store the last known FCM token to avoid redundant updates
  String? _lastKnownToken;

  /// Initialize the notification service
  Future<void> init() async {
    try {
      // Request permission for iOS
      await _requestPermission();

      // Configure foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications for Android
      await _initializeLocalNotifications();

      // Get and sync FCM token
      await _initializeFcmToken();

      // Listen to token refresh and sync to Firestore
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        _updateFcmTokenInFirestore(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Request notification permission (iOS)
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // For Android 13+ (API level 33+)
      final status = await Permission.notification.request();
      debugPrint('Android notification permission: $status');
    }
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Initialize FCM token - get token and sync to Firestore if needed
  Future<void> _initializeFcmToken() async {
    try {
      final String? currentToken = await _messaging.getToken();

      if (currentToken == null) {
        debugPrint('⚠️ FCM Token is null');
        return;
      }

      debugPrint('📱 Current FCM Token: $currentToken');

      // Get stored token from Firestore to compare
      final String? storedToken = await _getStoredFcmToken();

      // Only update Firestore if token has changed
      if (storedToken != currentToken) {
        debugPrint('🔄 FCM Token changed, updating Firestore...');
        debugPrint('   Old: $storedToken');
        debugPrint('   New: $currentToken');
        await _updateFcmTokenInFirestore(currentToken);
      } else {
        debugPrint('✅ FCM Token unchanged, skipping Firestore update');
      }

      _lastKnownToken = currentToken;
    } catch (e) {
      debugPrint('❌ Error initializing FCM token: $e');
    }
  }

  /// Get FCM token (public method for external use)
  Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Get stored FCM token from Firestore
  Future<String?> _getStoredFcmToken() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('⚠️ User not authenticated, cannot get stored token');
        return null;
      }

      final doc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()?['device_token'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting stored FCM token: $e');
      return null;
    }
  }

  /// Update FCM token in Firestore
  Future<void> _updateFcmTokenInFirestore(String token) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('⚠️ User not authenticated, cannot update token');
        return;
      }

      // Check if token actually changed before updating
      if (_lastKnownToken == token) {
        debugPrint('⏭️ Token unchanged, skipping update');
        return;
      }

      await _db.collection(DatabaseConfig.userCollection).doc(userId).update({
        'device_token': token,
      });

      _lastKnownToken = token;
      debugPrint('✅ FCM Token updated in Firestore');
    } catch (e) {
      debugPrint('❌ Error updating FCM token in Firestore: $e');
      // If document doesn't exist, try to set it
      if (e is FirebaseException && e.code == 'not-found') {
        try {
          final String? userId = _auth.currentUser?.uid;
          if (userId != null) {
            await _db.collection(DatabaseConfig.userCollection).doc(userId).set(
              {'device_token': token},
              SetOptions(merge: true),
            );
            _lastKnownToken = token;
            debugPrint('✅ FCM Token set in Firestore (document created)');
          }
        } catch (setError) {
          debugPrint('❌ Error setting FCM token: $setError');
        }
      }
    }
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Show local notification when app is in foreground
    if (notification != null && android != null) {
      _showLocalNotification(
        id: notification.hashCode,
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Handle notification tap (when app is in background)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    // Navigate based on notification data
    _navigateBasedOnPayload(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');

    // Parse payload and navigate
    if (response.payload != null) {
      // TODO: Parse payload and navigate to appropriate screen
      debugPrint('Payload: ${response.payload}');
    }
  }

  /// Navigate to appropriate screen based on notification payload
  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    // Example: Navigate based on notification type
    String? type = data['type'];
    String? chatId = data['chatId'];
    String? userId = data['userId'];

    debugPrint(
      'Navigation data - type: $type, chatId: $chatId, userId: $userId',
    );

    // TODO: Implement navigation logic based on your app's routes
    // Example:
    // if (type == 'chat' && chatId != null) {
    //   NavigationService.navigateTo(RouteNames.chatScreen, arguments: chatId);
    // } else if (type == 'profile' && userId != null) {
    //   NavigationService.navigateTo(RouteNames.profileScreen, arguments: userId);
    // }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
