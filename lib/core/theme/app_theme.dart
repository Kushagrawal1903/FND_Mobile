import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF2563EB),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF2563EB),
        onPrimaryContainer: Color(0xFFEEEFFF),
        secondary: Color(0xFF585F6C),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFDCE2F3),
        onSecondaryContainer: Color(0xFF5E6572),
        tertiary: Color(0xFF006229),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF007E37),
        onTertiaryContainer: Color(0xFFC1FFC5),
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF151C25),
        surfaceContainerLow: Color(0xFFEEF4FF),
        surfaceContainerHigh: Color(0xFFE2E8F5),
        surfaceContainerHighest: Color(0xFFDCE3F0),
        outline: Color(0xFF737686),
        outlineVariant: Color(0xFFE5E7EB),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF151C25)),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF737686)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF151C25),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
