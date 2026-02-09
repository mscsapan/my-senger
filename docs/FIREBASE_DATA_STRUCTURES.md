# Firebase Data Structures

This document describes the Firebase Firestore data structures used for the real-time chat feature.

## Collections Overview

```
firestore-root/
├── users/                      # User profiles
│   └── {userId}/
├── chat_rooms/                 # Chat room metadata
│   └── {chatRoomId}/
│       └── messages/           # Subcollection of messages
│           └── {messageId}/
└── typing_status/              # Typing indicators
    └── {chatRoomId}_{userId}/
```

## Users Collection

**Collection Path:** `users`

Each document represents a user in the system.

```json
{
  "id": "user_abc123",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "image": "https://storage.googleapis.com/...",
  "device_token": "fcm_token_here",
  "status": true,
  "is_online": true,
  "last_seen": "2026-02-07T12:30:00Z"
}
```

### User Fields

| Field          | Type      | Description                                |
| -------------- | --------- | ------------------------------------------ |
| `id`           | string    | Unique user identifier (Firebase Auth UID) |
| `first_name`   | string    | User's first name                          |
| `last_name`    | string    | User's last name                           |
| `email`        | string    | User's email address                       |
| `phone`        | string    | User's phone number                        |
| `image`        | string    | Profile image URL                          |
| `device_token` | string    | FCM token for push notifications           |
| `status`       | boolean   | Account status (active/inactive)           |
| `is_online`    | boolean   | Online status                              |
| `last_seen`    | timestamp | Last online timestamp                      |

## Chat Rooms Collection

**Collection Path:** `chat_rooms`

Each document represents a chat conversation between two users.

```json
{
  "chat_room_id": "userId1_userId2",
  "participant_ids": ["userId1", "userId2"],
  "last_message": "Hello, how are you?",
  "last_message_time": "2026-02-07T12:30:00Z",
  "last_message_sender_id": "userId1",
  "created_at": "2026-02-01T10:00:00Z",
  "updated_at": "2026-02-07T12:30:00Z",
  "unread_count": {
    "userId1": 0,
    "userId2": 5
  }
}
```

### Chat Room Fields

| Field                    | Type      | Description                                     |
| ------------------------ | --------- | ----------------------------------------------- |
| `chat_room_id`           | string    | Unique chat room ID (sorted: `userId1_userId2`) |
| `participant_ids`        | array     | Array of participant user IDs                   |
| `last_message`           | string    | Preview of the last message                     |
| `last_message_time`      | timestamp | Time of the last message                        |
| `last_message_sender_id` | string    | User ID of last message sender                  |
| `created_at`             | timestamp | Chat room creation time                         |
| `updated_at`             | timestamp | Last update time                                |
| `unread_count`           | map       | Map of userId to unread message count           |

## Messages Subcollection

**Collection Path:** `chat_rooms/{chatRoomId}/messages`

Each document represents a message within a chat room.

```json
{
  "message_id": "msg_xyz789",
  "chat_room_id": "userId1_userId2",
  "sender_id": "userId1",
  "receiver_id": "userId2",
  "content": "Hello, how are you?",
  "message_type": "text",
  "timestamp": "2026-02-07T12:30:00Z",
  "is_read": false,
  "read_at": null
}
```

### Message Fields

| Field          | Type      | Description                      |
| -------------- | --------- | -------------------------------- |
| `message_id`   | string    | Unique message identifier        |
| `chat_room_id` | string    | Parent chat room ID              |
| `sender_id`    | string    | User ID of the sender            |
| `receiver_id`  | string    | User ID of the receiver          |
| `content`      | string    | Message content                  |
| `message_type` | string    | Type: `text`, `image`, `file`    |
| `timestamp`    | timestamp | Message sent time                |
| `is_read`      | boolean   | Whether message has been read    |
| `read_at`      | timestamp | When message was read (nullable) |

## Typing Status Collection

**Collection Path:** `typing_status`

Each document tracks a user's typing status in a chat room.

```json
{
  "chat_room_id": "userId1_userId2",
  "typing_user_id": "userId1",
  "is_typing": true,
  "typing_timestamp": "2026-02-07T12:30:00Z"
}
```

### Typing Status Fields

| Field              | Type      | Description               |
| ------------------ | --------- | ------------------------- |
| `chat_room_id`     | string    | Chat room ID              |
| `typing_user_id`   | string    | User ID who is typing     |
| `is_typing`        | boolean   | Current typing status     |
| `typing_timestamp` | timestamp | Last typing status update |

**Document ID Format:** `{chatRoomId}_{userId}`

## Security Rules

Here are recommended Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Chat rooms collection
    match /chat_rooms/{chatRoomId} {
      allow read: if request.auth != null &&
                     request.auth.uid in resource.data.participant_ids;
      allow create: if request.auth != null &&
                       request.auth.uid in request.resource.data.participant_ids;
      allow update: if request.auth != null &&
                       request.auth.uid in resource.data.participant_ids;

      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth != null &&
                       request.auth.uid in get(/databases/$(database)/documents/chat_rooms/$(chatRoomId)).data.participant_ids;
        allow create: if request.auth != null &&
                         request.auth.uid == request.resource.data.sender_id;
        allow update: if request.auth != null &&
                         request.auth.uid == resource.data.receiver_id;
      }
    }

    // Typing status collection
    match /typing_status/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      docId.matches('.*_' + request.auth.uid) ||
                      request.resource.data.typing_user_id == request.auth.uid;
    }
  }
}
```

## Indexes

Required composite indexes for optimal query performance:

### Chat Rooms

```
Collection: chat_rooms
Fields indexed:
- participant_ids (Array contains)
- last_message_time (Descending)
```

### Messages

```
Collection: chat_rooms/{chatRoomId}/messages
Fields indexed:
- timestamp (Ascending)
```

```
Collection: chat_rooms/{chatRoomId}/messages
Fields indexed:
- receiver_id (Ascending)
- is_read (Ascending)
```

## Best Practices

1. **Chat Room ID Generation**: Always sort user IDs alphabetically to ensure consistent chat room IDs:

   ```dart
   String generateChatRoomId(String userId1, String userId2) {
     final sortedIds = [userId1, userId2]..sort();
     return '${sortedIds[0]}_${sortedIds[1]}';
   }
   ```

2. **Typing Indicator Optimization**:
   - Auto-expire typing status after 10 seconds
   - Debounce typing updates to reduce writes
   - Clear typing status when sending a message

3. **Unread Count Management**:
   - Increment receiver's count when sending a message
   - Reset to 0 when entering the chat room
   - Use batch updates for multiple operations

4. **Message Pagination**: For large chat histories, use cursor-based pagination:
   ```dart
   .orderBy('timestamp', descending: true)
   .startAfter([lastMessage.timestamp])
   .limit(50)
   ```
