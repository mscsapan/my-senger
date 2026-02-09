import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/data_provider/database_config.dart';

/// Diagnostic tool for debugging notification issues
class NotificationDiagnostics {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Run full diagnostics and print results
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    debugPrint('\n========== NOTIFICATION DIAGNOSTICS ==========\n');

    // 1. Check if user is logged in
    final user = _auth.currentUser;
    results['user_logged_in'] = user != null;
    results['user_id'] = user?.uid;
    debugPrint('1. User logged in: ${user != null}');
    debugPrint('   User ID: ${user?.uid ?? "N/A"}');

    if (user == null) {
      debugPrint('❌ User not logged in - cannot proceed');
      return results;
    }

    // 2. Check FCM token
    try {
      final token = await _messaging.getToken();
      results['fcm_token_exists'] = token != null && token.isNotEmpty;
      results['fcm_token_preview'] = token != null && token.length > 20
          ? '${token.substring(0, 20)}...'
          : token;
      debugPrint('2. FCM Token exists: ${token != null}');
      debugPrint('   Token preview: ${results['fcm_token_preview']}');
    } catch (e) {
      results['fcm_token_error'] = e.toString();
      debugPrint('2. ❌ FCM Token error: $e');
    }

    // 3. Check user document in Firestore
    try {
      final userDoc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(user.uid)
          .get();

      results['user_doc_exists'] = userDoc.exists;

      if (userDoc.exists) {
        final userData = userDoc.data();
        final storedToken =
            userData?[DatabaseConfig.fieldDeviceToken] as String?;
        results['stored_token_exists'] =
            storedToken != null && storedToken.isNotEmpty;
        results['stored_token_preview'] =
            storedToken != null && storedToken.length > 20
            ? '${storedToken.substring(0, 20)}...'
            : storedToken;
        debugPrint('3. User document exists: true');
        debugPrint(
          '   Stored FCM token exists: ${storedToken != null && storedToken.isNotEmpty}',
        );
        debugPrint(
          '   Stored token preview: ${results['stored_token_preview']}',
        );
      } else {
        debugPrint('3. ❌ User document does not exist in Firestore');
      }
    } catch (e) {
      results['user_doc_error'] = e.toString();
      debugPrint('3. ❌ Error checking user document: $e');
    }

    // 4. Check notification permissions
    try {
      final settings = await _messaging.getNotificationSettings();
      results['notification_permission'] = settings.authorizationStatus.name;
      debugPrint(
        '4. Notification permission: ${settings.authorizationStatus.name}',
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('   ⚠️ Notifications are not authorized!');
      }
    } catch (e) {
      results['permission_error'] = e.toString();
      debugPrint('4. ❌ Error checking permissions: $e');
    }

    // 5. Check notification queue
    try {
      final queueDocs = await _db
          .collection('notification_queue')
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      results['queue_count'] = queueDocs.docs.length;
      debugPrint('5. Recent notifications in queue: ${queueDocs.docs.length}');

      for (final doc in queueDocs.docs) {
        final data = doc.data();
        debugPrint(
          '   - To: ${data['receiver_id']?.toString().substring(0, 8)}..., '
          'Processed: ${data['processed']}, '
          'Error: ${data['error'] ?? 'none'}',
        );
      }
    } catch (e) {
      results['queue_error'] = e.toString();
      debugPrint('5. ❌ Error checking notification queue: $e');
    }

    // 6. Check if Cloud Functions are deployed
    debugPrint('\n6. Cloud Functions Status:');
    debugPrint('   To check if Cloud Functions are deployed:');
    debugPrint('   - Go to Firebase Console > Functions');
    debugPrint(
      '   - Look for "processNotificationQueue" or "sendChatNotification"',
    );
    debugPrint(
      '   - If not present, deploy with: firebase deploy --only functions',
    );

    debugPrint('\n========== END DIAGNOSTICS ==========\n');

    return results;
  }

  /// Save current FCM token to Firestore
  static Future<bool> syncFcmToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ Cannot sync token - user not logged in');
      return false;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ Cannot sync token - no FCM token available');
        return false;
      }

      await _db.collection(DatabaseConfig.userCollection).doc(user.uid).set({
        DatabaseConfig.fieldDeviceToken: token,
      }, SetOptions(merge: true));

      debugPrint('✅ FCM token synced to Firestore');
      return true;
    } catch (e) {
      debugPrint('❌ Error syncing FCM token: $e');
      return false;
    }
  }

  /// Send a test notification to yourself
  static Future<void> sendTestNotification() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ Cannot send test - user not logged in');
      Fluttertoast.showToast(msg: 'User not logged in');
      return;
    }

    try {
      // Get current user's FCM token
      final userDoc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        Fluttertoast.showToast(msg: 'User document not found');
        return;
      }

      final userData = userDoc.data();
      final fcmToken = userData?[DatabaseConfig.fieldDeviceToken] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        Fluttertoast.showToast(msg: 'No FCM token found - syncing now...');
        await syncFcmToken();
        return;
      }

      // Queue a test notification
      await _db.collection('notification_queue').add({
        'receiver_id': user.uid,
        'receiver_token': fcmToken,
        'sender_id': 'system',
        'sender_name': '🔔 Test Notification',
        'message': 'If you see this, notifications are working!',
        'chat_room_id': '',
        'type': 'test',
        'created_at': FieldValue.serverTimestamp(),
        'processed': false,
      });

      debugPrint('✅ Test notification queued');
      Fluttertoast.showToast(
        msg: 'Test notification queued. Check if Cloud Functions are deployed.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  /// Show diagnostics dialog
  static void showDiagnosticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Diagnostics'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: runDiagnostics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final results = snapshot.data ?? {};
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildResultRow('User logged in', results['user_logged_in']),
                  _buildResultRow(
                    'FCM token exists',
                    results['fcm_token_exists'],
                  ),
                  _buildResultRow(
                    'User doc exists',
                    results['user_doc_exists'],
                  ),
                  _buildResultRow(
                    'Token saved',
                    results['stored_token_exists'],
                  ),
                  _buildResultRow(
                    'Permission',
                    results['notification_permission'],
                  ),
                  _buildResultRow('Queue items', results['queue_count']),
                  const SizedBox(height: 16),
                  const Text(
                    'Check console logs for detailed info',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => syncFcmToken(),
            child: const Text('Sync Token'),
          ),
          TextButton(
            onPressed: () => sendTestNotification(),
            child: const Text('Send Test'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildResultRow(String label, dynamic value) {
    final isOk =
        value == true || value == 'authorized' || (value is int && value > 0);
    final icon = isOk ? '✅' : '❌';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 8),
          Expanded(child: Text('$label: ${value ?? "N/A"}')),
        ],
      ),
    );
  }
}
