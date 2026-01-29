import 'package:flutter/material.dart';

import '../utils/constraints.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color = primaryColor});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color),
    );
  }
}

class UpdateWidget extends StatelessWidget {
  const UpdateWidget({super.key, this.color = primaryColor});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: color,strokeWidth: 4.0,),
      ],
    );
  }
}
