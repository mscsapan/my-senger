/// Firebase database collection and document configurations
class DatabaseConfig {
  // Collections
  static const String userCollection = 'users';
  static const String chatRoomsCollection = 'chat_rooms';
  static const String messagesCollection = 'messages';
  static const String typingStatusCollection = 'typing_status';
  static const String chatPageCollection = 'chat_page';

  // Subcollections
  static const String participantsSubcollection = 'participants';

  // Field names for users
  static const String fieldUserId = 'id';
  static const String fieldFirstName = 'first_name';
  static const String fieldLastName = 'last_name';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldImage = 'image';
  static const String fieldDeviceToken = 'device_token';
  static const String fieldStatus = 'status';
  static const String fieldIsOnline = 'is_online';
  static const String fieldLastSeen = 'last_seen';

  // Field names for chat rooms
  static const String fieldChatRoomId = 'chat_room_id';
  static const String fieldParticipantIds = 'participant_ids';
  static const String fieldLastMessage = 'last_message';
  static const String fieldLastMessageTime = 'last_message_time';
  static const String fieldLastMessageSenderId = 'last_message_sender_id';
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
  static const String fieldUnreadCount = 'unread_count';

  // Field names for messages
  static const String fieldMessageId = 'message_id';
  static const String fieldSenderId = 'sender_id';
  static const String fieldReceiverId = 'receiver_id';
  static const String fieldContent = 'content';
  static const String fieldMessageType = 'message_type';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldIsRead = 'is_read';
  static const String fieldReadAt = 'read_at';

  // Field names for typing status
  static const String fieldIsTyping = 'is_typing';
  static const String fieldTypingUserId = 'typing_user_id';
  static const String fieldTypingTimestamp = 'typing_timestamp';

  // Message types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeFile = 'file';
}
