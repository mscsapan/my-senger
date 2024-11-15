import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import 'custom_text.dart';

class FetchErrorText extends StatelessWidget {
  const FetchErrorText(
      {super.key, required this.text, this.textColor = redColor});

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomText(
        text: text,
        color: textColor,
        fontSize: 14.0,
      ),
    );
  }
}
