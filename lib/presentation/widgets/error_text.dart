import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';
import 'custom_text.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? redColor;
    return Padding(
      padding: Utils.symmetric(h: 0, v: 5.0),
      child: CustomText(
        text: "* $text",
        color: c,
      ),
    );
  }
}
