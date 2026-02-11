import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/data_provider/database_config.dart';
import '../data/models/chat/chat_room_model.dart';
import '../data/models/chat/chat_user_model.dart';
import '../presentation/routes/route_names.dart';
import '../presentation/utils/navigation_service.dart';

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
  static final NotificationService _notificationService = NotificationService._internal();
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

  // Store the current active chat room ID to prevent notifications
  String? _activeChatRoomId;

  /// Set the active chat room (to suppress notifications while in chat)
  void setActiveChatRoom(String? chatRoomId) {
    _activeChatRoomId = chatRoomId;
    debugPrint('Active chat room set to: $chatRoomId');
  }

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
      // await _initializeFcmToken();

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
        // Delay navigation to allow app to initialize
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationTap(initialMessage);
        });
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
      // Chat messages channel
      const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
        'chat_messages_channel',
        'Chat Messages',
        description: 'Notifications for new chat messages.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // High importance channel for other notifications
      const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(chatChannel);
      await androidPlugin?.createNotificationChannel(highChannel);
    }
  }

  /// Initialize FCM token - get token and sync to Firestore if needed
  Future<void> initializeFcmToken() async {
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
        return doc.data()?[DatabaseConfig.fieldDeviceToken] as String?;
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
        DatabaseConfig.fieldDeviceToken: token,
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
              {DatabaseConfig.fieldDeviceToken: token},
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

    // Extract chat data
    final String? chatRoomId = message.data['chat_room_id'];
    final String? senderName = message.data['sender_name'];
    final String? messageContent = message.data['message'];
    final String? type = message.data['type'];

    // Don't show notification if we're in the same chat room
    if (type == 'chat_message' && chatRoomId == _activeChatRoomId) {
      debugPrint('📱 Suppressing notification - user is in active chat');
      return;
    }

    RemoteNotification? notification = message.notification;

    // Show local notification when app is in foreground
    if (notification != null) {
      _showChatNotification(
        id: notification.hashCode,
        title: senderName ?? notification.title ?? 'New Message',
        body: messageContent ?? notification.body ?? '',
        chatRoomId: chatRoomId,
        senderId: message.data['sender_id'],
      );
    } else if (type == 'chat_message' && messageContent != null) {
      // Handle data-only messages
      _showChatNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: senderName ?? 'New Message',
        body: messageContent,
        chatRoomId: chatRoomId,
        senderId: message.data['sender_id'],
      );
    }
  }

  /// Show chat notification with action support
  Future<void> _showChatNotification({
    required int id,
    required String title,
    required String body,
    String? chatRoomId,
    String? senderId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_messages_channel',
          'Chat Messages',
          channelDescription: 'Notifications for new chat messages.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          category: AndroidNotificationCategory.message,
          styleInformation: BigTextStyleInformation(''),
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

    // Create payload with chat info for navigation
    final payload = {
      'type': 'chat_message',
      'chat_room_id': chatRoomId ?? '',
      'sender_id': senderId ?? '',
    }.entries.map((e) => '${e.key}=${e.value}').join('&');

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
    if (response.payload != null && response.payload!.isNotEmpty) {
      final Map<String, String> data = {};
      final pairs = response.payload!.split('&');
      for (final pair in pairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          data[keyValue[0]] = keyValue[1];
        }
      }
      _navigateBasedOnPayload(data);
    }
  }

  /// Navigate to appropriate screen based on notification payload
  Future<void> _navigateBasedOnPayload(Map<String, dynamic> data) async {
    final String? type = data['type']?.toString();
    final String? chatRoomId = data['chat_room_id']?.toString();
    final String? senderId = data['sender_id']?.toString();

    debugPrint(
      'Navigation data - type: $type, chatRoomId: $chatRoomId, senderId: $senderId',
    );

    if (type == 'chat_message' && chatRoomId != null && chatRoomId.isNotEmpty) {
      await _navigateToChatRoom(chatRoomId, senderId);
    }
  }

  /// Navigate to a specific chat room
  Future<void> _navigateToChatRoom(String chatRoomId, String? senderId) async {
    try {
      // Fetch the chat room data
      final chatRoomDoc = await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        debugPrint('❌ Chat room not found: $chatRoomId');
        return;
      }

      var chatRoom = ChatRoomModel.fromDocument(chatRoomDoc);

      // Fetch the other user's data
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null) {
        final otherUserId = chatRoom.getOtherParticipantId(currentUserId);
        if (otherUserId.isNotEmpty) {
          final userDoc = await _db
              .collection(DatabaseConfig.userCollection)
              .doc(otherUserId)
              .get();

          if (userDoc.exists) {
            final otherUser = ChatUserModel.fromDocument(userDoc);
            chatRoom = chatRoom.copyWith(otherUser: otherUser);
          }
        }
      }

      // Navigate to the conversation screen
      NavigationService.navigateTo(
        RouteNames.conversationScreen,
        arguments: chatRoom,
      );

      debugPrint('✅ Navigated to chat room: $chatRoomId');
    } catch (e) {
      debugPrint('❌ Error navigating to chat room: $e');
    }
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
