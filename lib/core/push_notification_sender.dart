import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/data_provider/database_config.dart';

/// Service for sending push notifications to users
///
/// Note: For production, you should use Firebase Cloud Functions instead
/// of sending notifications directly from the client. This approach is
/// provided for development and testing purposes.
class PushNotificationSender {
  // Singleton pattern
  static final PushNotificationSender _instance =
      PushNotificationSender._internal();
  factory PushNotificationSender() => _instance;
  PushNotificationSender._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // FCM Server Key - You need to get this from Firebase Console:
  // Project Settings > Cloud Messaging > Server key (Legacy)
  // IMPORTANT: In production, NEVER store this in client code!
  // Use Cloud Functions instead.
  static const String _fcmServerKey = 'YOUR_FCM_SERVER_KEY_HERE';

  // FCM Legacy HTTP API endpoint
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  /// Send a chat message notification to a user
  Future<bool> sendChatNotification({
    required String receiverUserId,
    required String senderName,
    required String message,
    required String chatRoomId,
    required String senderId,
  }) async {
    try {
      // Get receiver's FCM token from Firestore
      final receiverDoc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(receiverUserId)
          .get();

      if (!receiverDoc.exists) {
        debugPrint('❌ Receiver document not found');
        return false;
      }

      final receiverData = receiverDoc.data();
      final fcmToken =
          receiverData?[DatabaseConfig.fieldDeviceToken] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('❌ Receiver has no FCM token');
        return false;
      }

      // Check if server key is configured
      if (_fcmServerKey == 'YOUR_FCM_SERVER_KEY_HERE') {
        debugPrint(
          '⚠️ FCM Server Key not configured. Skipping push notification.',
        );
        debugPrint('To enable notifications:');
        debugPrint(
          '1. Go to Firebase Console > Project Settings > Cloud Messaging',
        );
        debugPrint('2. Copy the "Server key" (Legacy) or use Cloud Functions');
        return false;
      }

      // Prepare notification payload
      final notificationPayload = {
        'to': fcmToken,
        'notification': {
          'title': senderName,
          'body': message.length > 100
              ? '${message.substring(0, 97)}...'
              : message,
          'sound': 'default',
          'badge': '1',
        },
        'data': {
          'type': 'chat_message',
          'chat_room_id': chatRoomId,
          'sender_id': senderId,
          'sender_name': senderName,
          'message': message,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'priority': 'high',
        'content_available': true,
      };

      // Send notification via FCM
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          debugPrint('✅ Push notification sent successfully');
          return true;
        } else {
          debugPrint('❌ FCM Error: ${responseData['results']}');
          return false;
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending push notification: $e');
      return false;
    }
  }

  /// Send notification using Firestore trigger (alternative approach)
  /// This creates a document that a Cloud Function can pick up
  Future<void> queueNotification({
    required String receiverUserId,
    required String senderName,
    required String message,
    required String chatRoomId,
    required String senderId,
  }) async {
    try {
      await _db.collection('notification_queue').add({
        'receiver_id': receiverUserId,
        'sender_id': senderId,
        'sender_name': senderName,
        'message': message,
        'chat_room_id': chatRoomId,
        'type': 'chat_message',
        'created_at': FieldValue.serverTimestamp(),
        'sent': false,
      });
      debugPrint('✅ Notification queued for Cloud Function processing');
    } catch (e) {
      debugPrint('❌ Error queueing notification: $e');
    }
  }
}
