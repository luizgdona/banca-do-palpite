import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.green,
          onPrimary: AppColors.offWhite,
          secondary: AppColors.amber,
          onSecondary: AppColors.green,
          surface: AppColors.cream,
          onSurface: AppColors.darkText,
          error: AppColors.liveBadge,
          onError: AppColors.offWhite,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: GoogleFonts.barlowCondensed(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.barlowCondensed(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
          ),
          headlineLarge: GoogleFonts.barlowCondensed(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
          headlineMedium: GoogleFonts.barlowCondensed(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
          titleLarge: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.dmSans(fontSize: 16),
          bodyMedium: GoogleFonts.dmSans(fontSize: 14),
          bodySmall: GoogleFonts.dmSans(fontSize: 13),
          labelSmall: GoogleFonts.barlowCondensed(fontSize: 12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.offWhite,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.barlowCondensed(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.offWhite,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amber,
            foregroundColor: AppColors.green,
            textStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.green,
            side: const BorderSide(color: AppColors.green, width: 1.5),
            textStyle: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        cardTheme: const CardTheme(
          color: AppColors.green,
          elevation: 4,
          shadowColor: Color(0x40000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.greenLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.amber, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.liveBadge, width: 1.5),
          ),
          labelStyle: GoogleFonts.dmSans(color: AppColors.mutedDark),
          hintStyle: GoogleFonts.dmSans(color: AppColors.mutedDark),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.green,
          contentTextStyle: GoogleFonts.dmSans(color: AppColors.offWhite),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
