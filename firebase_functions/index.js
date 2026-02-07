/**
 * Firebase Cloud Functions for Chat Notifications
 * 
 * This file contains Cloud Functions that send push notifications
 * when new messages are created in chat rooms.
 * 
 * Deploy these functions to Firebase:
 * $ cd functions
 * $ npm install
 * $ firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Cloud Function triggered when a new message is created
 * Sends a push notification to the receiver if they're not in the active chat
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
      
      // Get sender's info for the notification
      const senderDoc = await db.collection('users').doc(senderId).get();
      if (!senderDoc.exists) {
        console.log('Sender document not found');
        return null;
      }
      
      const senderData = senderDoc.data();
      const senderName = `${senderData.first_name || ''} ${senderData.last_name || ''}`.trim() 
        || senderData.email 
        || 'Someone';
      
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
      
      // Prepare message content preview
      let messagePreview = content;
      if (messageType === 'image') {
        messagePreview = '📷 Sent a photo';
      } else if (messageType === 'file') {
        messagePreview = '📎 Sent a file';
      } else if (content.length > 100) {
        messagePreview = content.substring(0, 97) + '...';
      }
      
      // Prepare notification payload
      const notificationPayload = {
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
            defaultSound: true,
            defaultVibrateTimings: true,
          },
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
      const response = await messaging.send(notificationPayload);
      console.log('Notification sent successfully:', response);
      
      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });

/**
 * Cloud Function to update user's online status
 * Can be triggered by client or scheduled function
 */
exports.updateUserOnlineStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }
  
  const userId = context.auth.uid;
  const isOnline = data.isOnline || false;
  
  try {
    await db.collection('users').doc(userId).update({
      is_online: isOnline,
      last_seen: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { success: true };
  } catch (error) {
    console.error('Error updating online status:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update status');
  }
});

/**
 * Scheduled function to clean up stale typing indicators
 * Runs every 5 minutes
 */
exports.cleanupTypingIndicators = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    try {
      const fiveMinutesAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 5 * 60 * 1000)
      );
      
      const staleTypingDocs = await db
        .collection('typing_status')
        .where('is_typing', '==', true)
        .where('typing_timestamp', '<', fiveMinutesAgo)
        .get();
      
      const batch = db.batch();
      
      staleTypingDocs.forEach((doc) => {
        batch.update(doc.ref, { is_typing: false });
      });
      
      await batch.commit();
      console.log(`Cleaned up ${staleTypingDocs.size} stale typing indicators`);
      
      return null;
    } catch (error) {
      console.error('Error cleaning up typing indicators:', error);
      return null;
    }
  });

/**
 * Function to send notification when mentioned in a group (future feature)
 */
exports.sendMentionNotification = functions.firestore
  .document('chat_rooms/{chatRoomId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    // Implementation for @mentions feature
    // This is a placeholder for future group chat functionality
    return null;
  });
