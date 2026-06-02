import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
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

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.barlowCondensed(
          fontSize: 52,
          fontWeight: FontWeight.w900,
          color: AppColors.darkText,
          letterSpacing: -1,
          height: 1,
        ),
        displayMedium: GoogleFonts.barlowCondensed(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: AppColors.darkText,
          letterSpacing: -0.5,
          height: 1,
        ),
        headlineLarge: GoogleFonts.barlowCondensed(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          letterSpacing: -0.3,
          height: 1.1,
        ),
        headlineMedium: GoogleFonts.barlowCondensed(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
          letterSpacing: -0.2,
          height: 1.1,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, height: 1.4),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, height: 1.4),
        bodySmall: GoogleFonts.dmSans(fontSize: 13, height: 1.4),
        labelSmall: GoogleFonts.barlowCondensed(
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),

      // ── App Bar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.offWhite,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: AppColors.shadowDark,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.barlowCondensed(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.offWhite,
          letterSpacing: 0.3,
          height: 1,
        ),
        iconTheme: const IconThemeData(color: AppColors.offWhite),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.green,
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: AppColors.mutedDark,
          textStyle: GoogleFonts.barlowCondensed(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          elevation: 2,
          shadowColor: AppColors.amberDark.withAlpha(80),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.green, width: 1.5),
          textStyle: GoogleFonts.barlowCondensed(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.green,
        elevation: 0,  // we apply our own shadow via BoxDecoration
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.liveBadge, width: 2),
        ),
        labelStyle: GoogleFonts.dmSans(
          color: AppColors.mutedDark,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.mutedDark,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.greenDark,
        contentTextStyle: GoogleFonts.dmSans(
          color: AppColors.offWhite,
          fontSize: 14,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.amber;
          return AppColors.mutedDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.amber.withAlpha(60);
          }
          return AppColors.divider;
        }),
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.amber,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.amber,
        unselectedLabelColor: AppColors.mutedText,
        labelStyle: GoogleFonts.barlowCondensed(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        unselectedLabelStyle: GoogleFonts.barlowCondensed(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        dividerColor: Colors.transparent,
      ),
    );
  }
}
