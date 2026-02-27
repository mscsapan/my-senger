# iOS Notification Actions Setup

This guide explains how to properly set up interactive notifications for iOS.

## Current Implementation Status

Your app now has Android direct reply working. To add similar functionality for iOS, follow these steps.

## Step 1: Update iOS Configuration in NotificationService

Add this code to the `_initializeLocalNotifications()` method in `notification_service.dart`:

```dart
// For iOS interactive notifications (replace existing iOS initialization)
if (Platform.isIOS) {
  final DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'CHAT_CATEGORY',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'reply',
                'Reply',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                  DarwinNotificationActionOption.authenticationRequired,
                },
              ),
              DarwinNotificationAction.plain(
                'mark_read',
                'Mark as read',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive,
                },
              ),
              DarwinNotificationAction.plain(
                'open',
                'Open',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
        ],
      );
}
```

## Step 2: Update iOS Notification Details

Replace the iOS notification details in `_showChatNotification()`:

```dart
const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
  subtitle: 'New message',
  categoryIdentifier: 'CHAT_CATEGORY',
  threadIdentifier: 'chat_message',
);
```

## Step 3: Update iOS Native Code

Edit `ios/Runner/GeneratedPluginRegistrant.m` or `Podfile` to ensure `flutter_local_notifications` includes notification actions support:

```ruby
# In ios/Podfile, ensure this pod is included:
pod 'flutter_local_notifications', :path => '.symlinks/plugins/flutter_local_notifications/ios'
```

## Step 4: Handle iOS Actions

The existing `_onNotificationTapped()` method already handles iOS actions because the `flutter_local_notifications` plugin passes action IDs the same way for both platforms.

## Common Issues with iOS Notifications

### Issue 1: Actions Not Appearing

**Solution**:

- Ensure you swipe/press the notification (not just tap)
- Check that you granted notification permissions
- Verify iOS 10+ (required for notification actions)

### Issue 2: Reply Input Not Showing

**Solution**:

- For iOS, you need to use a special input action type
- Replace the reply action with:

```dart
DarwinNotificationAction.plain(
  'reply',
  'Reply',
  options: <DarwinNotificationActionOption>{
    DarwinNotificationActionOption.foreground,
    DarwinNotificationActionOption.authenticationRequired,
  },
),
```

### Issue 3: Actions Visible But Not Working

**Solution**:

- Ensure `_onNotificationTapped()` is being called
- Add logging to verify action processing
- Check that `response.actionId` is being captured

## Full iOS Reply Implementation (Optional - More Advanced)

If you want direct text input on iOS (like 3D Touch reply), you need to use native iOS code:

1. Create a new key in `Info.plist`:

```xml
<key>NSLocalizedDescription</key>
<string>This app needs notification permissions</string>
```

2. In `ios/Runner/GeneratedPluginRegistrant.m`, import:

```objc
#import "GeneratedPluginRegistrant.h"
```

3. Add custom notification extension (advanced - requires iOS native knowledge)

## Testing iOS Notifications

### In Xcode Simulator:

```bash
# Install pusher or similar app
# Or use terminal command:
xcrun simctl push booted 'com.yourapp' notification.json
```

### With Real Device:

1. Use Firebase Console > Cloud Messaging
2. Send test notification to your device
3. Long press or swipe notification to see actions
4. Tap action and verify it's processed

## Payload Structure for iOS

Ensure your Cloud Function sends correct payload for iOS:

```javascript
const payload = {
  notification: {
    title: senderName,
    body: messagePreview,
  },
  apns: {
    payload: {
      aps: {
        sound: "default",
        badge: 1,
        alert: {
          title: senderName,
          body: messagePreview,
        },
        category: "CHAT_CATEGORY",
        customData: {
          type: "chat_message",
          chat_room_id: chatRoomId,
          sender_id: senderId,
        },
      },
    },
  },
  data: {
    type: "chat_message",
    chat_room_id: chatRoomId,
    sender_id: senderId,
    sender_name: senderName,
    message: messagePreview,
  },
  token: fcmToken,
};
```

## Differences Between Android and iOS

| Feature               | Android          | iOS                 |
| --------------------- | ---------------- | ------------------- |
| Reply with text input | Yes (Inline)     | Yes (system dialog) |
| Quick actions         | Yes              | Yes (long press)    |
| Badges                | Automatic        | Manual count        |
| Sound                 | Custom supported | Limited             |
| Grouping              | Yes (group key)  | Limited             |
| Threading             | Yes              | Yes                 |
| Inline images         | Yes              | Limited             |

## Firebase Console Testing

1. Go to Firebase Console > Cloud Messaging
2. Create new campaign
3. Send to a test device
4. On iOS, swipe or long press the notification
5. Tap "Reply" action (may need specific iOS version or swiping)

## Troubleshooting Log Output

Add this to debug iOS notification handling:

```dart
// In _onNotificationTapped()
debugPrint('iOS Notification Response:');
debugPrint('  Action ID: ${response.actionId}');
debugPrint('  Payload: ${response.payload}');
debugPrint('  Input: ${response.input}');
debugPrint('  Is notification: ${response.notificationResponseType}');
```

## Next Steps

1. ✅ Android direct reply is already working
2. ⚠️ iOS actions require following steps above
3. After implementation, test on iOS device
4. Add tests for both platforms
5. Consider using `firebase_messaging` API directly for more control

## References

- [Flutter Local Notifications iOS Setup](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Cloud Messaging APNS Configuration](https://firebase.google.com/docs/cloud-messaging/xmpp-server-errors)
- [iOS Notification Capabilities](https://developer.apple.com/documentation/usernotifications)
