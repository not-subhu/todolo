import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour tokens ──────────────────────────────────────────────────────────
class ScreechColors {
  // Backgrounds
  static const Color bg          = Color(0xFF0A0812);
  static const Color bgCard      = Color(0xFF130F1E);
  static const Color bgPanel     = Color(0xFF0F0C1A);

  // Primary purple family
  static const Color primary     = Color(0xFF7C3AED);
  static const Color primaryLit  = Color(0xFF9F67F5);
  static const Color primaryDim  = Color(0xFF4C1D95);
  static const Color accent      = Color(0xFF6D28D9);

  // Semantic
  static const Color gold        = Color(0xFFF59E0B);
  static const Color goldLight   = Color(0xFFFBBF24);
  static const Color danger      = Color(0xFFEF4444);
  static const Color success     = Color(0xFF22C55E);
  static const Color warning     = Color(0xFFF97316);

  // Priority
  static const Color prioLow     = Color(0xFF22C55E);
  static const Color prioMed     = Color(0xFFF59E0B);
  static const Color prioHigh    = Color(0xFFEF4444);
  static const Color prioUrgent  = Color(0xFFFF1744);

  // Text
  static const Color textPrimary   = Color(0xFFF0EAF8);
  static const Color textSecondary = Color(0xFF9D8FB8);
  static const Color textMuted     = Color(0xFF5C5074);

  // Glass
  static const Color glassBorder   = Color(0x22FFFFFF);
  static const Color glassFill     = Color(0x10FFFFFF);

  // ── Backward-compat aliases (old KawaiiColors names → new tokens) ──────
  static const Color sakuraPink    = Color(0xFFB983FF);  // bright lilac-pink
  static const Color lavender      = Color(0xFF1E1730);  // card-level lavender bg
  static const Color deepPurple    = primary;
  static const Color coral         = Color(0xFFFF6B6B);  // warm red-orange
  static const Color cardMid       = bgCard;
  static const Color cardDark      = bgPanel;
  static const Color inputBg       = bgPanel;
  static const Color priorityLow    = prioLow;
  static const Color priorityMed   = prioMed;
  static const Color priorityHigh  = prioHigh;
  static const Color priorityUrgent = prioUrgent;
  static const Color teal          = Color(0xFF14B8A6);
  static const Color lightPink     = Color(0xFFFF93C7);

  // bgGradient helper used by older screens
  static LinearGradient get bgGradient => const LinearGradient(
        colors: [Color(0xFF1A0A3C), bg],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}

// ── Theme ──────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ScreechColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: ScreechColors.primary,
        secondary: ScreechColors.primaryLit,
        surface: ScreechColors.bgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ScreechColors.textPrimary,
        error: ScreechColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: ScreechColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 32, letterSpacing: -1),
          displayMedium: TextStyle(color: ScreechColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 26, letterSpacing: -0.5),
          titleLarge: TextStyle(color: ScreechColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          titleMedium: TextStyle(color: ScreechColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: TextStyle(color: ScreechColors.textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: ScreechColors.textSecondary, fontSize: 13),
          bodySmall: TextStyle(color: ScreechColors.textMuted, fontSize: 12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: ScreechColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: ScreechColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: ScreechColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ScreechColors.bgPanel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ScreechColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ScreechColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ScreechColors.primary, width: 2)),
        labelStyle: const TextStyle(color: ScreechColors.textSecondary),
        hintStyle: const TextStyle(color: ScreechColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ScreechColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ScreechColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      dividerColor: ScreechColors.glassBorder,
      iconTheme: const IconThemeData(color: ScreechColors.textSecondary),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? ScreechColors.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: ScreechColors.textMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : ScreechColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? ScreechColors.primary : ScreechColors.bgPanel),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F0FF),
      colorScheme: const ColorScheme.light(
        primary: ScreechColors.primary,
        secondary: ScreechColors.primaryLit,
        surface: Colors.white,
        onPrimary: Colors.white,
        error: ScreechColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [ScreechColors.primary, ScreechColors.primaryLit],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get headerGradient => const LinearGradient(
        colors: [Color(0xFF1A0A3C), Color(0xFF0A0812)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // Glass card decoration — glassLevel 0..1 controls opacity/blur
  static BoxDecoration glassCardWith({double glassLevel = 0.5, double radius = 16}) {
    final fill = (glassLevel * 20).round();
    final border = (glassLevel * 40).round();
    return BoxDecoration(
      color: Color.fromARGB(fill.clamp(6, 30), 255, 255, 255),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Color.fromARGB(border.clamp(15, 60), 255, 255, 255),
        width: 1,
      ),
    );
  }

  // Backward-compat getter used by older screens
  static BoxDecoration get glassCard => glassCardWith();

  // Priority colour
  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low': return ScreechColors.prioLow;
      case 'high': return ScreechColors.prioHigh;
      case 'urgent': return ScreechColors.prioUrgent;
      default: return ScreechColors.prioMed;
    }
  }
}

// Backward-compatibility alias — older screens that still reference KawaiiColors
// compile without changes while we migrate incrementally.
typedef KawaiiColors = ScreechColors;
