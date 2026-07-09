import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Blues (from report UI)
  static const Color primaryBlue = Color(0xff3b82a6);
  static const Color darkBlue = Color(0xff2f6d8e);
  static const Color lightBlue = Color(0xff4aa3d3);
  static const Color deepBlue = Color(0xff1e4e6b);

  // Backgrounds
  static const Color bgLight = Color(0xfff2f2f2);
  static const Color bgGrey = Color(0xffeeeeee);
  static const Color cardGrey = Color(0xffcfcfcf);

  // Accents
  static const Color accentRed = Color(0xffE53935);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightBlue, deepBlue],
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryBlue, darkBlue],
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.bgLight,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      primary: AppColors.primaryBlue,
      secondary: AppColors.lightBlue,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentRed,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}
