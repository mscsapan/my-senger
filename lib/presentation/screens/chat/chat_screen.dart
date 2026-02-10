import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/notification_diagnostics.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/chat_user_model.dart';
import '../../../logic/cubit/chat/chat_list_cubit.dart';
import '../../routes/route_names.dart';
import '../../utils/constraints.dart';
import '../../utils/navigation_service.dart';
import '../../utils/utils.dart';
import '../../widgets/circle_image.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text.dart';

/// Real-time Chat List Screen
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatListCubit()
        ..loadChatRooms()
        ..loadAllUsers(),
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  const _ChatScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chats',
        visibleLeading: false,
        action: [
          // Debug button (only shown in debug mode)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: grayColor),
              onPressed: () =>
                  NotificationDiagnostics.showDiagnosticsDialog(context),
              tooltip: 'Notification Diagnostics',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: blackColor),
            onPressed: () => context.read<ChatListCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          return switch (state) {
            ChatListInitial() => const _LoadingShimmer(),
            ChatListLoading() => const _LoadingShimmer(),
            ChatListError(message: final message) => _ErrorView(
              message: message,
            ),
            ChatListLoaded(chatRooms: final chatRooms) => _LoadedChatList(
              chatRooms: chatRooms,
              availableUsers: state.usersWithoutChats,
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showNewChatDialog(context),
        child: const Icon(Icons.chat_bubble_outline, color: whiteColor),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final cubit = context.read<ChatListCubit>();
    final state = cubit.state;

    if (state is! ChatListLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => _NewChatBottomSheet(
        users: state.allUsers,
        onUserSelected: (user) async {
          Navigator.pop(dialogContext);
          final chatRoom = await cubit.startChatWithUser(user.id);
          if (chatRoom != null && context.mounted) {
            NavigationService.navigateTo(
              RouteNames.conversationScreen,
              arguments: chatRoom,
            );
          }
        },
      ),
    );
  }
}

/// Loaded chat list with chat rooms and typing indicators
class _LoadedChatList extends StatelessWidget {
  const _LoadedChatList({
    required this.chatRooms,
    required this.availableUsers,
  });

  final List<ChatRoomModel> chatRooms;
  final List<ChatUserModel> availableUsers;

  @override
  Widget build(BuildContext context) {
    if (chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: grayColor.withValues(alpha: 0.5),
            ),
            Utils.verticalSpace(16),
            const CustomText(
              text: 'No conversations yet',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: grayColor,
            ),
            Utils.verticalSpace(8),
            const CustomText(
              text: 'Start a new chat by tapping the button below',
              fontSize: 14,
              color: grayColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        context.read<ChatListCubit>().refresh();
      },
      child: ListView.builder(
        itemCount: chatRooms.length,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: Utils.only(bottom: 80.0),
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return _ChatRoomItem(
            chatRoom: chatRoom,
            currentUserId: context.read<ChatListCubit>().currentUserId ?? '',
          );
        },
      ),
    );
  }
}

/// Individual chat room item with typing indicator
class _ChatRoomItem extends StatelessWidget {
  const _ChatRoomItem({required this.chatRoom, required this.currentUserId});

  final ChatRoomModel chatRoom;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final otherUser = chatRoom.otherUser;
    final unreadCount = chatRoom.getUnreadCount(currentUserId);

    return InkWell(
      onTap: () {
        NavigationService.navigateTo(
          RouteNames.conversationScreen,
          arguments: chatRoom,
        );
      },
      child: Container(
        padding: Utils.symmetric(h: 14.0, v: 12.0),
        child: Row(
          children: [
            // Profile Image with Online Indicator
            Stack(
              children: [
                CircleImage(image: otherUser?.image ?? '', size: 52.0),
                if (otherUser?.isOnline ?? false)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: greenColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: whiteColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            Utils.horizontalSpace(12.0),
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  CustomText(
                    text: otherUser?.fullName ?? 'Unknown User',
                    maxLine: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                  Utils.verticalSpace(4.0),
                  // Last message or typing indicator
                  if (chatRoom.isOtherUserTyping)
                    const _TypingIndicator()
                  else
                    CustomText(
                      text: chatRoom.hasLastMessage
                          ? chatRoom.lastMessage
                          : 'Start a conversation',
                      maxLine: 1,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 14.0,
                      color: unreadCount > 0 ? blackColor : grayColor,
                    ),
                ],
              ),
            ),
            Utils.horizontalSpace(8.0),
            // Time and Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: chatRoom.formattedLastMessageTime,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                  color: unreadCount > 0 ? primaryColor : grayColor,
                ),
                if (unreadCount > 0) ...[
                  Utils.verticalSpace(6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomText(
                      text: unreadCount > 99 ? '99+' : unreadCount.toString(),
                      color: whiteColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated typing indicator
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'typing',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: primaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
        Utils.horizontalSpace(4),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_controller.value - delay).clamp(0.0, 1.0);
                final opacity = (value * 2.0).clamp(0.3, 1.0);
                return Container(
                  margin: const EdgeInsets.only(right: 2),
                  child: Opacity(
                    opacity: opacity,
                    child: const CustomText(
                      text: '.',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

/// Bottom sheet for starting a new chat
class _NewChatBottomSheet extends StatelessWidget {
  const _NewChatBottomSheet({required this.users, required this.onUserSelected});

  final List<ChatUserModel> users;
  final void Function(ChatUserModel) onUserSelected;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: grayColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: Utils.symmetric(v: 16.0),
              child: const CustomText(
                text: 'Start New Chat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 1),
            // User List
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: CustomText(
                        text: 'No users available',
                        color: grayColor,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: users.length,
                      padding: Utils.symmetric(v: 8.0),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleImage(image: Utils.imagePath(user.image), size: 48),
                              if (user.isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: greenColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: whiteColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: CustomText(
                            fontSize: 15.0,
                            text: user.fullName,
                            fontWeight: FontWeight.w700,
                          ),
                          subtitle: CustomText(
                            text: user.email,
                            fontSize: 12,
                            color: grayColor,
                          ),
                          onTap: () => onUserSelected(user),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Loading shimmer effect
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300] ?? Colors.grey,
      highlightColor: Colors.grey[100] ?? Colors.white,
      child: ListView.builder(
        itemCount: 8,
        padding: Utils.symmetric(v: 8.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: Utils.symmetric(h: 14.0, v: 10.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: Colors.white),
                Utils.horizontalSpace(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Utils.verticalSpace(6),
                      Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Utils.symmetric(h: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: redColor.withValues(alpha: 0.7),
            ),
            Utils.verticalSpace(16),
            CustomText(
              text: 'Something went wrong',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
            Utils.verticalSpace(8),
            CustomText(
              text: message,
              fontSize: 14,
              color: grayColor,
              textAlign: TextAlign.center,
            ),
            Utils.verticalSpace(24),
            ElevatedButton(
              onPressed: () => context.read<ChatListCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
