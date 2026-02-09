import 'package:flutter/material.dart';

import '../../../../data/models/chat/message_model.dart';
import '../../../utils/constraints.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_text.dart';

/// Message bubble widget for displaying chat messages
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
  });

  final MessageModel message;
  final bool isFromMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: Utils.symmetric(
          v: 4.0,
        ).copyWith(left: isFromMe ? 60.0 : 0.0, right: isFromMe ? 0.0 : 60.0),
        padding: Utils.symmetric(h: 14.0, v: 10.0),
        decoration: BoxDecoration(
          color: isFromMe ? primaryColor.withValues(alpha: 0.9) : disableColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isFromMe ? 16.0 : 4.0),
            bottomRight: Radius.circular(isFromMe ? 4.0 : 16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: blackColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message content
            _buildMessageContent(),
            Utils.verticalSpace(4.0),
            // Time and read status
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: message.formattedTime,
                  fontSize: 11.0,
                  color: isFromMe
                      ? whiteColor.withValues(alpha: 0.7)
                      : grayColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
                if (isFromMe) ...[
                  Utils.horizontalSpace(4.0),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? Colors.lightBlueAccent
                        : whiteColor.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.text:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return CustomText(
      text: message.content,
      fontSize: 15.0,
      color: isFromMe ? whiteColor : blackColor,
      fontWeight: FontWeight.w400,
      maxLine: 100,
    );
  }

  Widget _buildImageMessage() {
    // Placeholder for image messages
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
          decoration: BoxDecoration(
            color: grayColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.content,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: grayColor.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.broken_image,
                    color: grayColor,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isFromMe
                ? whiteColor.withValues(alpha: 0.2)
                : primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: isFromMe ? whiteColor : primaryColor,
            size: 24,
          ),
        ),
        Utils.horizontalSpace(8),
        Flexible(
          child: CustomText(
            text: message.content,
            fontSize: 14.0,
            color: isFromMe ? whiteColor : blackColor,
            maxLine: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
