import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data_provider/database_config.dart';

/// Model representing typing status for a user in a chat room
class TypingStatusModel extends Equatable {
  final String chatRoomId;
  final String typingUserId;
  final bool isTyping;
  final DateTime? typingTimestamp;

  const TypingStatusModel({
    required this.chatRoomId,
    required this.typingUserId,
    this.isTyping = false,
    this.typingTimestamp,
  });

  /// Check if typing status is recent (within last 10 seconds)
  bool get isRecentlyTyping {
    if (!isTyping || typingTimestamp == null) return false;
    final difference = DateTime.now().difference(typingTimestamp!);
    // Consider typing status stale after 10 seconds
    return difference.inSeconds < 10;
  }

  /// Create a copy with modified fields
  TypingStatusModel copyWith({
    String? chatRoomId,
    String? typingUserId,
    bool? isTyping,
    DateTime? typingTimestamp,
  }) {
    return TypingStatusModel(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      typingUserId: typingUserId ?? this.typingUserId,
      isTyping: isTyping ?? this.isTyping,
      typingTimestamp: typingTimestamp ?? this.typingTimestamp,
    );
  }

  /// Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DatabaseConfig.fieldChatRoomId: chatRoomId,
      DatabaseConfig.fieldTypingUserId: typingUserId,
      DatabaseConfig.fieldIsTyping: isTyping,
      DatabaseConfig.fieldTypingTimestamp: FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firebase Map
  factory TypingStatusModel.fromMap(Map<String, dynamic> map) {
    DateTime? timestamp;
    final timestampValue = map[DatabaseConfig.fieldTypingTimestamp];
    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is String) {
      timestamp = DateTime.tryParse(timestampValue);
    }

    return TypingStatusModel(
      chatRoomId: map[DatabaseConfig.fieldChatRoomId] as String? ?? '',
      typingUserId: map[DatabaseConfig.fieldTypingUserId] as String? ?? '',
      isTyping: map[DatabaseConfig.fieldIsTyping] as bool? ?? false,
      typingTimestamp: timestamp,
    );
  }

  /// Create from Firebase DocumentSnapshot
  factory TypingStatusModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return TypingStatusModel.fromMap(data);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
    chatRoomId,
    typingUserId,
    isTyping,
    typingTimestamp,
  ];
}
