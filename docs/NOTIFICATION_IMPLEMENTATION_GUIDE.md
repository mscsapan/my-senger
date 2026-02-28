# Notification Implementation Guide

## Overview

This guide documents the complete push notification implementation with payload handling, direct reply functionality, and navigation fixes for the My Senger app.

## Issues Fixed

### 1. **Notification Navigation Not Working**

**Problem**: When users tapped notifications while the app was in the background or terminated, the app wasn't navigating to the chat room.

**Root Causes**:

- Navigator wasn't ready when notification tap handler was triggered
- Timing issue with Firebase message handling
- Missing null checks for the NavigationService

**Solutions Implemented**:

- Added delay (1.5 seconds) when app launches from notification to ensure app initialization
- Added retry logic with null checks in `_navigateToChatRoom()`
- Proper handling of both `FirebaseMessaging.onMessageOpenedApp` and `getInitialMessage()`
- Enhanced delay parameter in `_navigateBasedOnPayload()` for local notification taps

### 2. **Direct Reply Functionality Not Working**

**Problem**: Users couldn't reply directly from notifications.

**Solutions Implemented**:

- Added Android notification actions (Reply, Mark as read)
- Implemented `_handleDirectReply()` method to process replies
- Direct replies are saved to Firestore immediately
- After replying, the conversation screen opens automatically
- Chat room's last message is updated in real-time

### 3. **Notification Suppression**

**Enhancement**: Notifications are now properly suppressed when the user is actively viewing the chat.

**Implementation**:

- `NotificationService.setActiveChatRoom()` called when entering ConversationScreen
- Cleared when leaving ConversationScreen
- Foreground message handler checks `_activeChatRoomId` to prevent notification duplication

## Implementation Details

### Notification Service Changes

#### 1. **Import Addition**

```dart
import 'package:flutter/material.dart'; // Added for Colors in Android actions
```

#### 2. **Enhanced Chat Notification with Reply Actions**

The `_showChatNotification()` method now includes:

```dart
actions: <AndroidNotificationAction>[
  AndroidNotificationAction(
    'reply',
    'Reply',
    titleColor: Colors.blue,
    showsUserInterface: true,
    inputs: <AndroidNotificationActionInput>[
      const AndroidNotificationActionInput(
        label: 'Reply',
        allowFreeformInput: true,
      ),
    ],
  ),
  AndroidNotificationAction(
    'mark_read',
    'Mark as read',
    titleColor: Colors.green,
    showsUserInterface: false,
  ),
],
```

**Android Features**:

- Users can swipe down on notification to see reply action
- Reply action opens an input field for typing
- "Mark as read" action is silent (no UI shown)
- Group key prevents duplicate notifications

**iOS Features**:

- Subtitle added for better context
- Standard notification actions (iOS 10+)

#### 3. **Direct Reply Handler**

New method `_handleDirectReply()` handles:

- Extracting chat room and sender information from notification payload
- Validating user authentication
- Creating message document in Firestore with proper structure:
  ```dart
  {
    'id': messageRef.id,
    'sender_id': currentUserId,
    'receiver_id': senderId,
    'content': replyText,
    'message_type': 'text',
    'timestamp': FieldValue.serverTimestamp(),
    'is_read': false,
    'created_at': FieldValue.serverTimestamp(),
  }
  ```
- Updating chat room's last message
- Opening conversation screen after reply

#### 4. **Improved Navigation Handler**

`_onNotificationTapped()` now:

- Checks for action type (reply, mark_read, or tap)
- Routes to appropriate handler
- Passes `delayNavigation: true` for local notifications to ensure app readiness
- Properly parses payload with error checking

#### 5. **Enhanced Navigation with Retry Logic**

`_navigateToChatRoom()` now:

- Checks if navigator is ready before navigating
- Implements retry mechanism with 1-second delay if navigator isn't ready
- Fetches fresh chat room and user data
- Proper error handling and logging

#### 6. **App Initialization Improvements**

`init()` method now:

- Uses 1.5-second delay for terminated state cold launch
- Properly handles both background and terminated states
- Clear logging for debugging

### Conversation Screen Changes

#### 1. **Active Chat Room Tracking**

Added to `_init()`:

```dart
NotificationService().setActiveChatRoom(chatRoom.chatRoomId);
```

Added to `dispose()`:

```dart
NotificationService().setActiveChatRoom(null);
```

This ensures:

- No duplicate notifications while user is in the chat
- Notifications resume when user leaves the chat
- Smooth user experience

#### 2. **Import Addition**

```dart
import 'package:my_senger/core/notification_service.dart';
```

## Database Schema Requirements

The following Firestore structure is required for direct replies to work:

```
chat_rooms/
  {chatRoomId}/
    messages/
      {messageId}/
        - id: String
        - sender_id: String
        - receiver_id: String
        - content: String
        - message_type: String
        - timestamp: Timestamp
        - is_read: Boolean
        - created_at: Timestamp
    - last_message: String
    - last_message_time: Timestamp
    - last_sender_id: String

users/
  {userId}/
    - device_token: String
```

