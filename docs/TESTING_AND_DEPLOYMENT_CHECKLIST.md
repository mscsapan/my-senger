# Pre-Deployment Checklist & Testing Guide

## 🎯 Pre-Testing Setup

Before you start testing, ensure:

- [ ] App has been rebuilt (`flutter clean` then `flutter pub get`)
- [ ] App is running on a device or emulator with Android 8.0+ (for reply actions)
- [ ] User is logged in
- [ ] Firebase is properly configured
- [ ] FCM tokens are being synced to Firestore
- [ ] You have access to another device or Firebase Console to send test messages

## 📋 Testing Checklist

### Phase 1: Basic Navigation (5 minutes)

#### Test 1.1: Foreground Navigation

**Scenario**: App is open and in foreground

```
□ Step 1: Open app
□ Step 2: Enter a conversation with any user
□ Step 3: Go back to chat list (app still in foreground)
□ Step 4: Using different device/account, send a message
□ Step 5: Check if notification appears → IT SHOULD NOT (suppressed)
□ Step 6: Check console logs for "📱 Suppressing notification"
```

**Expected Result**: ✅ No notification appears while in chat

**If Failed**:

- Check that `setActiveChatRoom()` was called in \_init()
- Verify chat room ID matches payload
- Check console logs

---

#### Test 1.2: Background Navigation (Tap Notification)

**Scenario**: App is in background, user taps notification

```
□ Step 1: Open app and enter a conversation
□ Step 2: Go back to chat list
□ Step 3: Minimize app (send to background - don't force quit)
□ Step 4: Using different device, send a message
□ Step 5: Notification appears on device
□ Step 6: Tap the notification
□ Step 7: App comes to foreground
□ Step 8: Verify correct conversation is open
□ Step 9: Verify the new message is visible
```

**Expected Result**: ✅ App navigates to correct conversation

**If Failed**:

- Check logs for "✅ Navigated to chat room:"
- If you see "⚠️ Navigator not ready", navigation is retrying (give it a moment)
- Verify chat room exists in Firestore
- Check that data includes `chat_room_id` in payload

---

#### Test 1.3: Terminated State Navigation (Cold Launch)

**Scenario**: App is fully closed, user taps notification

```
□ Step 1: Force quit the app completely
  □ On Android: Settings > Apps > [Your App] > Force Stop
  □ Or long-press app icon > Swipe up
□ Step 2: Using different device, send a message
□ Step 3: Notification appears
□ Step 4: Tap the notification
□ Step 5: App launches and navigates to conversation
□ Step 6: Wait ~2-3 seconds for data to load
□ Step 7: Verify correct conversation is open
□ Step 8: Verify message appears
```

**Expected Result**: ✅ App launches and correctly opens conversation

**If Failed**:

- Check logs for timing issues
- Increase delay in `init()` if navigation happens too quickly
- Verify Firestore data loads correctly

---

### Phase 2: Direct Reply (8 minutes)

#### Test 2.1: Direct Reply from Foreground

**Scenario**: App is open, notification has reply action

```
□ Step 1: Open app
□ Step 2: Put app in background (minimize)
□ Step 3: Using different device, send message
□ Step 4: Notification appears on device screen
□ Step 5: Swipe down on notification to expand it
□ Step 6: Tap the "Reply" action (blue button)
□ Step 7: Text input dialog appears
□ Step 8: Type: "Test reply message"
□ Step 9: Tap "Send" or "OK" button
□ Step 10: Check Firestore - message should appear in messages collection
□ Step 11: Open app - conversation should open and show your reply
```

**Expected Result**: ✅ Reply appears in Firestore and conversation

**If Failed**:

- Check logs for "✅ Reply sent successfully via notification"
- If action button doesn't appear: try swiping down more on notification
- If text input doesn't show: ensure `showsUserInterface: true` in code
- Verify Firestore rules allow message creation
- Check that user is authenticated (currentUserId not null)

---

#### Test 2.2: Direct Reply from Background (No Input)

**Scenario**: Reply is sent without opening app after

```
□ Step 1: Force quit app
□ Step 2: Using different device, send message
□ Step 3: Notification appears
□ Step 4: Swipe down to see reply action
□ Step 5: Tap "Reply"
□ Step 6: Type message and confirm
□ Step 7: Don't open app yet
□ Step 8: Wait 5 seconds
□ Step 9: Check Firestore directly for the message
□ Step 10: Now open app (conversation should open automatically)
```

