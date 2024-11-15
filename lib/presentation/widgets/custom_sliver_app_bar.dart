import 'package:flutter/material.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';
import 'custom_app_bar.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar(
      {super.key,
      required this.title,
      this.height = 80.0,
      this.action = const [SizedBox()]});

  final double height;
  final String title;
  final List<Widget> action;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: grayBackgroundColor,
      automaticallyImplyLeading: false,
      toolbarHeight: Utils.vSize(height),
      pinned: true,
      title: CustomAppBar(title: title),
      actions: action,
    );
  }
}
