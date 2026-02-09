import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/data_provider/database_config.dart';
import '../../data/models/chat/chat_room_model.dart';
import '../../data/models/chat/chat_user_model.dart';
import '../../data/models/chat/message_model.dart';
import '../../data/models/chat/typing_status_model.dart';

/// Service class for all Firebase chat operations
class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Typing debounce timer
  Timer? _typingTimer;
  static const Duration _typingTimeout = Duration(seconds: 3);

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER STREAMS ====================

  /// Stream all users (excluding current user) for chat list
  Stream<List<ChatUserModel>> streamAllUsers() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection(DatabaseConfig.userCollection)
        .where(DatabaseConfig.fieldStatus, isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.id != userId)
              .map((doc) => ChatUserModel.fromDocument(doc))
              .toList();
        });
  }

  /// Stream a single user's data
  Stream<ChatUserModel?> streamUser(String userId) {
    if (userId.isEmpty) return Stream.value(null);

    return _db
        .collection(DatabaseConfig.userCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return ChatUserModel.fromDocument(snapshot);
        });
  }

  /// Get user by ID (one-time fetch)
  Future<ChatUserModel?> getUserById(String userId) async {
    if (userId.isEmpty) return null;

    try {
      final doc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return ChatUserModel.fromDocument(doc);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  // ==================== CHAT ROOM OPERATIONS ====================

  /// Stream chat rooms for current user
  Stream<List<ChatRoomModel>> streamChatRooms() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    // Note: If you have the composite index created, you can re-enable orderBy here
    // for better performance. Without the index, we sort client-side.
    return _db
        .collection(DatabaseConfig.chatRoomsCollection)
        .where(DatabaseConfig.fieldParticipantIds, arrayContains: userId)
        // Uncomment the next line after creating the composite index in Firebase Console:
        // .orderBy(DatabaseConfig.fieldLastMessageTime, descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final chatRooms = <ChatRoomModel>[];

          for (final doc in snapshot.docs) {
            var chatRoom = ChatRoomModel.fromDocument(doc);

            // Fetch the other user's data
            final otherUserId = chatRoom.getOtherParticipantId(userId);
            if (otherUserId.isNotEmpty) {
              final otherUser = await getUserById(otherUserId);
              if (otherUser != null) {
                chatRoom = chatRoom.copyWith(otherUser: otherUser);
              }
            }

            chatRooms.add(chatRoom);
          }

          // Sort client-side by last message time (most recent first)
          // This can be removed once the Firebase composite index is created
          chatRooms.sort((a, b) {
            final aTime = a.lastMessageTime;
            final bTime = b.lastMessageTime;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Descending order
          });

          return chatRooms;
        });
  }

  /// Stream chat rooms with typing status
  Stream<List<ChatRoomModel>> streamChatRoomsWithTyping() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return streamChatRooms().asyncMap((chatRooms) async {
      final updatedRooms = <ChatRoomModel>[];

      for (final room in chatRooms) {
        final otherUserId = room.getOtherParticipantId(userId);
        // Check typing status
        final typingStatus = await getTypingStatus(
          room.chatRoomId,
          otherUserId,
        );
        final isTyping = typingStatus?.isRecentlyTyping ?? false;

        updatedRooms.add(room.copyWith(isOtherUserTyping: isTyping));
      }

      return updatedRooms;
    });
  }

  /// Create or get existing chat room between two users
  Future<ChatRoomModel?> getOrCreateChatRoom(String otherUserId) async {
    final userId = currentUserId;
    if (userId == null || otherUserId.isEmpty) return null;

    try {
      final chatRoomId = ChatRoomModel.generateChatRoomId(userId, otherUserId);

      // Check if chat room exists
      final existingDoc = await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .get();

      if (existingDoc.exists) {
        var chatRoom = ChatRoomModel.fromDocument(existingDoc);
        // Fetch other user data
        final otherUser = await getUserById(otherUserId);
        if (otherUser != null) {
          chatRoom = chatRoom.copyWith(otherUser: otherUser);
        }
        return chatRoom;
      }

      // Create new chat room
      final newChatRoom = ChatRoomModel(
        chatRoomId: chatRoomId,
        participantIds: [userId, otherUserId],
        lastMessage: '',
        lastMessageTime: null,
        lastMessageSenderId: '',
        createdAt: DateTime.now(),
        unreadCounts: {userId: 0, otherUserId: 0},
      );

      await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .set(newChatRoom.toMap());

      // Fetch other user data
      final otherUser = await getUserById(otherUserId);
      return newChatRoom.copyWith(otherUser: otherUser);
    } catch (e) {
      debugPrint('Error creating chat room: $e');
      return null;
    }
  }

  /// Update chat room with last message info
  Future<void> updateChatRoomLastMessage({
    required String chatRoomId,
    required String message,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .update({
            DatabaseConfig.fieldLastMessage: message,
            DatabaseConfig.fieldLastMessageTime: FieldValue.serverTimestamp(),
            DatabaseConfig.fieldLastMessageSenderId: senderId,
            DatabaseConfig.fieldUpdatedAt: FieldValue.serverTimestamp(),
            // Increment unread count for receiver
            '${DatabaseConfig.fieldUnreadCount}.$receiverId':
                FieldValue.increment(1),
          });
    } catch (e) {
      debugPrint('Error updating chat room: $e');
    }
  }

  /// Reset unread count for current user in a chat room
  Future<void> resetUnreadCount(String chatRoomId) async {
    final userId = currentUserId;
    if (userId == null || chatRoomId.isEmpty) return;

    try {
      await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .update({'${DatabaseConfig.fieldUnreadCount}.$userId': 0});
    } catch (e) {
      debugPrint('Error resetting unread count: $e');
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Stream messages for a chat room
  Stream<List<MessageModel>> streamMessages(String chatRoomId) {
    if (chatRoomId.isEmpty) return Stream.value([]);

    return _db
        .collection(DatabaseConfig.chatRoomsCollection)
        .doc(chatRoomId)
        .collection(DatabaseConfig.messagesCollection)
        .orderBy(DatabaseConfig.fieldTimestamp, descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromDocument(doc))
              .toList();
        });
  }

  /// Send a message
  Future<MessageModel?> sendMessage({
    required String chatRoomId,
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
    String? senderName,
  }) async {
    final userId = currentUserId;
    if (userId == null || chatRoomId.isEmpty || content.trim().isEmpty) {
      return null;
    }

    try {
      // Create message document reference
      final messageRef = _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .collection(DatabaseConfig.messagesCollection)
          .doc();

      final message = MessageModel(
        messageId: messageRef.id,
        chatRoomId: chatRoomId,
        senderId: userId,
        receiverId: receiverId,
        content: content.trim(),
        messageType: messageType,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Send message
      await messageRef.set(message.toMap());
      debugPrint('✅ Message saved to Firestore: ${message.messageId}');

      // Update chat room with last message
      await updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        message: content.trim(),
        senderId: userId,
        receiverId: receiverId,
      );

      // Stop typing indicator
      await setTypingStatus(chatRoomId: chatRoomId, isTyping: false);

      // Send push notification to receiver
      await _sendPushNotification(
        receiverId: receiverId,
        senderId: userId,
        senderName: senderName,
        message: content.trim(),
        chatRoomId: chatRoomId,
      );

      return message;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  /// Send push notification to receiver
  Future<void> _sendPushNotification({
    required String receiverId,
    required String senderId,
    String? senderName,
    required String message,
    required String chatRoomId,
  }) async {
    try {
      // Get sender's name if not provided
      String name = senderName ?? 'Someone';
      if (senderName == null || senderName.isEmpty) {
        final senderDoc = await _db
            .collection(DatabaseConfig.userCollection)
            .doc(senderId)
            .get();
        if (senderDoc.exists) {
          final data = senderDoc.data();
          final firstName = data?['first_name'] as String? ?? '';
          final lastName = data?['last_name'] as String? ?? '';
          name = '$firstName $lastName'.trim();
          if (name.isEmpty) {
            name = data?['email'] as String? ?? 'Someone';
          }
        }
      }

      // Get receiver's FCM token
      final receiverDoc = await _db
          .collection(DatabaseConfig.userCollection)
          .doc(receiverId)
          .get();

      if (!receiverDoc.exists) {
        debugPrint('⚠️ Receiver document not found for notification');
        return;
      }

      final receiverData = receiverDoc.data();
      final fcmToken =
          receiverData?[DatabaseConfig.fieldDeviceToken] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('⚠️ Receiver has no FCM token - cannot send notification');
        return;
      }

      debugPrint(
        '📱 Receiver FCM token found: ${fcmToken.substring(0, 20)}...',
      );

      // Queue notification for Cloud Function processing
      // (This is more secure than sending directly from client)
      await _db.collection('notification_queue').add({
        'receiver_id': receiverId,
        'receiver_token': fcmToken,
        'sender_id': senderId,
        'sender_name': name,
        'message': message.length > 100
            ? '${message.substring(0, 97)}...'
            : message,
        'chat_room_id': chatRoomId,
        'type': 'chat_message',
        'created_at': FieldValue.serverTimestamp(),
        'processed': false,
      });

      debugPrint('✅ Notification queued for processing');
    } catch (e) {
      debugPrint('⚠️ Error queueing notification: $e');
      // Don't fail the message send if notification fails
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final userId = currentUserId;
    if (userId == null || chatRoomId.isEmpty) return;

    try {
      // Get unread messages sent to current user
      final unreadMessages = await _db
          .collection(DatabaseConfig.chatRoomsCollection)
          .doc(chatRoomId)
          .collection(DatabaseConfig.messagesCollection)
          .where(DatabaseConfig.fieldReceiverId, isEqualTo: userId)
          .where(DatabaseConfig.fieldIsRead, isEqualTo: false)
          .get();

      // Batch update
      final batch = _db.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          DatabaseConfig.fieldIsRead: true,
          DatabaseConfig.fieldReadAt: FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Reset unread count
      await resetUnreadCount(chatRoomId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // ==================== TYPING INDICATOR ====================

  /// Set typing status with debounce
  Future<void> setTypingStatus({
    required String chatRoomId,
    required bool isTyping,
  }) async {
    final userId = currentUserId;
    if (userId == null || chatRoomId.isEmpty) return;

    // Cancel previous timer
    _typingTimer?.cancel();

    try {
      final typingDocId = '${chatRoomId}_$userId';

      if (isTyping) {
        // Set typing to true
        await _db
            .collection(DatabaseConfig.typingStatusCollection)
            .doc(typingDocId)
            .set({
              DatabaseConfig.fieldChatRoomId: chatRoomId,
              DatabaseConfig.fieldTypingUserId: userId,
              DatabaseConfig.fieldIsTyping: true,
              DatabaseConfig.fieldTypingTimestamp: FieldValue.serverTimestamp(),
            });

        // Auto-stop typing after timeout
        _typingTimer = Timer(_typingTimeout, () {
          setTypingStatus(chatRoomId: chatRoomId, isTyping: false);
        });
      } else {
        // Set typing to false
        await _db
            .collection(DatabaseConfig.typingStatusCollection)
            .doc(typingDocId)
            .set({
              DatabaseConfig.fieldChatRoomId: chatRoomId,
              DatabaseConfig.fieldTypingUserId: userId,
              DatabaseConfig.fieldIsTyping: false,
              DatabaseConfig.fieldTypingTimestamp: FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error setting typing status: $e');
    }
  }

  /// Stream typing status for a user in a chat room
  Stream<TypingStatusModel?> streamTypingStatus(
    String chatRoomId,
    String otherUserId,
  ) {
    if (chatRoomId.isEmpty || otherUserId.isEmpty) {
      return Stream.value(null);
    }

    final typingDocId = '${chatRoomId}_$otherUserId';

    return _db
        .collection(DatabaseConfig.typingStatusCollection)
        .doc(typingDocId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          final status = TypingStatusModel.fromDocument(snapshot);
          // Only return if recently typing
          return status.isRecentlyTyping ? status : null;
        });
  }

  /// Get typing status (one-time fetch)
  Future<TypingStatusModel?> getTypingStatus(
    String chatRoomId,
    String otherUserId,
  ) async {
    if (chatRoomId.isEmpty || otherUserId.isEmpty) return null;

    try {
      final typingDocId = '${chatRoomId}_$otherUserId';
      final doc = await _db
          .collection(DatabaseConfig.typingStatusCollection)
          .doc(typingDocId)
          .get();

      if (!doc.exists) return null;
      return TypingStatusModel.fromDocument(doc);
    } catch (e) {
      debugPrint('Error getting typing status: $e');
      return null;
    }
  }

  // ==================== USER ONLINE STATUS ====================

  /// Update user online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      await _db.collection(DatabaseConfig.userCollection).doc(userId).update({
        DatabaseConfig.fieldIsOnline: isOnline,
        DatabaseConfig.fieldLastSeen: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  /// Clean up typing timer
  void dispose() {
    _typingTimer?.cancel();
  }
}
