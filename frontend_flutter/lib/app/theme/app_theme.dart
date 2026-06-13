import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1558F3);
  static const Color primaryBlueDark = Color(0xFF003366);
  static const Color primaryBlueLight = Color(0xFFEBF2FF);
  static const Color navyText = Color(0xFF003366);

  static const Color accentOrange = Color(0xFFF37022);
  static const Color accentOrangeHover = Color(0xFFD85D15);
  static const Color accentOrangeLight = Color(0xFFFFF5F0);

  static const Color accentGreen = Color(0xFF00A651);
  static const Color accentGreenLight = Color(0xFFE6FBF1);

  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color bgBody = Color(0xFFF4F6F9);

  // Light Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: primaryBlueLight,
    onPrimaryContainer: primaryBlueDark,
    secondary: accentOrange,
    onSecondary: Colors.white,
    secondaryContainer: accentOrangeLight,
    onSecondaryContainer: accentOrangeHover,
    tertiary: accentGreen,
    onTertiary: Colors.white,
    error: Color(0xFFEF4444),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: textDark,
    onSurfaceVariant: textMuted,
    outline: Color(0xFFE5E7EB),
    shadow: Color(0x0F02509B),
  );

  // Dark Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8), // Light blue for dark mode
    onPrimary: Color(0xFF090D16),
    primaryContainer: Color(0xFF1E293B),
    onPrimaryContainer: Color(0xFFF8FAFC),
    secondary: Color(0xFFFB923C), // Orange gold
    onSecondary: Color(0xFF090D16),
    secondaryContainer: Color(0xFF1B263F),
    onSecondaryContainer: Color(0xFFFFF5F0),
    tertiary: Color(0xFF10B981), // Teal
    onTertiary: Color(0xFF090D16),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    surface: Color(0xFF131C2E), // Premium Card
    onSurface: Color(0xFFF8FAFC),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFF1E293B),
    shadow: Colors.black54,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.bgBody,
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF020617),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: const Color(0xFFF1F5F9)),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF1F5F9),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFF1F5F9),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF131C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF38BDF8),
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
