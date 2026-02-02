import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Set to true in tests to disable/bypass animations
  static bool isTestMode = false;

  // ===========================================================================
  // 🎨 Color Palettes
  // ===========================================================================

  // 🌞 Light Mode Colors ("Morning Sun")
  static const Color _lightBackground = Color(0xFFFAF9F6); // Off-White / Cream
  static const Color _lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color _lightPrimary = Color(0xFF88B896); // Soft Sage
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightSecondary = Color(0xFF9D84B7); // Muted Lavender
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF2D3436); // Dark Grey
  static const Color _lightTextSecondary = Color(0xFF636E72);
  static const Color _lightError = Color(0xFFFF8A80); // Soft Red
  static const Color _lightInputFill = Color(0xFFF0F2F5); // Very Light Grey

  // 🌙 Dark Mode Colors ("Midnight Calm")
  static const Color _darkBackground = Color(0xFF1C1C1E); // Deep Gunmetal / Dark Slate
  static const Color _darkSurface = Color(0xFF2C2C2E); // Charcoal
  // Subtly lighter border for dark mode surface to create depth without shadow
  static const Color _darkSurfaceBorder = Color(0x1AFFFFFF); // 10% White
  static const Color _darkPrimary = Color(0xFFA8D8B6); // Desaturated Sage (Glowing)
  static const Color _darkOnPrimary = Color(0xFF1C1C1E);
  static const Color _darkSecondary = Color(0xFFB5A3C9); // Desaturated Lavender
  static const Color _darkOnSecondary = Color(0xFF1C1C1E);
  static const Color _darkText = Color(0xFFE5E5E5); // Off-White
  static const Color _darkTextSecondary = Color(0xFFA0A0A0);
  static const Color _darkError = Color(0xFFE57373); // Muted Red
  static const Color _darkInputFill = Color(0xFF3A3A3C); // Lighter Charcoal

  // ===========================================================================
  // 📐 Shape & Geometry
  // ===========================================================================
  static const double _borderRadiusSmall = 12.0;
  static const double _borderRadiusMedium = 16.0;
  static const double _borderRadiusLarge = 24.0;

  // ===========================================================================
  // 🌞 Light Theme Definition
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        secondary: _lightSecondary,
        onSecondary: _lightOnSecondary,
        error: _lightError,
        onError: Colors.white,
        surface: _lightSurface,
        onSurface: _lightText,
        background: _lightBackground,
        onBackground: _lightText,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: _lightText,
        displayColor: _lightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _lightText),
        titleTextStyle: TextStyle(
          color: _lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05), // Soft, warm shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 2,
          shadowColor: _lightPrimary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: _lightError, width: 1.5),
        ),
        hintStyle: TextStyle(color: _lightTextSecondary),
      ),
      iconTheme: const IconThemeData(
        color: _lightPrimary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        color: _lightTextSecondary.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }

  // ===========================================================================
  // 🌙 Dark Theme Definition
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        error: _darkError,
        onError: _darkBackground,
        surface: _darkSurface,
        onSurface: _darkText,
        background: _darkBackground,
        onBackground: _darkText,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _darkText),
        titleTextStyle: TextStyle(
          color: _darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0, // No shadow in dark mode
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          side: const BorderSide(color: _darkSurfaceBorder, width: 1), // Gentle border
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary.withOpacity(0.9), // Slightly muted fill
          foregroundColor: _darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: _darkPrimary, width: 1), // Thinner border in dark mode
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMedium),
          borderSide: BorderSide(color: _darkError, width: 1.5),
        ),
        hintStyle: TextStyle(color: _darkTextSecondary),
      ),
      iconTheme: const IconThemeData(
        color: _darkPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: _darkTextSecondary.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  // ===========================================================================
  // 🔗 Legacy Aliases (For Backward Compatibility)
  // ===========================================================================
  static const Color primary = _lightPrimary;
  static const Color secondary = _lightSecondary;
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color error = _lightError;
}

// ===========================================================================
// 🧩 Extensions for Easy Access
// ===========================================================================
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isLight => theme.brightness == Brightness.light;
}
