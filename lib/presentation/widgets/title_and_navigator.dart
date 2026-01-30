import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import 'custom_text.dart';

class TitleAndNavigator extends StatelessWidget {
  const TitleAndNavigator({
    super.key,
    required this.title,
    required this.press,
    this.isSeeAll = true,
    this.textColors = blackColor,
    this.seeAllColors = blueColor,
  });

  final String title;
  final VoidCallback press;
  final bool isSeeAll;
  final Color textColors;
  final Color seeAllColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: title,
          color: textColors,
          fontSize: 22.0,

          fontWeight: FontWeight.w600,
        ),
        isSeeAll
            ? GestureDetector(
                onTap: press,
                child: CustomText(text: 'See All', color: seeAllColors),
              )
            : const SizedBox(),
        //Utils.horizontalSpace(6),
        //const Icon(Icons.arrow_forward, color: primaryColor),
      ],
    );
  }
}
