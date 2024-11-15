import 'package:flutter/material.dart';

import '../utils/constraints.dart';

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: gray5B,
    );
  }
}
