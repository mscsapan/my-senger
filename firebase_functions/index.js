/**
 * Firebase Cloud Functions for Chat Notifications
 * 
 * This file contains Cloud Functions that send push notifications
 * when notification documents are added to the queue.
 * 
 * DEPLOYMENT INSTRUCTIONS:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login to Firebase: firebase login
 * 3. Initialize functions (if not done): firebase init functions
 * 4. Navigate to functions folder: cd firebase_functions
 * 5. Install dependencies: npm install
 * 6. Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

/**
 * Cloud Function triggered when a notification is queued
 * Sends the push notification and marks it as processed
 */
exports.processNotificationQueue = functions.firestore
  .document('notification_queue/{notificationId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const { notificationId } = context.params;

    console.log(`Processing notification: ${notificationId}`);
    console.log('Notification data:', JSON.stringify(data));

    try {
      const receiverToken = data.receiver_token;
      const senderName = data.sender_name || 'Someone';
      const message = data.message || 'New message';
      const chatRoomId = data.chat_room_id || '';
      const senderId = data.sender_id || '';
      const type = data.type || 'chat_message';

      if (!receiverToken) {
        console.log('No receiver token found, skipping notification');
        await snapshot.ref.update({ processed: true, error: 'No token' });
        return null;
      }

      // Prepare notification payload
      const payload = {
        notification: {
          title: senderName,
          body: message,
        },
        data: {
          type: type,
          chat_room_id: chatRoomId,
          sender_id: senderId,
          sender_name: senderName,
          message: message,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        token: receiverToken,
        android: {
          notification: {
            channelId: 'chat_messages_channel',
            priority: 'high',
            sound: 'default',
          },
          priority: 'high',
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              contentAvailable: true,
            },
          },
        },
      };

      // Send notification
      const response = await admin.messaging().send(payload);
      console.log('Notification sent successfully:', response);

      // Mark as processed
      await snapshot.ref.update({
        processed: true,
        processed_at: admin.firestore.FieldValue.serverTimestamp(),
        fcm_response: response,
      });

      return response;
    } catch (error) {
      console.error('Error sending notification:', error);

      // Mark as processed with error
      await snapshot.ref.update({
        processed: true,
        processed_at: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message,
      });

      return null;
    }
  });

/**
 * Alternative: Trigger on new message creation
 * Use this if you prefer direct triggering instead of the queue
 */
exports.sendChatNotification = functions.firestore
  .document('chat_rooms/{chatRoomId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    try {
      const messageData = snapshot.data();
      const { chatRoomId } = context.params;

      const senderId = messageData.sender_id;
      const receiverId = messageData.receiver_id;
      const content = messageData.content;
      const messageType = messageData.message_type || 'text';

      console.log(`New message in chat ${chatRoomId} from ${senderId} to ${receiverId}`);

      // Get sender's info
      const senderDoc = await db.collection('users').doc(senderId).get();
      if (!senderDoc.exists) {
        console.log('Sender document not found');
        return null;
      }

      const senderData = senderDoc.data();
      const senderName =
        `${senderData.first_name || ''} ${senderData.last_name || ''}`.trim() ||
        senderData.email ||
        'Someone';

      // Get receiver's FCM token
      const receiverDoc = await db.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) {
        console.log('Receiver document not found');
        return null;
      }

      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.device_token;

      if (!fcmToken) {
        console.log('Receiver has no FCM token');
        return null;
      }

      // Prepare message preview
      let messagePreview = content;
      if (messageType === 'image') {
        messagePreview = '📷 Sent a photo';
      } else if (messageType === 'file') {
        messagePreview = '📎 Sent a file';
      } else if (content && content.length > 100) {
        messagePreview = content.substring(0, 97) + '...';
      }

      // Send notification
      const payload = {
        notification: {
          title: senderName,
          body: messagePreview,
        },
        data: {
          type: 'chat_message',
          chat_room_id: chatRoomId,
          sender_id: senderId,
          sender_name: senderName,
          message: messagePreview,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        token: fcmToken,
        android: {
          notification: {
            channelId: 'chat_messages_channel',
            priority: 'high',
            sound: 'default',
          },
          priority: 'high',
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(payload);
      console.log('Notification sent successfully:', response);

      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });

/**
 * Cleanup old processed notifications (runs daily)
 */
exports.cleanupNotificationQueue = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      const oneDayAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 24 * 60 * 60 * 1000)
      );

      const oldNotifications = await db
        .collection('notification_queue')
        .where('processed', '==', true)
        .where('created_at', '<', oneDayAgo)
        .limit(500)
        .get();

      const batch = db.batch();
      oldNotifications.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Cleaned up ${oldNotifications.size} old notifications`);

      return null;
    } catch (error) {
      console.error('Error cleaning up notifications:', error);
      return null;
    }
  });