**Expected Result**: ✅ Message saved to Firestore, app opens conversation

**If Failed**:

- Check Firestore for message document
- Verify database operation completed (check timestamps)
- Check auth status
- Review error logs in `_handleDirectReply()`

---

#### Test 2.3: Mark as Read Action

**Scenario**: User taps "Mark as read" action

```
□ Step 1: Receive notification in background
□ Step 2: Swipe down to see actions
□ Step 3: Tap "Mark as read" (green button)
□ Step 4: Notification should dismiss
□ Step 5: No app navigation should occur
□ Step 6: Check console - should see "Marking notification as read"
```

**Expected Result**: ✅ Notification dismisses silently

**If Failed**:

- Check that action ID is 'mark_read' in code
- Verify action has `showsUserInterface: false`

---

### Phase 3: Multiple Conversations (5 minutes)

#### Test 3.1: Navigation Between Different Chats

**Scenario**: Test that notifications navigate to correct chat

```
□ Step 1: Add 3 test users (A, B, C)
□ Step 2: Open chat with User A
□ Step 3: Exit chat to list
□ Step 4: Send app to background
□ Step 5: Have both User B and User C send messages
□ Step 6: Two notifications appear
□ Step 7: Tap User B's notification
□ Step 8: Verify User B's chat opens (NOT User C)
□ Step 9: Go back to chat list
□ Step 10: Tap User C's notification
□ Step 11: Verify User C's chat opens
```

**Expected Result**: ✅ Each notification opens correct conversation

**If Failed**:

- Check that `chat_room_id` in payloads are different
- Verify correct chat room data is being fetched
- Check Firestore for correct chat room documents

---

#### Test 3.2: Rapid Notifications

**Scenario**: Multiple notifications in quick succession

```
□ Step 1: Send app to background
□ Step 2: Have User A send 3 messages quickly
□ Step 3: Check if notifications are grouped or separate
□ Step 4: Tap the latest notification
□ Step 5: Verify correct conversation opens
□ Step 6: Verify all 3 messages appear in chat
```

**Expected Result**: ✅ Messages are grouped (Android) and chat displays all

**If Failed**:

- Notifications might not be grouped - this is okay for now
- Verify messages all appear in Firestore

---

## 🔍 Debugging While Testing

### Enable Verbose Logging

Add to your main app to see all notification logs:

```dart
// In main.dart main() function
debugPrintBeginFrame = true;
WidgetInspectorService.enableCheckedMode();
```

### Watch Console Logs

Key log messages to look for:

| Log                           | Meaning                 | Status     |
| ----------------------------- | ----------------------- | ---------- |
| `✅ Navigated to chat room:`  | Navigation successful   | OK ✅      |
| `❌ Chat room not found:`     | Chat room doesn't exist | ERROR      |
| `⚠️ Navigator not ready`      | App not initialized yet | RETRY (OK) |
| `📱 Suppressing notification` | In active chat          | OK ✅      |
| `✅ Reply sent successfully`  | Reply saved             | OK ✅      |
| `❌ Cannot send reply`        | Reply failed            | ERROR      |

### Check Firestore in Real-Time

1. Go to Firebase Console > Firestore
2. Open `chat_rooms/{chatRoomId}/messages`
3. Watch messages appear in real-time during tests
4. Verify message structure:
   - Should have: `id`, `sender_id`, `receiver_id`, `content`, `timestamp`
   - Message type should be: `text`

### Use ADB to Check Logs

```bash
# For detailed notification logs
adb logcat | grep -i notification

# For app logs
adb logcat | grep -i flutter

# For specific app
adb logcat | grep -i "my_senger"
```

---

## ✅ Test Results Summary

After completing all tests, fill in this summary:

### Navigation Tests

- [ ] Foreground suppression working
- [ ] Background navigation working
- [ ] Terminated state navigation working

### Reply Tests

- [ ] Direct reply saving to Firestore
- [ ] Reply message structure correct
- [ ] App navigation after reply works
- [ ] Mark as read action works

### Multi-Chat Tests

- [ ] Navigation to correct conversation
- [ ] Message grouping (if applicable)
- [ ] Rapid notifications handled

