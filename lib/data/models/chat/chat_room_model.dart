import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data_provider/database_config.dart';
import 'chat_user_model.dart';

/// Model representing a chat room between two users
class ChatRoomModel extends Equatable {
  final String chatRoomId;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastMessageSenderId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, int> unreadCounts;

  // Additional data fetched for display
  final ChatUserModel? otherUser;
  final bool isOtherUserTyping;

  const ChatRoomModel({
    required this.chatRoomId,
    required this.participantIds,
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastMessageSenderId = '',
    required this.createdAt,
    this.updatedAt,
    this.unreadCounts = const {},
    this.otherUser,
    this.isOtherUserTyping = false,
  });

  /// Get the other participant's ID (for 1-on-1 chats)
  String getOtherParticipantId(String currentUserId) {
    if (participantIds.isEmpty) return '';
    if (participantIds.length == 1) return participantIds.first;
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Check if there is a last message
  bool get hasLastMessage => lastMessage.trim().isNotEmpty;

  /// Get formatted last message time
  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      lastMessageTime!.year,
      lastMessageTime!.month,
      lastMessageTime!.day,
    );

    if (messageDate == today) {
      // Today: show time
      final hour = lastMessageTime!.hour;
      final minute = lastMessageTime!.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(lastMessageTime!).inDays < 7) {
      // Within a week: show day name
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[lastMessageTime!.weekday % 7];
    } else {
      // Older: show date
      return '${lastMessageTime!.day}/${lastMessageTime!.month}/${lastMessageTime!.year}';
    }
  }

  /// Generate a chat room ID from two user IDs (consistent ordering)
  static String generateChatRoomId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Create a copy with modified fields
  ChatRoomModel copyWith({
    String? chatRoomId,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? unreadCounts,
    ChatUserModel? otherUser,
    bool? isOtherUserTyping,
  }) {
    return ChatRoomModel(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      otherUser: otherUser ?? this.otherUser,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
    );
  }

  /// Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseConfig.fieldChatRoomId: chatRoomId,
      DatabaseConfig.fieldParticipantIds: participantIds,
      DatabaseConfig.fieldLastMessage: lastMessage,
      DatabaseConfig.fieldLastMessageTime: lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      DatabaseConfig.fieldLastMessageSenderId: lastMessageSenderId,
      DatabaseConfig.fieldCreatedAt: Timestamp.fromDate(createdAt),
      DatabaseConfig.fieldUpdatedAt: updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      DatabaseConfig.fieldUnreadCount: unreadCounts,
    };
  }

  /// Create from Firebase Map
  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    // Parse participant IDs
    List<String> participants = [];
    final participantsValue = map[DatabaseConfig.fieldParticipantIds];
    if (participantsValue is List) {
      participants = participantsValue
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Parse last message time
    DateTime? lastMsgTime;
    final lastMsgTimeValue = map[DatabaseConfig.fieldLastMessageTime];
    if (lastMsgTimeValue is Timestamp) {
      lastMsgTime = lastMsgTimeValue.toDate();
    } else if (lastMsgTimeValue is String) {
      lastMsgTime = DateTime.tryParse(lastMsgTimeValue);
    }

    // Parse created at
    DateTime createdAtDate;
    final createdAtValue = map[DatabaseConfig.fieldCreatedAt];
    if (createdAtValue is Timestamp) {
      createdAtDate = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAtDate = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    // Parse updated at
    DateTime? updatedAtDate;
    final updatedAtValue = map[DatabaseConfig.fieldUpdatedAt];
    if (updatedAtValue is Timestamp) {
      updatedAtDate = updatedAtValue.toDate();
    } else if (updatedAtValue is String) {
      updatedAtDate = DateTime.tryParse(updatedAtValue);
    }

    // Parse unread counts
    Map<String, int> unreadMap = {};
    final unreadValue = map[DatabaseConfig.fieldUnreadCount];
    if (unreadValue is Map) {
      unreadValue.forEach((key, value) {
        if (key is String && value is int) {
          unreadMap[key] = value;
        } else if (key is String && value is num) {
          unreadMap[key] = value.toInt();
        }
      });
    }

    return ChatRoomModel(
      chatRoomId: map[DatabaseConfig.fieldChatRoomId] as String? ?? '',
      participantIds: participants,
      lastMessage: map[DatabaseConfig.fieldLastMessage] as String? ?? '',
      lastMessageTime: lastMsgTime,
      lastMessageSenderId:
          map[DatabaseConfig.fieldLastMessageSenderId] as String? ?? '',
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
      unreadCounts: unreadMap,
    );
  }

  /// Create from Firebase DocumentSnapshot
  factory ChatRoomModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ChatRoomModel.fromMap({
      ...data,
      DatabaseConfig.fieldChatRoomId: doc.id,
    });
  }

  String toJson() => json.encode(toMap());

  factory ChatRoomModel.fromJson(String source) =>
      ChatRoomModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    chatRoomId,
    participantIds,
    lastMessage,
    lastMessageTime,
    lastMessageSenderId,
    createdAt,
    updatedAt,
    unreadCounts,
    otherUser,
    isOtherUserTyping,
  ];
}
