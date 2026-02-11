import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_senger/presentation/utils/k_string.dart';
import '../../../data/models/chat/chat_page_status.dart';
import '../../utils/navigation_service.dart';
import '/logic/cubit/auth/auth_cubit.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../../../logic/cubit/chat/conversation_cubit.dart';
import '../../utils/constraints.dart';
import '../../utils/utils.dart';
import '../../widgets/circle_image.dart';
import '../../widgets/custom_text.dart';
import 'component/conversation_input_field.dart';
import 'component/message_bubble.dart';
import 'component/typing_indicator_bubble.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key,required this.chatRoom});
  final ChatRoomModel chatRoom;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {


  late ConversationCubit conversationCubit;
  late AuthCubit authCubit;
  late ChatRoomModel chatRoom;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late String ? otherUserId;

  @override
  void initState() {
    super.initState();
    _init();

  }

  void _init(){
    conversationCubit = context.read<ConversationCubit>();
    authCubit = context.read<AuthCubit>();

    chatRoom = widget.chatRoom;

    conversationCubit.setChatRoom(chatRoom);
    // Then initialize the conversation
    otherUserId = chatRoom.otherUser?.id ?? chatRoom.getOtherParticipantId(conversationCubit.currentUserId ?? '');
    conversationCubit.initConversation(
      chatRoomId: chatRoom.chatRoomId,
      otherUserId: otherUserId ?? '',
      existingChatRoom: chatRoom,
      existingOtherUser: chatRoom.otherUser,
    );

    final model = ChatPageStatus(userId: conversationCubit.currentUserId ?? '', isOpenChatPage: true);

    authCubit..fetchOtherUserInfo(otherUserId)..createUserOnlineStatus(model);

    debugPrint('current-user ${conversationCubit.currentUserId}');
    debugPrint('other-user $otherUserId');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();

    authCubit.updateUserOnlineStatus(ChatPageStatus(userId: conversationCubit.currentUserId??'',isOpenChatPage: false));

    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<ConversationCubit, ConversationState>(
        listener: (context, state) {
          if (state is ConversationLoaded && state.hasMessages) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if(state is ConversationInitial || state is ConversationLoading){
            return const _LoadingView();
          }else if(state is ConversationError){
            return _ErrorView(message: state.message);
          }else if(state is ConversationLoaded){
            return _buildLoadedView(context, state);
          }else if(state is ConversationSending){
            return _buildLoadedView(context, context.read<ConversationCubit>().state as ConversationLoaded);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 30.0,
      elevation: 1,
      backgroundColor: whiteColor,
      surfaceTintColor: whiteColor,
      title: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) {
          final otherUser = state is ConversationLoaded
              ? state.otherUser
              : null;
          final isTyping = state is ConversationLoaded && state.isOtherUserTyping;
          final isOnline = state is ConversationLoaded && state.isOtherUserOnline;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image with Online Indicator
              Stack(
                children: [
                  CircleImage(image: Utils.imagePath(otherUser?.image), size: 44.0),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: greenColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: whiteColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              Utils.horizontalSpace(10.0),
              // Name and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: otherUser?.fullName ?? 'Chat',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    color: blackColor,
                  ),
                  if (isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else if (isOnline)
                    const CustomText(
                      text: 'Online',
                      fontSize: 12.0,
                      color: greenColor,
                      fontWeight: FontWeight.w500,
                    )
                  else
                    CustomText(
                      text: _formatLastSeen(otherUser?.lastSeen),
                      fontSize: 12.0,
                      color: grayColor,
                      fontWeight: FontWeight.w400,
                    ),
                ],
              ),
            ],
          );
        },
      ),
      centerTitle: false,
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Last seen yesterday';
    } else {
      return 'Last seen ${difference.inDays}d ago';
    }
  }

  Widget _buildLoadedView(BuildContext context, ConversationLoaded state) {
    final currentUserId = context.read<ConversationCubit>().currentUserId ?? '';

    return Column(
      children: [
        // Messages List
        Expanded(
          child: state.hasMessages
              ? _buildMessageList(context, state, currentUserId)
              : _buildEmptyMessages(),
        ),
        // Typing Indicator
        if (state.isOtherUserTyping)
          const Align(
            alignment: Alignment.centerLeft,
            child: TypingIndicatorBubble(),
          ),
        // Input Field

        StreamBuilder<ChatPageStatus?>(
            stream: authCubit.getUserOnlineStatusStream(otherUserId ?? ''),
            builder: (BuildContext context, AsyncSnapshot snapshot) {


              return ConversationInputFieldNew(
                controller: _messageController,
                focusNode: _focusNode,
                onChanged: (text) {
                  conversationCubit.onMessageChanged(text);
                },
                onSend: () async {
                  final text = _messageController.text;
                  if (text.trim().isEmpty) return;

                  if (!snapshot.data.isOpenChatPage) {
                    debugPrint('send-because false ${snapshot.data.isOpenChatPage}');
                    final body = {
                      'message': {
                        'token': authCubit.otherUserInfo?.deviceToken ?? '',
                        'notification': {
                          'title': 'New message from ${chatRoom.otherUser?.fullName ?? 'Guest User'}',
                          'body': _messageController.text,
                        }
                      },
                    };
                    conversationCubit.sendChatNotificationToOther(body, KString.notificationAuthToken);
                  }else{
                    debugPrint('not-send-because true ${snapshot.data.isOpenChatPage}');
                  }
                  _messageController.clear();
                  final sent = await conversationCubit.sendMessage(text);
                  if (sent) {
                    _scrollToBottom();
                  }
                },
                canSend: state.canSendMessage,
              );
            },
        ),

        /*ConversationInputFieldNew(
                controller: _messageController,
                focusNode: _focusNode,
                onChanged: (text) {
                  conversationCubit.onMessageChanged(text);
                },
                onSend: () async {
                  final text = _messageController.text;
                  if (text.trim().isEmpty) return;

                    final body = {
                      'message': {
                        'token': authCubit.otherUserInfo?.deviceToken ?? '',
                        'notification': {
                          'title': 'New message from ${chatRoom.otherUser?.fullName ?? 'Guest User'}',
                          'body': _messageController.text,
                        }
                      },
                    };
                    conversationCubit.sendChatNotificationToOther(body, KString.notificationAuthToken);

                  _messageController.clear();
                  final sent = await conversationCubit.sendMessage(text);
                  if (sent) {
                    _scrollToBottom();
                  }
                },
                canSend: state.canSendMessage,
              ),*/

      ],
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    ConversationLoaded state,
    String currentUserId,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: Utils.symmetric(h: 12.0, v: 14.0),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isFromMe = message.senderId == currentUserId;
        final showDate = _shouldShowDate(state.messages, index);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.formattedDate),
            MessageBubble(message: message, isFromMe: isFromMe),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<MessageModel> messages, int index) {
    if (index == 0) return true;

    final currentDate = messages[index].formattedDate;
    final previousDate = messages[index - 1].formattedDate;

    return currentDate != previousDate;
  }

  Widget _buildDateDivider(String date) {
    return Container(
      margin: Utils.symmetric(v: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: grayColor.withValues(alpha: 0.3))),
          Padding(
            padding: Utils.symmetric(h: 12.0),
            child: CustomText(
              text: date,
              fontSize: 12.0,
              color: grayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: Divider(color: grayColor.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
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
            text: 'No messages yet',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: grayColor,
          ),
          Utils.verticalSpace(8),
          const CustomText(
            text: 'Say hello to start the conversation!',
            fontSize: 14,
            color: grayColor,
          ),
        ],
      ),
    );
  }
}

/// Loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300] ?? Colors.grey,
      highlightColor: Colors.grey[100] ?? Colors.white,
      child: ListView.builder(
        padding: Utils.symmetric(h: 16.0, v: 14.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isFromMe = index % 2 == 0;
          return Align(
            alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: Utils.symmetric(v: 6.0),
              padding: Utils.symmetric(h: 16.0, v: 12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Utils.verticalSpace(6),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
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
            const CustomText(
              text: 'Failed to load conversation',
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