### Overall Status

- [ ] All tests passed - READY FOR PRODUCTION
- [ ] Some tests failed - SEE TROUBLESHOOTING
- [ ] Major issues - NEEDS INVESTIGATION

---

## 🚀 Pre-Deployment Steps

Once all tests pass, prepare for deployment:

### 1. Code Review

```
□ Review changes in notification_service.dart
□ Review changes in conversation_screen.dart
□ Check for any debug code that should be removed
□ Verify error handling is comprehensive
```

### 2. Build & Release Testing

```
□ Run: flutter clean
□ Run: flutter pub get
□ Run: flutter build apk (for Android release)
□ Run: flutter build ios (for iOS release)
□ Test the release build on a device
```

### 3. Firebase Configuration

```
□ Verify FCM is enabled in Firebase Console
□ Check notification channel exists in Android
□ Verify APNS certificates are set up (iOS)
□ Check Cloud Functions are deployed (if using)
```

### 4. Security & Permissions

```
□ Verify Android manifest has POST_NOTIFICATIONS permission
□ Check Firestore security rules for message creation
□ Verify user authentication is required
□ Check token refresh is working
```

### 5. Performance Metrics

```
□ Test on low-end device (if possible)
□ Check battery impact
□ Monitor network usage
□ Verify no memory leaks
```

### 6. Documentation

```
□ Update changelog
□ Document any configuration changes
□ Create deployment guide for DevOps
□ Add troubleshooting guide for support team
```

---

## 🚨 If Something Goes Wrong

### Issue: Notification doesn't navigate

```
1. Check console logs for "✅ Navigated to chat room:"
2. If you see "⚠️ Navigator not ready":
   - This is normal, navigation is retrying
   - Give it 1-2 more seconds
3. If no navigation happens:
   - Check Firebase logs for data structure
   - Verify chat room exists in Firestore
   - Restart device and try again
4. If still failing:
   - Check device notification settings
   - Try with a different device
   - Check Firebase project permissions
```

### Issue: Direct reply not saving

```
1. Check Firestore for the reply message
2. If message appears in Firestore but not in chat:
   - App might need to refresh
   - Wait 2-3 seconds
   - Go back and reopen the chat
3. If message doesn't appear in Firestore:
   - Check user is authenticated
   - Verify Firestore security rules
   - Check error logs in console
4. If permission denied error:
   - Update Firestore rules to allow message creation
   - Test in Firestore simulator first
```

### Issue: Reply action button not visible

```
1. Try swiping down harder on notification
2. Check Android version is 8.0+
3. Verify notification is expanded (not grouped)
4. Try different notification:
   - Close and reopen notification center
   - Send another test message
5. If still not visible:
   - Check `showsUserInterface: true` in code
   - Verify notification has `category: AndroidNotificationCategory.message`
```

---

## 📞 Support Resources

If you need help:

1. **Check the logs first** - Most issues are visible in console logs
2. **See NOTIFICATION_IMPLEMENTATION_GUIDE.md** - Detailed troubleshooting
3. **See CODE_CHANGES_DETAIL.md** - Exact code changes
4. **See NOTIFICATION_QUICK_REFERENCE.md** - Quick reference guide

---

## Timeline Estimate

- **Phase 1 Testing**: 5-10 minutes
- **Phase 2 Testing**: 8-15 minutes
- **Phase 3 Testing**: 5-10 minutes
- **Debugging (if needed)**: 10-30 minutes
- **Pre-Deployment**: 20-30 minutes

**Total Estimated Time**: 1-1.5 hours for full testing

---

## Final Validation

Before going to production, verify:

```
Product Check List:
□ All 3 navigation tests passing
□ All 3 reply tests passing
□ Multi-chat navigation correct
□ No console errors
□ Firestore data structure correct
□ Security rules allow operations
□ Android/iOS permissions granted
□ App performance acceptable
□ Battery impact minimal
□ Network usage normal

Deployment Check List:
□ Code reviewed
□ Tests documented
□ Changes logged
□ Backup created
□ Rollback plan ready
□ Team notified
□ Release notes prepared
□ Monitoring set up
```

---

**Ready to Deploy?** Yes ✅ - If all checkboxes above are checked

**Proceed to production deployment** once validation is complete.
