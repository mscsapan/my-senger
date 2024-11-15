import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';
import 'custom_text.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onTap,
    this.horSpace = 24.0,
    this.bgColor = Colors.transparent,
    this.textColor = blackColor,
    this.iconColor = blackColor,
    this.visibleLeading = true,
    this.iconBgColor = primaryColor,
    this.action = const [],
  });
  final String title;
  final double horSpace;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  final bool visibleLeading;
  final Color iconBgColor;
  final Function()? onTap;
  final List<Widget> action;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: bgColor,
      centerTitle: true,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (visibleLeading)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_sharp,
                size: 26.0,
                color: Color(0xFF040415),
              ),
            ),
          // Utils.horizontalSpace(horSpace),
          const Spacer(),
          CustomText(
            text: title,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          const Spacer(),
        ],
      ),
      actions: action,
      toolbarHeight: Utils.vSize(70.0),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Utils.vSize(70.0));
}


class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.maybePop(context),
      child: Container(
        margin: Utils.only(left: 10.0),
        //padding: Utils.all(value: 10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
            border: Border.all(color: stockColor)
        ),
        child: Padding(
          padding: Utils.only(left: 6.0),
          child: const Icon(Icons.arrow_back_ios,color: blackColor),
        ),
      ),
    );
  }
}

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
    required this.title,
    this.isShowBackButton = true,
    this.textSize = 22.0,
    this.fontWeight = FontWeight.w700,
    this.textColor = blackColor,
    this.height = 60.0,
  });

  final String title;
  final bool isShowBackButton;
  final double textSize;
  final FontWeight fontWeight;
  final Color textColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: scaffoldBgColor,
      leadingWidth: 60.0,
      leading: const BackButtonWidget(),
      title:  CustomText(
        text: title,
        fontSize: textSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
    );
  }

  // Row buildRow() {
  //   return Row(
  //   children: [
  //     isShowBackButton ? const BackButtonWidget() : const SizedBox(),
  //     CustomText(
  //       text: title,
  //       fontSize: textSize,
  //       fontWeight: fontWeight,
  //       color: textColor,
  //     )
  //   ],
  // );
  // }

  @override
  Size get preferredSize => Size(double.infinity, height);
}
