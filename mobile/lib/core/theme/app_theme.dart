import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surfaceContainer,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        error: AppColors.error,
        onError: AppColors.onError,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.lexend(
          fontSize: 72, fontWeight: FontWeight.w900,
          color: AppColors.onBackground, letterSpacing: -2, height: 0.95,
          fontStyle: FontStyle.italic,
        ),
        displayMedium: GoogleFonts.lexend(
          fontSize: 52, fontWeight: FontWeight.w900,
          color: AppColors.onBackground, letterSpacing: -1, height: 1,
          fontStyle: FontStyle.italic,
        ),
        headlineLarge: GoogleFonts.lexend(
          fontSize: 40, fontWeight: FontWeight.w900,
          color: AppColors.onBackground, letterSpacing: -0.5,
          fontStyle: FontStyle.italic,
        ),
        headlineMedium: GoogleFonts.lexend(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: AppColors.onBackground, letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.workSans(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.workSans(fontSize: 16, height: 1.5),
        bodyMedium: GoogleFonts.workSans(fontSize: 14, height: 1.4),
        bodySmall: GoogleFonts.workSans(fontSize: 13, height: 1.4,
            color: AppColors.onSurfaceVariant),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600,
        ),
      ),

      // ── App Bar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLow,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          textStyle: GoogleFonts.workSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
          textStyle: GoogleFonts.workSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.workSans(
          color: AppColors.onSurfaceVariant, fontSize: 14,
        ),
        hintStyle: GoogleFonts.workSans(
          color: AppColors.onSurfaceVariant, fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.workSans(
          color: AppColors.onSurface, fontSize: 14,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary.withAlpha(50)
                : AppColors.surfaceContainerHighest),
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5,
        ),
        dividerColor: AppColors.outlineVariant,
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
        ),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 9, letterSpacing: 1,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Drawer ────────────────────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        width: AppSpacing.sidebarWidth,
      ),
    );
  }

  /// Alias kept for existing code that calls `AppTheme.light`.
  static ThemeData get light => dark;
}