## Testing Checklist

### 1. **Foreground Notification Suppression**

- [ ] Open chat with User A
- [ ] Have User B send a message
- [ ] Verify no notification appears (check logs)
- [ ] Exit chat
- [ ] Have User B send another message
- [ ] Verify notification appears

### 2. **Background Navigation**

- [ ] Close app (send to background)
- [ ] Have another user send a message
- [ ] Tap notification
- [ ] Verify app opens and navigates to correct conversation
- [ ] Verify message appears in chat

### 3. **Terminated State Navigation**

- [ ] Fully close app (force quit)
- [ ] Have another user send a message
- [ ] Tap notification
- [ ] Verify app launches and navigates to correct conversation
- [ ] Verify message appears in chat

### 4. **Direct Reply from Foreground Notification**

- [ ] Keep app in foreground
- [ ] Have another user send a message
- [ ] You receive foreground notification
- [ ] Swipe down on notification to see actions
- [ ] Tap "Reply"
- [ ] Type reply message
- [ ] Verify reply is sent and appears in chat
- [ ] Verify app navigates to conversation

### 5. **Direct Reply from Background Notification**

- [ ] Put app in background
- [ ] Have another user send a message
- [ ] Swipe down on notification to see actions
- [ ] Tap "Reply"
- [ ] Type reply message
- [ ] Verify reply is sent (check Firestore)
- [ ] Open app and verify reply appears in chat

### 6. **Mark as Read Action**

- [ ] Receive background notification
- [ ] Swipe down and tap "Mark as read"
- [ ] Verify notification is dismissed
- [ ] Check that message isn't duplicated

### 7. **Multiple Conversations**

- [ ] Have users A and B send messages
- [ ] Receive notifications from both
- [ ] Tap notification from User A
- [ ] Verify correct conversation opens
- [ ] Tap back, then tap notification from User B
- [ ] Verify User B's conversation opens

## Troubleshooting

### Issue: Notifications Still Not Navigating

**Solutions**:

1. Check console logs for navigation timing issues
2. Ensure chat room and recipient IDs are being passed in notification data
3. Verify chat room exists in Firestore
4. Check that NavigationService.navigatorKey is properly initialized
5. Increase delay if needed in `init()` method

### Issue: Direct Reply Not Saving

**Solutions**:

1. Verify Firestore security rules allow message creation
2. Check that user is authenticated
3. Ensure `DatabaseConfig.chatRoomsCollection` and `DatabaseConfig.messagesSubcollection` are correct
4. Check console logs in `_handleDirectReply()`
5. Verify chat room ID and sender ID are being parsed correctly

### Issue: Notification Actions Not Appearing

**Android**:

1. Swipe down on notification (notification must be expanded)
2. Check notification channel settings
3. Verify Android API level 26+ (Android 8.0+)
4. Ensure `showsUserInterface: true` for reply action

**iOS**:

1. Declare notification categories in `Info.plist`
2. Ensure system notification settings allow action buttons
3. Check iOS version 10+

## Cloud Functions Integration

If using Cloud Functions for notifications, ensure the payload includes all required fields:

```javascript
const payload = {
  notification: {
    title: senderName,
    body: messagePreview,
  },
  data: {
    type: "chat_message",
    chat_room_id: chatRoomId,
    sender_id: senderId,
    sender_name: senderName,
    message: messagePreview,
    click_action: "FLUTTER_NOTIFICATION_CLICK",
  },
  token: fcmToken,
  android: {
    notification: {
      channelId: "chat_messages_channel",
      priority: "high",
      sound: "default",
    },
    priority: "high",
  },
};
```

## Future Enhancements

1. **iOS Interactive Notifications**
   - Implement similar reply action for iOS using UNNotificationAction
   - Add custom sound alerts
   - Implement rich notifications with images

2. **Notification Grouping**
   - Group multiple messages from same sender
   - Show summary notification
   - Individual message quick reply

3. **Rich Media Notifications**
   - Display thumbnail images in notifications
   - Show preview of shared files
   - Audio message playback controls

4. **Smart Notification Timing**
   - Mute notifications during certain hours
   - Focus mode integration
   - Do Not Disturb exceptions

5. **Advanced Analytics**
   - Track notification engagement
   - Monitor direct reply usage
   - Analyze notification timing effectiveness

## Performance Considerations

1. **Firestore Queries**: Chat room queries in navigation handler are optimized with ID-based lookups
2. **Memory Management**: Notification payloads are minimal
3. **Battery Impact**: No long-running tasks in notification handlers
4. **Network Usage**: Messages are queued even if network is unavailable

## Security Notes

1. **Notification Payloads**: Keep data minimal and non-sensitive due to potential interception
2. **Database Access**: Ensure Firestore rules validate sender/receiver relationships
3. **FCM Token**: Regularly refresh tokens; implement proper token rotation
4. **User Authentication**: All notification handlers verify user login status
