# Real-Time Chat Feature Implementation

This document describes the real-time chat feature implementation for the My Senger application.

## Overview

The chat feature provides:

- ✅ Real-time instant messaging using Firebase Firestore
- ✅ Chat list screen with user profiles, last messages, and unread counts
- ✅ Real-time typing indicators (visible in both chat list and conversation)
- ✅ Push notifications for incoming messages (with deep linking)
- ✅ Online/offline status tracking
- ✅ Message read receipts
- ✅ Strict null safety
- ✅ Cubit-based state management
- ✅ Clean architecture

## Architecture

```
lib/
├── core/
│   ├── chat_service.dart          # Firebase chat operations
│   └── notification_service.dart  # Push notification handling
├── data/
│   ├── data_provider/
│   │   └── database_config.dart   # Firebase collection/field constants
│   └── models/
│       └── chat/
│           ├── chat_room_model.dart    # Chat room data model
│           ├── chat_user_model.dart    # Chat user data model
│           ├── message_model.dart      # Message data model
│           └── typing_status_model.dart # Typing status model
├── logic/
│   └── cubit/
│       └── chat/
│           ├── chat_list_cubit.dart    # Chat list state management
│           ├── chat_list_state.dart    # Chat list states
│           ├── conversation_cubit.dart # Conversation state management
│           └── conversation_state.dart # Conversation states
└── presentation/
    └── screens/
        └── chat/
            ├── chat_screen.dart        # Chat list UI
            ├── conversation_screen.dart # Conversation UI
            └── component/
                ├── conversation_input_field.dart
                ├── message_bubble.dart
                └── typing_indicator_bubble.dart
```

## Data Models

### ChatUserModel

Represents a user in the chat system:

- `id`: User ID (Firebase Auth UID)
- `firstName`, `lastName`: User name
- `email`, `phone`: Contact info
- `image`: Profile picture URL
- `isOnline`: Online status
- `lastSeen`: Last online timestamp
- `deviceToken`: FCM token for notifications

### ChatRoomModel

Represents a chat conversation:

- `chatRoomId`: Unique ID (sorted: `userId1_userId2`)
- `participantIds`: Array of two user IDs
- `lastMessage`: Preview of last message
- `lastMessageTime`: Timestamp of last message
- `unreadCounts`: Map of userId → unread count
- `otherUser`: Fetched user data for display

### MessageModel

Represents a message:

- `messageId`: Unique message ID
- `senderId`, `receiverId`: Sender and receiver IDs
- `content`: Message text
- `messageType`: `text`, `image`, or `file`
- `timestamp`: Send time
- `isRead`: Read status
- `readAt`: Read timestamp

### TypingStatusModel

Tracks typing status:

- `chatRoomId`: Parent chat room
- `typingUserId`: User who is typing
- `isTyping`: Current typing state
- `typingTimestamp`: Last update time
- `isRecentlyTyping`: Computed (< 10 seconds ago)

## Cubit Classes

### ChatListCubit

Manages the chat list screen:

- `loadChatRooms()`: Start streaming chat rooms
- `loadAllUsers()`: Load users for new chat creation
- `startChatWithUser(userId)`: Create/get chat room
- Automatically listens to typing status for each room

### ConversationCubit

Manages the conversation screen:

- `initConversation()`: Initialize with chat room ID
- `onMessageChanged(text)`: Handle typing with debounce
- `sendMessage(content)`: Send a message
- Automatically marks messages as read
- Cleans up typing status on close

## Typing Indicator Optimization

To prevent excessive Firebase writes, the typing indicator uses:

1. **Debouncing**: Only updates Firebase after typing stops for 2 seconds
2. **Auto-expiry**: Typing status auto-clears after 3 seconds
3. **Cleanup on send**: Immediately clears typing when message is sent
4. **Cleanup on close**: Clears typing when leaving the screen

## Push Notifications

### Setup

1. FCM token is automatically synced to Firestore in `users/{userId}.device_token`
2. Firebase Cloud Function triggers on new messages
3. Notifications include sender name and message preview

### Deep Linking

When user taps a notification:

1. Parse `chat_room_id` from notification data
2. Fetch chat room and other user data
3. Navigate to `ConversationScreen` with the chat room

### Active Chat Suppression

Notifications are suppressed when the user is already in the active chat room.

## Usage Examples

### Start a new chat

```dart
final cubit = context.read<ChatListCubit>();
final chatRoom = await cubit.startChatWithUser(otherUserId);
if (chatRoom != null) {
  Navigator.pushNamed(
    context,
    RouteNames.conversationScreen,
    arguments: chatRoom,
  );
}
```

### Send a message

```dart
final cubit = context.read<ConversationCubit>();
await cubit.sendMessage('Hello!');
```

### Handle typing

```dart
TextField(
  onChanged: (text) {
    context.read<ConversationCubit>().onMessageChanged(text);
  },
)
```

## Firebase Setup

### Required Collections

- `users` - User profiles
- `chat_rooms` - Chat metadata
- `chat_rooms/{id}/messages` - Messages subcollection
- `typing_status` - Typing indicators

### Required Indexes

See `docs/FIREBASE_DATA_STRUCTURES.md` for complete index configuration.

### Cloud Functions

Deploy `firebase_functions/index.js` for push notifications:

```bash
cd firebase_functions
npm install
firebase deploy --only functions
```

## Testing Checklist

- [ ] Users can see list of chat rooms
- [ ] Typing indicator shows in chat list
- [ ] Typing indicator shows in conversation
- [ ] Messages send instantly
- [ ] Messages appear for both users in real-time
- [ ] Unread count updates correctly
- [ ] Online/offline status updates
- [ ] Push notifications received when app is backgrounded
- [ ] Tapping notification opens correct chat
- [ ] Read receipts show correctly
