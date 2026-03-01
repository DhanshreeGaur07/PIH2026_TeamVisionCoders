import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── ScrapCrafters Neo Brutalism Design System ───
/// Light-mode, bold borders, hard shadows, flat colors, premium typography.
class AppTheme {
  AppTheme._();

  // ─── Core Palette ─────────────────────────────
  static const Color background = Color(0xFFFAFAF9); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceLight = Color(0xFFF5F5F4); // Muted fill areas
  static const Color border = Color(0xFF1C1917); // Near-black borders
  static const Color borderLight = Color(0xFFD6D3D1); // Subtle dividers
  static const Color shadow = Color(0xFF1C1917); // Hard shadow color

  static const Color primary = Color(0xFF0D9488); // Muted teal
  static const Color primaryDark = Color(0xFF0F766E); // Teal dark
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color accent = Color(0xFFF59E0B); // Amber (coins/money)
  static const Color danger = Color(0xFFDC2626); // Red
  static const Color warning = Color(0xFFEA580C); // Orange
  static const Color success = Color(0xFF16A34A); // Green

  static const Color textPrimary = Color(0xFF0F172A); // Near-black
  static const Color textSecondary = Color(0xFF475569); // Slate
  static const Color textMuted = Color(0xFF94A3B8); // Light slate

  // Legacy aliases (keep to avoid breaking screens that reference these)
  static const Color cardGlass = surfaceLight;
  static const Color cardGlassBorder = borderLight;

  // ─── Neo Brutal Decoration ────────────────────
  static BoxDecoration brutalDecoration({
    double borderRadius = 8,
    Color? bgColor,
    double borderWidth = 2,
    double shadowOffset = 4,
  }) {
    return BoxDecoration(
      color: bgColor ?? surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadow,
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
        ),
      ],
    );
  }

  // ─── Theme Data ───────────────────────────────
  static ThemeData get darkTheme => theme;
  static ThemeData get theme {
    final base = ThemeData.light();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return const IconThemeData(color: primary, size: 24);
          return const IconThemeData(color: textMuted, size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary,
          foregroundColor: surface,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: border, width: 2),
          ),
          elevation: 0,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.spaceGrotesk(color: textMuted),
        prefixIconColor: textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        secondaryLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        side: const BorderSide(color: border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 2),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: surface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: borderLight, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 2),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ─── Responsive Helpers ───────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double responsivePadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  static int responsiveGridCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }
}
