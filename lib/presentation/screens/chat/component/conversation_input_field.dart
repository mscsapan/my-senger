import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/constraints.dart';
import '../../../utils/k_images.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';

/// Updated conversation input field with send functionality
class ConversationInputFieldNew extends StatelessWidget {
  const ConversationInputFieldNew({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSend,
    this.canSend = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onSend;
  final bool canSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Utils.symmetric(v: 8.0, h: 12.0).copyWith(bottom: 12.0),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text Input
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.roboto(
                        fontSize: 15.0,
                        color: blackColor,
                      ),
                      maxLines: null,
                      onChanged: onChanged,
                      // onFieldSubmitted: (_) {
                      //   if (canSend) onSend();
                      // },
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        // hintText: 'Message',
                        hintStyle: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: blackColor,
                        ),
                        contentPadding: Utils.symmetric(h: 16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        suffixIcon: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  // Emoji/Attachment button (placeholder)
                  // IconButton(
                  //   icon: Icon(Icons.attach_file, color: grayColor),
                  //   onPressed: () {},
                  // ),
                ],
              ),
            ),
            Utils.horizontalSpace(8.0),
            // Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: canSend ? onSend : null,
                child: Container(
                  height: 48.0,
                  width: 48.0,
                  decoration: BoxDecoration(
                    color: canSend
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: Utils.all(value: 12.0),
                  child: CustomImage(path: KImages.sendIcon, color: whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legacy conversation input field (kept for backward compatibility)
class ConversationInputField extends StatelessWidget {
  ConversationInputField({super.key});

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Utils.symmetric(v: 8.0, h: 12.0).copyWith(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 14.0),
              onChanged: (String text) {},
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: blackColor,
                ),
                contentPadding: Utils.symmetric(h: 14.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: const BorderSide(color: borderColor),
                ),
                suffixIcon: const SizedBox.shrink(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 48.0,
              width: 48.0,
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              margin: Utils.only(left: 10.0),
              padding: Utils.all(value: 12.0),
              child: CustomImage(path: KImages.sendIcon),
            ),
          ),
        ],
      ),
    );
  }
}
