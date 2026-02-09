import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data_provider/database_config.dart';

/// Enum representing message types
enum MessageType {
  text,
  image,
  file;

  String get value {
    switch (this) {
      case MessageType.text:
        return DatabaseConfig.messageTypeText;
      case MessageType.image:
        return DatabaseConfig.messageTypeImage;
      case MessageType.file:
        return DatabaseConfig.messageTypeFile;
    }
  }

  static MessageType fromString(String? type) {
    switch (type) {
      case DatabaseConfig.messageTypeImage:
        return MessageType.image;
      case DatabaseConfig.messageTypeFile:
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}

/// Model representing a chat message
class MessageModel extends Equatable {
  final String messageId;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;

  const MessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
  });

  /// Check if the message is sent by a specific user
  bool isSentBy(String userId) => senderId == userId;

  /// Get formatted time for display
  String get formattedTime {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get formatted date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  /// Create a copy with modified fields
  MessageModel copyWith({
    String? messageId,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? messageType,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseConfig.fieldMessageId: messageId,
      DatabaseConfig.fieldChatRoomId: chatRoomId,
      DatabaseConfig.fieldSenderId: senderId,
      DatabaseConfig.fieldReceiverId: receiverId,
      DatabaseConfig.fieldContent: content,
      DatabaseConfig.fieldMessageType: messageType.value,
      DatabaseConfig.fieldTimestamp: Timestamp.fromDate(timestamp),
      DatabaseConfig.fieldIsRead: isRead,
      DatabaseConfig.fieldReadAt: readAt != null
          ? Timestamp.fromDate(readAt!)
          : null,
    };
  }

  /// Create from Firebase Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime timestampDate;
    final timestampValue = map[DatabaseConfig.fieldTimestamp];
    if (timestampValue is Timestamp) {
      timestampDate = timestampValue.toDate();
    } else if (timestampValue is String) {
      timestampDate = DateTime.tryParse(timestampValue) ?? DateTime.now();
    } else {
      timestampDate = DateTime.now();
    }

    DateTime? readAtDate;
    final readAtValue = map[DatabaseConfig.fieldReadAt];
    if (readAtValue != null) {
      if (readAtValue is Timestamp) {
        readAtDate = readAtValue.toDate();
      } else if (readAtValue is String) {
        readAtDate = DateTime.tryParse(readAtValue);
      }
    }

    return MessageModel(
      messageId: map[DatabaseConfig.fieldMessageId] as String? ?? '',
      chatRoomId: map[DatabaseConfig.fieldChatRoomId] as String? ?? '',
      senderId: map[DatabaseConfig.fieldSenderId] as String? ?? '',
      receiverId: map[DatabaseConfig.fieldReceiverId] as String? ?? '',
      content: map[DatabaseConfig.fieldContent] as String? ?? '',
      messageType: MessageType.fromString(
        map[DatabaseConfig.fieldMessageType] as String?,
      ),
      timestamp: timestampDate,
      isRead: map[DatabaseConfig.fieldIsRead] as bool? ?? false,
      readAt: readAtDate,
    );
  }

  /// Create from Firebase DocumentSnapshot
  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return MessageModel.fromMap({
      ...data,
      DatabaseConfig.fieldMessageId: doc.id,
    });
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    messageId,
    chatRoomId,
    senderId,
    receiverId,
    content,
    messageType,
    timestamp,
    isRead,
    readAt,
  ];
}
