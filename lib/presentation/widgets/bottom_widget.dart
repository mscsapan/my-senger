import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';

class BottomWidget extends StatelessWidget {
  const BottomWidget({super.key, required this.child, this.margin});

  final Widget child;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Utils.only(
        left: 16.0,
        right: 16.0,
        top: 14.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: defaultDecoration,
      margin: margin?? Utils.symmetric(h: 0.0, v: 0.0).copyWith(bottom: 16.0),
      child: child,
    );
  }
}
