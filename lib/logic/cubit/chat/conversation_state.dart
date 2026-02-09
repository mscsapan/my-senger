part of 'conversation_cubit.dart';

/// Base state for conversation
sealed class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

/// Loading state
final class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

/// Loaded state with messages and user data
final class ConversationLoaded extends ConversationState {
  final List<MessageModel> messages;
  final ChatUserModel? otherUser;
  final ChatRoomModel? chatRoom;
  final bool isOtherUserTyping;
  final String currentMessage;

  const ConversationLoaded({
    required this.messages,
    this.otherUser,
    this.chatRoom,
    this.isOtherUserTyping = false,
    this.currentMessage = '',
  });

  /// Check if there are any messages
  bool get hasMessages => messages.isNotEmpty;

  /// Check if the send button should be enabled
  bool get canSendMessage => currentMessage.trim().isNotEmpty;

  /// Get the other user's display name
  String get otherUserName => otherUser?.fullName ?? 'Unknown';

  /// Get the other user's profile image
  String get otherUserImage => otherUser?.image ?? '';

  /// Check if other user is online
  bool get isOtherUserOnline => otherUser?.isOnline ?? false;

  /// Group messages by date
  Map<String, List<MessageModel>> get messagesByDate {
    final grouped = <String, List<MessageModel>>{};

    for (final message in messages) {
      final dateKey = message.formattedDate;
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]?.add(message);
    }

    return grouped;
  }

  @override
  List<Object?> get props => [
    messages,
    otherUser,
    chatRoom,
    isOtherUserTyping,
    currentMessage,
  ];
}

/// Error state
final class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Message sending state
final class ConversationSending extends ConversationState {
  const ConversationSending();
}
