part of 'chat_list_cubit.dart';

/// Base state for chat list
sealed class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

/// Loading state
final class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

/// Loaded state with chat rooms and users
final class ChatListLoaded extends ChatListState {
  final List<ChatRoomModel> chatRooms;
  final List<ChatUserModel> allUsers;

  const ChatListLoaded({required this.chatRooms, required this.allUsers});

  /// Get users who don't have an existing chat room
  List<ChatUserModel> get usersWithoutChats {
    final chatUserIds = chatRooms.expand((room) => room.participantIds).toSet();

    return allUsers.where((user) => !chatUserIds.contains(user.id)).toList();
  }

  /// Check if there are any chats
  bool get hasChats => chatRooms.isNotEmpty;

  /// Check if there are any users available for new chats
  bool get hasAvailableUsers => usersWithoutChats.isNotEmpty;

  @override
  List<Object?> get props => [chatRooms, allUsers];
}

/// Error state
final class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
