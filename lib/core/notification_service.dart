import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('App opened from notification: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          'App launched from notification: ${initialMessage.messageId}',
        );
        // Add a delay to ensure the app is fully initialized
        // and the navigator is ready
        Future.delayed(const Duration(milliseconds: 1500), () {
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

  /// Download and cache image from URL, asset, or local path
  Future<String?> _getCachedImagePath(
    String? imagePath, {
    bool makeCircular = false,
  }) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      // Handle asset paths (e.g., 'assets/images/...')
      if (imagePath.startsWith('assets/')) {
        debugPrint('📦 Loading asset: $imagePath');
        final byteData = await rootBundle.load(imagePath);
        final tempDir = await getTemporaryDirectory();
        final fileName = imagePath.hashCode.toString();
        final filePath = '${tempDir.path}/notification_asset_$fileName.jpg';
        final file = File(filePath);

        if (!await file.exists()) {
          await file.writeAsBytes(byteData.buffer.asUint8List());
          debugPrint('✅ Asset cached at: $filePath');
        }

        if (makeCircular) {
          return await _makeCircularBitmap(filePath);
        }
        return filePath;
      }

      // Handle local file paths (not assets)
      if (!imagePath.startsWith('http')) {
        final localFile = File(imagePath);
        if (await localFile.exists()) {
          debugPrint('✅ Using local file: $imagePath');
          if (makeCircular) {
            return await _makeCircularBitmap(imagePath);
          }
          return imagePath;
        }
        debugPrint('❌ Local file not found: $imagePath');
        return null;
      }

      // Handle remote URLs
      final cacheDir = await getTemporaryDirectory();
      final fileName = imagePath.hashCode.toString();
      final filePath = '${cacheDir.path}/notification_$fileName.jpg';
      final cachedFile = File(filePath);

      // Return cached file if it already exists
      if (await cachedFile.exists()) {
        debugPrint('✅ Using cached image: $filePath');
        if (makeCircular) {
          return await _makeCircularBitmap(filePath);
        }
        return filePath;
      }

      debugPrint('📥 Downloading image from: $imagePath');
      final response = await http
          .get(Uri.parse(imagePath))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Image download timeout');
            },
          );

      if (response.statusCode == 200) {
        await cachedFile.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Image cached at: $filePath');
        if (makeCircular) {
          return await _makeCircularBitmap(filePath);
        }
        return filePath;
      } else {
        debugPrint('❌ Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error caching image: $e');
      return null;
    }
  }

  /// Create a circular version of the image
  Future<String?> _makeCircularBitmap(String imagePath) async {
    try {
      debugPrint('🔄 Creating circular bitmap for: $imagePath');
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Decode image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final nextFrame = await codec.getNextFrame();
      final image = nextFrame.image;

      // Create circular image
      final size = ui.Size(image.width.toDouble(), image.height.toDouble());
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Offset.zero & size);

      // Draw circular clip
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        Paint()
          ..color = Colors.white
          ..isAntiAlias = true,
      );

      // Draw image within circle
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(size.width / 2.0, size.height / 2.0),
            radius: size.width / 2.0,
          ),
        ),
      );
      canvas.drawImage(image, Offset.zero, Paint());
      canvas.restore();

      // Convert back to bytes
      final picture = recorder.endRecording();
      final circularImage = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final bytes = await circularImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // Save circular image
      final tempDir = await getTemporaryDirectory();
      final circularPath = '${tempDir.path}/circular_${imagePath.hashCode}.png';
      await File(circularPath).writeAsBytes(bytes!.buffer.asUint8List());

      debugPrint('✅ Circular bitmap created at: $circularPath');
      return circularPath;
    } catch (e) {
      debugPrint('❌ Error creating circular bitmap: $e');
      return imagePath; // Return original if circular fails
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
    final String? profile = message.data['avatar'];
    final String? bodyImg = message.data['body_image'];
    final String? senderId = message.data['sender_id'];

    debugPrint('═══ Extracted from Firebase message ═══');
    debugPrint(
      'chatRoomId: "$chatRoomId" (null: ${chatRoomId == null}, empty: ${chatRoomId?.isEmpty ?? true})',
    );
    debugPrint(
      'senderId: "$senderId" (null: ${senderId == null}, empty: ${senderId?.isEmpty ?? true})',
    );
    debugPrint('type: "$type"');
    debugPrint('avatar: $profile');
    debugPrint('body image: $bodyImg');

    // Don't show notification if we're in the same chat room
    if (type == 'chat_message' && chatRoomId == _activeChatRoomId) {
      debugPrint('📱 Suppressing notification - user is in active chat');
      return;
    }

    RemoteNotification? notification = message.notification;

    // Show local notification when app is in foreground
    if (notification != null) {
      debugPrint(
        'Showing notification with chatRoomId: "$chatRoomId", senderId: "$senderId"',
      );
      _showChatNotification(
        id: notification.hashCode,
        title: senderName ?? notification.title ?? 'New Message',
        body: messageContent ?? notification.body ?? '',
        chatRoomId: chatRoomId,
        senderId: senderId,
        avatarUrl: profile,
        bodyImageUrl: bodyImg,
      );
    } else if (type == 'chat_message' && messageContent != null) {
      // Handle data-only messages
      debugPrint(
        'Showing data-only notification with chatRoomId: "$chatRoomId", senderId: "$senderId"',
      );
      _showChatNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: senderName ?? 'New Message',
        body: messageContent,
        chatRoomId: chatRoomId,
        senderId: senderId,
        avatarUrl: profile,
        bodyImageUrl: bodyImg,
      );
    }
  }

  /// Show chat notification with action support (direct reply)
  Future<void> _showChatNotification({
    required int id,
    required String title,
    required String body,
    String? chatRoomId,
    String? senderId,
    String? avatarUrl,
    String? bodyImageUrl,
  }) async {
    // Cache images in parallel with avatar as circular
    final avatarPath = await _getCachedImagePath(avatarUrl, makeCircular: true);
    final bodyImagePath = await _getCachedImagePath(
      bodyImageUrl,
      makeCircular: false,
    );

    // Determine style information based on available body image
    final styleInformation = bodyImagePath != null
        ? BigPictureStyleInformation(
            FilePathAndroidBitmap(bodyImagePath),
            contentTitle: title,
            summaryText: body,
            htmlFormatContentTitle: false,
            htmlFormatSummaryText: false,
          )
        : const BigTextStyleInformation('');

    // Android reply action
    final AndroidNotificationDetails androidDetails =
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
          largeIcon: avatarPath != null
              ? FilePathAndroidBitmap(avatarPath)
              : null,
          styleInformation: styleInformation,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'reply',
              'Reply',
              titleColor: Colors.blue,
              showsUserInterface: true,
              inputs: const <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(
                  label: 'Reply',
                  allowFreeFormInput: true,
                ),
              ],
            ),
            const AndroidNotificationAction(
              'mark_read',
              'Mark as read',
              titleColor: Colors.green,
              showsUserInterface: false,
            ),
          ],
          groupKey: 'chat_messages',
          setAsGroupSummary: false,
        );

    /*AndroidNotificationDetails(
      'chat_messages_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.message,
      styleInformation: const BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'reply',
          'Reply',
          titleColor: Colors.red,
          showsUserInterface: true,
          inputs: const <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(label: 'Type reply...'),
          ],
        ),
        const AndroidNotificationAction(
          'mark_read',
          'Mark as read',
          titleColor: Colors.red,
          showsUserInterface: false,
        ),
      ],
      groupKey: 'chat_messages',
      setAsGroupSummary: false,
    );*/

    // iOS interactive notifications
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'New message',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Create payload with chat info for navigation
    debugPrint('═══ Creating notification ═══');
    debugPrint(
      'chatRoomId: "$chatRoomId" (null: ${chatRoomId == null}, empty: ${chatRoomId?.isEmpty ?? true})',
    );
    debugPrint(
      'senderId: "$senderId" (null: ${senderId == null}, empty: ${senderId?.isEmpty ?? true})',
    );

    final payload = {
      'type': 'chat_message',
      'chat_room_id': chatRoomId ?? '',
      'sender_id': senderId ?? '',
    }.entries.map((e) => '${e.key}=${e.value}').join('&');

    debugPrint('Final payload string: "$payload"');

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );

    debugPrint('═══ Notification shown ═══');
  }

  /// Handle notification tap (when app is in background)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    // Navigate based on notification data
    _navigateBasedOnPayload(message.data);
  }

  /// Handle local notification tap and actions
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tap/action: ${response.actionId}');
    debugPrint('Payload: ${response.payload}');
    debugPrint('User input: ${response.input}');
    debugPrint('Input is null: ${response.input == null}');
    debugPrint('Input is empty: ${response.input?.isEmpty ?? true}');

    // Handle action responses (reply, mark as read, etc.)
    if (response.actionId == 'reply') {
      if (response.input != null && response.input!.isNotEmpty) {
        debugPrint('✅ Reply text captured: "${response.input}"');
        _handleDirectReply(response.payload, response.input!);
        return;
      } else {
        debugPrint('⚠️ Reply action triggered but no text input captured');
        // Still navigate to the chat room even if no text was entered
        if (response.payload != null && response.payload!.isNotEmpty) {
          final data = _parsePayload(response.payload!);
          _navigateBasedOnPayload(data, delayNavigation: true);
          return;
        }
      }
    } else if (response.actionId == 'mark_read') {
      debugPrint('Marking notification as read');
      return;
    }

    // Handle notification tap
    if (response.payload != null && response.payload!.isNotEmpty) {
      final data = _parsePayload(response.payload!);
      _navigateBasedOnPayload(data, delayNavigation: true);
    }
  }

  /// Parse payload string into key-value map
  Map<String, String> _parsePayload(String payload) {
    final Map<String, String> data = {};
    if (payload.isEmpty) {
      debugPrint('⚠️ Empty payload string');
      return data;
    }

    debugPrint('Parsing payload: "$payload"');
    final pairs = payload.split('&');
    for (final pair in pairs) {
      if (pair.contains('=')) {
        final keyValue = pair.split('=');
        if (keyValue.length >= 2) {
          final key = keyValue[0];
          final value = keyValue
              .sublist(1)
              .join('='); // Handle values with = in them
          debugPrint('  Parsed: "$key" = "$value"');
          data[key] = value;
        }
      }
    }
    return data;
  }

  /// Navigate to appropriate screen based on notification payload
  Future<void> _navigateBasedOnPayload(
    Map<String, dynamic> data, {
    bool delayNavigation = false,
  }) async {
    final String? type = data['type']?.toString();
    final String? chatRoomId = data['chat_room_id']?.toString();
    final String? senderId = data['sender_id']?.toString();

    debugPrint(
      'Navigation data - type: $type, chatRoomId: $chatRoomId, senderId: $senderId',
    );

    if (type == 'chat_message' && chatRoomId != null && chatRoomId.isNotEmpty) {
      if (delayNavigation) {
        // Delay navigation to ensure the app is fully initialized
        // This is important when tapping notifications from terminated state
        await Future.delayed(const Duration(milliseconds: 500));
      }
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

      // Check if navigator is ready before navigating
      if (NavigationService.navigator != null &&
          NavigationService.navigatorKey.currentContext != null) {
        NavigationService.navigateTo(
          RouteNames.conversationScreen,
          arguments: chatRoom,
        );
        debugPrint('✅ Navigated to chat room: $chatRoomId');
      } else {
        debugPrint('⚠️ Navigator not ready, retrying navigation in 1 second');
        // Retry after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (NavigationService.navigator != null) {
          NavigationService.navigateTo(
            RouteNames.conversationScreen,
            arguments: chatRoom,
          );
          debugPrint('✅ Navigated to chat room after retry: $chatRoomId');
        } else {
          debugPrint('❌ Navigator still not ready after retry');
        }
      }
    } catch (e) {
      debugPrint('❌ Error navigating to chat room: $e');
    }
  }

  /// Handle direct reply from notification
  Future<void> _handleDirectReply(String? payload, String replyText) async {
    debugPrint('═══ Handling direct reply ═══');
    debugPrint('Reply text: "$replyText"');
    debugPrint('Payload: "$payload"');

    try {
      // Parse payload to get chatRoomId and senderId
      final data = payload != null
          ? _parsePayload(payload)
          : <String, String>{};

      final String? chatRoomId = data['chat_room_id'];
      final String? senderId = data['sender_id'];

      debugPrint(
        'Extracted chatRoomId: "$chatRoomId" (empty: ${chatRoomId?.isEmpty ?? true})',
      );
      debugPrint(
        'Extracted senderId: "$senderId" (empty: ${senderId?.isEmpty ?? true})',
      );

      // Validate required fields
      if ((chatRoomId?.isEmpty ?? true) || (senderId?.isEmpty ?? true)) {
        debugPrint('❌ Missing chatRoomId or senderId from payload');
        debugPrint('Available data keys: ${data.keys.toList()}');
        return;
      }

      if (chatRoomId == null || chatRoomId.isEmpty) {
        debugPrint('❌ Cannot send reply - chat room ID missing');
        return;
      }

      // Get current user ID
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        debugPrint('❌ Cannot send reply - user not authenticated');
        return;
      }

      // Add message to Firestore
      final messageRef = _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .collection(DatabaseConfig.messagesCollection)
          .doc();

      await messageRef.set({
        'id': messageRef.id,
        'sender_id': currentUserId,
        'receiver_id': senderId,
        'content': replyText,
        'message_type': 'text',
        'timestamp': FieldValue.serverTimestamp(),
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update chat room's last message
      await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .update({
            'last_message': replyText,
            'last_message_time': FieldValue.serverTimestamp(),
            'last_sender_id': currentUserId,
          });

      debugPrint('✅ Reply sent successfully via notification');

      // Navigate to chat room
      await _navigateToChatRoom(chatRoomId, senderId);
    } catch (e) {
      debugPrint('❌ Error handling direct reply: $e');
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
