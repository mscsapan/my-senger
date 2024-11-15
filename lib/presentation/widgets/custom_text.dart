import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.w400,
    this.fontSize = 14.0,
    this.height = 1.4,
    this.maxLine = 20,
    this.color = blackColor,
    this.decoration = TextDecoration.none,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final TextAlign textAlign;
  final int maxLine;
  final TextOverflow overflow;
  final TextDecoration decoration;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Utils.only(bottom: 2.0),
      child: Text(
        text,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLine,
        style: GoogleFonts.ibmPlexSansDevanagari(
          fontWeight: fontWeight,
          fontSize: fontSize.sp,
          color: color,
          height: height.h,
          decoration: decoration,
        ),
      ),
    );
  }
}
