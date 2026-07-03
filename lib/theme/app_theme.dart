import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KawaiiColors {
  // Primary palette
  static const Color deepPurple = Color(0xFF1A0A3C);
  static const Color midPurple = Color(0xFF2D1B69);
  static const Color lightPurple = Color(0xFF4A3580);
  static const Color sakuraPink = Color(0xFFFF6B9D);
  static const Color lightPink = Color(0xFFFFB3D1);
  static const Color softPink = Color(0xFFFFF0F5);
  static const Color lavender = Color(0xFF9F8FD8);
  static const Color softLavender = Color(0xFFE8E0FF);

  // Accent
  static const Color gold = Color(0xFFFFD700);
  static const Color softGold = Color(0xFFFFF3B0);
  static const Color teal = Color(0xFF64FFDA);
  static const Color coral = Color(0xFFFF7F7F);

  // Priority colors
  static const Color priorityLow = Color(0xFF69F0AE);
  static const Color priorityMed = Color(0xFFFFD54F);
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityUrgent = Color(0xFFFF1744);

  // Surface colors
  static const Color cardDark = Color(0xFF251550);
  static const Color cardMid = Color(0xFF2F1D60);
  static const Color inputBg = Color(0xFF1E1248);

  // Text
  static const Color textPrimary = Color(0xFFF5F0FF);
  static const Color textSecondary = Color(0xFFB8A9E0);
  static const Color textMuted = Color(0xFF7A6AA0);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KawaiiColors.deepPurple,
      colorScheme: const ColorScheme.dark(
        primary: KawaiiColors.sakuraPink,
        secondary: KawaiiColors.lavender,
        surface: KawaiiColors.cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: KawaiiColors.textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: KawaiiColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
          displayMedium: TextStyle(
            color: KawaiiColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          titleLarge: TextStyle(
            color: KawaiiColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          titleMedium: TextStyle(
            color: KawaiiColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(color: KawaiiColors.textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: KawaiiColors.textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: KawaiiColors.textMuted, fontSize: 12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KawaiiColors.deepPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: KawaiiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: KawaiiColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: KawaiiColors.cardDark,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KawaiiColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KawaiiColors.lavender, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: KawaiiColors.lavender.withAlpha(80), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: KawaiiColors.sakuraPink, width: 2),
        ),
        labelStyle: const TextStyle(color: KawaiiColors.textSecondary),
        hintStyle: const TextStyle(color: KawaiiColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KawaiiColors.sakuraPink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KawaiiColors.sakuraPink,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KawaiiColors.midPurple,
        selectedItemColor: KawaiiColors.sakuraPink,
        unselectedItemColor: KawaiiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: Color(0x144A3580),
      iconTheme: const IconThemeData(color: KawaiiColors.textSecondary),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KawaiiColors.sakuraPink;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: KawaiiColors.lavender, width: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KawaiiColors.sakuraPink;
          }
          return KawaiiColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KawaiiColors.sakuraPink.withAlpha(100);
          }
          return KawaiiColors.cardMid;
        }),
      ),
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [KawaiiColors.sakuraPink, KawaiiColors.lavender],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get bgGradient => const LinearGradient(
        colors: [KawaiiColors.deepPurple, Color(0xFF0D0720)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static BoxDecoration get glassCard => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(30),
            Colors.white.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
      );
}
