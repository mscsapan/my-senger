import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/chat_service.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/chat_user_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../../../data/models/chat/typing_status_model.dart';
import '../../repository/conversation_repository.dart';

part 'conversation_state.dart';

/// Cubit for managing the conversation screen state
class ConversationCubit extends Cubit<ConversationState> {
  final ConversationRepository _repository;
  ConversationCubit({required ConversationRepository repository }) : _repository = repository,super(const ConversationInitial());

  final ChatService _chatService = ChatService();

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<TypingStatusModel?>? _typingSubscription;
  StreamSubscription<ChatUserModel?>? _otherUserSubscription;

  // Current conversation data
  ChatRoomModel? _currentChatRoom;
  ChatUserModel? _otherUser;
  List<MessageModel> _messages = [];
  bool _isOtherUserTyping = false;
  String _currentMessage = '';

  // Typing debounce
  Timer? _typingDebounceTimer;
  bool _isCurrentlyTyping = false;

  /// Initialize conversation with a chat room
  Future<void> initConversation({
    required String chatRoomId,
    required String otherUserId,
    ChatRoomModel? existingChatRoom,
    ChatUserModel? existingOtherUser,
  }) async {

    emit(const ConversationLoading());

    // Set initial data if provided
    _currentChatRoom = existingChatRoom;
    _otherUser = existingOtherUser;

    // Start listening to messages
    _setupMessageListener(chatRoomId);

    // Start listening to other user's typing status
    _setupTypingListener(chatRoomId, otherUserId);

    // Start listening to other user's data (for online status, etc.)
    _setupOtherUserListener(otherUserId);

    // Mark messages as read
    await _chatService.markMessagesAsRead(chatRoomId);
  }




  /// Setup message stream listener
  void _setupMessageListener(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService
        .streamMessages(chatRoomId)
        .listen(
          (messages) {
            _messages = messages;
            _emitLoadedState();

            // Mark new messages as read
            _chatService.markMessagesAsRead(chatRoomId);
          },
          onError: (error) {
            debugPrint('Error loading messages: $error');
            emit(ConversationError(error.toString()));
          },
        );
  }

  /// Setup typing status listener
  void _setupTypingListener(String chatRoomId, String otherUserId) {
    _typingSubscription?.cancel();
    _typingSubscription = _chatService
        .streamTypingStatus(chatRoomId, otherUserId)
        .listen(
          (typingStatus) {
            _isOtherUserTyping = typingStatus?.isRecentlyTyping ?? false;
            _emitLoadedState();
          },
          onError: (error) {
            debugPrint('Error listening to typing status: $error');
          },
        );
  }

  /// Setup other user data listener
  void _setupOtherUserListener(String otherUserId) {
    _otherUserSubscription?.cancel();
    _otherUserSubscription = _chatService
        .streamUser(otherUserId)
        .listen(
          (user) {
            if (user != null) {
              _otherUser = user;
              _emitLoadedState();
            }
          },
          onError: (error) {
            debugPrint('Error listening to other user: $error');
          },
        );
  }

  /// Emit loaded state with current data
  void _emitLoadedState() {
    emit(
      ConversationLoaded(
        messages: List.unmodifiable(_messages),
        otherUser: _otherUser,
        chatRoom: _currentChatRoom,
        isOtherUserTyping: _isOtherUserTyping,
        currentMessage: _currentMessage,
      ),
    );
  }

  /// Update current message (for typing indicator)
  void onMessageChanged(String message) {
    _currentMessage = message;

    final chatRoomId = _currentChatRoom?.chatRoomId;
    if (chatRoomId == null) return;

    // Debounced typing indicator
    if (message.trim().isNotEmpty && !_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      _chatService.setTypingStatus(chatRoomId: chatRoomId, isTyping: true);
    }

    // Reset debounce timer
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
      if (_isCurrentlyTyping) {
        _isCurrentlyTyping = false;
        _chatService.setTypingStatus(chatRoomId: chatRoomId, isTyping: false);
      }
    });

    _emitLoadedState();
  }

  /// Send a message
  Future<bool> sendMessage(String content) async {
    final chatRoomId = _currentChatRoom?.chatRoomId;
    final receiverId = _otherUser?.id;

    if (chatRoomId == null || receiverId == null || content.trim().isEmpty) {
      return false;
    }

    try {
      // Stop typing indicator immediately
      _isCurrentlyTyping = false;
      _typingDebounceTimer?.cancel();
      await _chatService.setTypingStatus(
        chatRoomId: chatRoomId,
        isTyping: false,
      );

      // Send message
      final message = await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        content: content,
      );

      // Clear current message
      _currentMessage = '';
      _emitLoadedState();

      return message != null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  /// Set the chat room data
  void setChatRoom(ChatRoomModel chatRoom) {
    _currentChatRoom = chatRoom;
    _otherUser = chatRoom.otherUser;
    _emitLoadedState();
  }

  /// Get current user ID
  String? get currentUserId => _chatService.currentUserId;

  /// Check if message is from current user
  bool isFromCurrentUser(MessageModel message) {
    return message.senderId == currentUserId;
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _otherUserSubscription?.cancel();
    _typingDebounceTimer?.cancel();

    // Stop typing indicator on close
    final chatRoomId = _currentChatRoom?.chatRoomId;
    if (chatRoomId != null) {
      _chatService.setTypingStatus(chatRoomId: chatRoomId, isTyping: false);
    }

    return super.close();
  }
}
