import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';
import 'custom_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.maximumSize = const Size(double.infinity, 44.0),
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    required this.onPressed,
    this.textColor = whiteColor,
    this.bgColor = blackColor,
    this.borderColor = primaryColor,
    this.minimumSize = const Size(double.infinity, 44.0),
    this.borderRadiusSize = 4.0,
    this.buttonType = ButtonType.elevated,
    this.padding,
    this.icon,
    this.maxLine,
    this.isGradient = true,
  });

  final VoidCallback? onPressed;

  final String text;
  final Size maximumSize;
  final Size minimumSize;
  final double fontSize;
  final double borderRadiusSize;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final ButtonType buttonType;
  final EdgeInsets? padding;
  final Widget? icon;
  final FontWeight fontWeight;
  final int? maxLine;
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    final p = padding ?? Utils.all(value: 0.0);
    final tempIcon = icon ?? const Icon(Icons.add);
    final borderRadius = BorderRadius.circular(borderRadiusSize);
    if (buttonType == ButtonType.iconButton) {
      return Padding(
        padding: p,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: tempIcon,
          label: Padding(
            padding: p,
            child: CustomText(
              text: text,
              color: textColor,
              fontSize: fontSize.sp,
              height: 1.5.h,
              fontWeight: fontWeight,
              maxLine: maxLine ?? 1,
              textAlign: TextAlign.center,
            ),
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(bgColor),
            splashFactory: NoSplash.splashFactory,
            shadowColor: WidgetStateProperty.all(transparent),
            overlayColor: WidgetStateProperty.all(transparent),
            elevation: WidgetStateProperty.all(0.0),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(color: borderColor))),
            minimumSize: WidgetStateProperty.all(minimumSize),
            maximumSize: WidgetStateProperty.all(maximumSize),
          ),
        ),
      );
    } else if (buttonType == ButtonType.outlined) {
      return Padding(
        padding: p,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(transparent),
            splashFactory: NoSplash.splashFactory,
            shadowColor: WidgetStateProperty.all(transparent),
            overlayColor: WidgetStateProperty.all(transparent),
            elevation: WidgetStateProperty.all(0.0),
            side: WidgetStateProperty.all(
                BorderSide(color: borderColor, width: 0.4)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(color: borderColor))),
            minimumSize: WidgetStateProperty.all(minimumSize),
            maximumSize: WidgetStateProperty.all(maximumSize),
          ),
          child: Padding(
            padding: Utils.only(bottom: 0.0),
            child: CustomText(
              text: text,
              color: textColor,
              fontSize: fontSize.sp,
              height: 1.5.h,
              fontWeight: fontWeight,
              maxLine: maxLine ?? 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (buttonType == ButtonType.gradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: borderRadius,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(bgColor),
            splashFactory: NoSplash.splashFactory,
            shadowColor: WidgetStateProperty.all(transparent),
            overlayColor: WidgetStateProperty.all(transparent),
            elevation: WidgetStateProperty.all(0.0),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: borderRadius)),
            minimumSize: WidgetStateProperty.all(minimumSize),
            maximumSize: WidgetStateProperty.all(maximumSize),
          ),
          child: CustomText(
            text: text,
            color: textColor,
            fontSize: fontSize.sp,
            height: 1.5.h,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Padding(
        padding: p,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(bgColor),
            // splashFactory: NoSplash.splashFactory,
            shadowColor: WidgetStateProperty.all(transparent),
            overlayColor: WidgetStateProperty.all(transparent),
            elevation: WidgetStateProperty.all(0.0),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: borderRadius)),
            minimumSize: WidgetStateProperty.all(minimumSize),
            maximumSize: WidgetStateProperty.all(maximumSize),
          ),
          child: Padding(
            padding: p,
            child: CustomText(
              text: text,
              color: textColor,
              fontSize: fontSize,
              height: 1.5,
              fontWeight: fontWeight,
              maxLine: maxLine ?? 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}

enum ButtonType { elevated, outlined, iconButton, gradient }
