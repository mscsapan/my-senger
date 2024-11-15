import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';
import 'custom_text.dart';

class CustomForm extends StatelessWidget {
  final String label;
  final Widget child;
  final double bottomSpace;

  const CustomForm({
    super.key,
    required this.label,
    required this.child,
    this.bottomSpace = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontWeight: FontWeight.w500,
          color: blackColor,
        ),
        Utils.verticalSpace(10.0),
        child,
        Utils.verticalSpace(bottomSpace),
      ],
    );
  }
}
