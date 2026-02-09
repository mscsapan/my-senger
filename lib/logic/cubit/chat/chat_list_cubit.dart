import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/chat_service.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/chat_user_model.dart';
import '../../../data/models/chat/typing_status_model.dart';

part 'chat_list_state.dart';

/// Cubit for managing the chat list screen state
class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit() : super(const ChatListInitial());

  final ChatService _chatService = ChatService();

  StreamSubscription<List<ChatRoomModel>>? _chatRoomsSubscription;
  StreamSubscription<List<ChatUserModel>>? _usersSubscription;
  final Map<String, StreamSubscription<TypingStatusModel?>>
  _typingSubscriptions = {};

  // Store current data for combining with typing updates
  List<ChatRoomModel> _currentChatRooms = [];
  List<ChatUserModel> _allUsers = [];

  /// Initialize and start listening to chat rooms
  void loadChatRooms() {
    emit(const ChatListLoading());

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _chatService.streamChatRooms().listen(
      (chatRooms) {
        _currentChatRooms = chatRooms;
        _setupTypingListeners(chatRooms);
        _emitLoadedState();
      },
      onError: (error) {
        debugPrint('Error loading chat rooms: $error');
        emit(ChatListError(error.toString()));
      },
    );
  }

  /// Load all users for starting new chats
  void loadAllUsers() {
    _usersSubscription?.cancel();
    _usersSubscription = _chatService.streamAllUsers().listen(
      (users) {
        _allUsers = users;
        _emitLoadedState();
      },
      onError: (error) {
        debugPrint('Error loading users: $error');
      },
    );
  }

  /// Setup typing status listeners for each chat room
  void _setupTypingListeners(List<ChatRoomModel> chatRooms) {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    // Clear old subscriptions
    for (final sub in _typingSubscriptions.values) {
      sub.cancel();
    }
    _typingSubscriptions.clear();

    // Setup new subscriptions
    for (final room in chatRooms) {
      final otherUserId = room.getOtherParticipantId(currentUserId);
      if (otherUserId.isEmpty) continue;

      _typingSubscriptions[room.chatRoomId] = _chatService
          .streamTypingStatus(room.chatRoomId, otherUserId)
          .listen(
            (typingStatus) {
              _updateTypingStatus(room.chatRoomId, typingStatus);
            },
            onError: (error) {
              debugPrint('Error listening to typing: $error');
            },
          );
    }
  }

  /// Update typing status for a specific chat room
  void _updateTypingStatus(String chatRoomId, TypingStatusModel? typingStatus) {
    final isTyping = typingStatus?.isRecentlyTyping ?? false;

    // Update the chat room in our list
    _currentChatRooms = _currentChatRooms.map((room) {
      if (room.chatRoomId == chatRoomId) {
        return room.copyWith(isOtherUserTyping: isTyping);
      }
      return room;
    }).toList();

    _emitLoadedState();
  }

  /// Emit the loaded state with current data
  void _emitLoadedState() {
    emit(
      ChatListLoaded(
        chatRooms: List.unmodifiable(_currentChatRooms),
        allUsers: List.unmodifiable(_allUsers),
      ),
    );
  }

  /// Create or navigate to chat with a user
  Future<ChatRoomModel?> startChatWithUser(String otherUserId) async {
    try {
      return await _chatService.getOrCreateChatRoom(otherUserId);
    } catch (e) {
      debugPrint('Error starting chat: $e');
      return null;
    }
  }

  /// Get current user ID
  String? get currentUserId => _chatService.currentUserId;

  /// Refresh chat rooms
  void refresh() {
    loadChatRooms();
    loadAllUsers();
  }

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    _usersSubscription?.cancel();
    for (final sub in _typingSubscriptions.values) {
      sub.cancel();
    }
    _typingSubscriptions.clear();
    return super.close();
  }
}
