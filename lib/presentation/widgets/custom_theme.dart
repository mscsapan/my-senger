import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constraints.dart';
import '../utils/utils.dart';

class MyTheme {
  static final borderRadius = BorderRadius.circular(10.0);
  static final theme = ThemeData(
      //brightness: Brightness.light,
      primaryColor: whiteColor,
      scaffoldBackgroundColor: scaffoldBgColor,
      // bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
      // colorScheme: const ColorScheme.light(secondary: lightningYellowColor),
      appBarTheme: AppBarTheme(
        backgroundColor: greenColor,
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        titleTextStyle: GoogleFonts.ibmPlexSansDevanagari(
            color: blackColor, fontSize: 20.0, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: blackColor),
        elevation: 0,
      ),
      textTheme: GoogleFonts.ibmPlexSansDevanagariTextTheme(
        TextTheme(
          bodySmall:
              GoogleFonts.ibmPlexSansDevanagari(fontSize: 12, height: 1.83),
          bodyLarge: GoogleFonts.ibmPlexSansDevanagari(
              fontSize: 16, fontWeight: FontWeight.w500, height: 1.375),
          bodyMedium:
              GoogleFonts.ibmPlexSansDevanagari(fontSize: 14, height: 1.5714),
          labelLarge: GoogleFonts.ibmPlexSansDevanagari(
              fontSize: 16, height: 2, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.ibmPlexSansDevanagari(
              fontSize: 16, height: 2, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          backgroundColor: whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
        selectedLabelStyle: GoogleFonts.ibmPlexSansDevanagari(
          fontWeight: FontWeight.w600,
          color: primaryColor,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: GoogleFonts.ibmPlexSansDevanagari(
          fontWeight: FontWeight.w600,
          color: grayColor,
          fontSize: 14.0,
        ),
        selectedItemColor: primaryColor,
        unselectedItemColor: grayColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        hintStyle: GoogleFonts.ibmPlexSansDevanagari(
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
          color: grayColor,
        ),
        labelStyle: GoogleFonts.ibmPlexSansDevanagari(
          fontWeight: FontWeight.w400,
          fontSize: 16.0,
          color: inputTextColor,
        ),
        contentPadding: Utils.symmetric(v: 20.0),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        fillColor: whiteColor,
        //fillColor: fillColor,
        filled: true,
        focusColor: primaryColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: blackColor,
        selectionColor: blackColor,
        selectionHandleColor: blackColor,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: Utils.borderRadius(r: 6.0)),
        insetPadding: Utils.symmetric(),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: primaryColor));
}
