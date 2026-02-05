import 'package:flutter/material.dart';
import '../utils/constraints.dart';
import '../utils/k_images.dart';
import '../utils/utils.dart';

import 'custom_image.dart';
import 'custom_text.dart';
import 'primary_button.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.title,
    this.subTitle,
    this.buttonText,
    this.image,
    this.bgColor,
    this.isOneButton,
    this.child,
    this.onTap,
    this.onCancel,
    this.isShowCancelButton
  });

  final String? title;
  final String? subTitle;
  final String? buttonText;
  final String? image;
  final Color? bgColor;
  final bool? isOneButton;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final bool ? isShowCancelButton;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bgColor?? whiteColor,
      insetPadding: Utils.symmetric(h: 14.0, v: 30.0),
        shape: RoundedRectangleBorder(
          borderRadius: Utils.borderRadius(r: 16.0),
        ),
      child: Padding(
        padding: Utils.symmetric(h: 30.0,v: 25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            if(isShowCancelButton??true)...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Spacer(),
                  // const CustomText(
                  //   text: 'Refund Request',
                  //   fontSize: 22.0,
                  //   fontWeight: FontWeight.w700,
                  //   color: blackColor,
                  // ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancel?? () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                        backgroundColor: redColor,
                        maxRadius: 14.0,
                        child: const Icon(Icons.clear, color: whiteColor,size: 20.0)
                    ),
                  ),
                  // GestureDetector(
                  //     onTap: () => Navigator.of(context).pop(),
                  //     child: const Icon(Icons.clear, color: redColor)),
                ],
              ),
              Utils.verticalSpace(10.0),
            ],

            Center(child: CustomImage(path: image??KImages.done)),
            Utils.verticalSpace(20.0),
            CustomText(
                text: title?? '',
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                maxLine: 2,
              height: 1.2,
            ),
            Utils.verticalSpace(8.0),
            CustomText(
              text: subTitle?? '',
              fontSize: 16.0,
              color: grayColor,
              textAlign: TextAlign.center,
              height: 1.4,
              maxLine: 2,
            ),
           if(isOneButton??true)...[
             Utils.verticalSpace(24.0),
             PrimaryButton(text: buttonText?? 'Return to Sign In',  onPressed: onTap?? (){}),
           ]else...[
             child??const SizedBox.shrink(),
           ]
          ],
        ),
      ),
    );
  }
}
