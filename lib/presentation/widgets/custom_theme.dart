import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';

class MyTheme {
  static final borderRadius = BorderRadius.circular(6.0);
  static final theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: whiteColor,
      scaffoldBackgroundColor: scaffoldBgColor,
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        titleTextStyle: GoogleFonts.roboto(
            color: blackColor, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: blackColor),
        elevation: 0,
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        TextTheme(
          bodySmall: GoogleFonts.roboto(fontSize: 12.0),
          bodyLarge: GoogleFonts.roboto(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              height: 2.16,
              color: blackColor),
          bodyMedium: GoogleFonts.roboto(fontSize: 14.0),
          labelLarge:
              GoogleFonts.roboto(fontSize: 16.0, fontWeight: FontWeight.w600),
          titleLarge:
              GoogleFonts.roboto(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 42.0),
          backgroundColor: whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
            shadowColor: WidgetStatePropertyAll(transparent),
            elevation: WidgetStatePropertyAll(0.0),
            iconSize: WidgetStatePropertyAll(20.0),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStatePropertyAll(
              (transparent),
            ),
            padding: WidgetStatePropertyAll(EdgeInsets.zero)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 3,
        backgroundColor: whiteColor,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          color: grayColor,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          color: blackColor,
          fontSize: 14.0,
        ),
        selectedItemColor: grayColor,
        unselectedItemColor: blackColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        hintStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
          color: const Color(0xFFBABABA),
        ),
        labelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w400, fontSize: 15.0, color: blackColor),
        contentPadding: Utils.symmetric(v: 6.0, h: 20.0),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        fillColor: filledColor,
        filled: true,
        //focusColor: primaryColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: blackColor,
        selectionColor: blueColor.withValues(alpha: 0.4),
        selectionHandleColor: primaryColor,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: primaryColor));
}
