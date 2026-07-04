import 'package:flutter/material.dart';

/// TotalSkillz app theme — exactly matching the website's CSS design system
///
/// CSS mapping reference:
///   Dark theme  →  [data-theme="dark"] overrides in style.css
///   Light theme →  :root defaults in style.css
class AppTheme {
  // ─── Brand / Primary (CSS --primary family) ─────────────────────────────
  /// `--primary: #4f46e5`  (Indigo-600)
  static const Color primary      = Color(0xFF4F46E5);
  /// `--primary-dark: #4338ca`
  static const Color primaryDark  = Color(0xFF4338CA);
  /// `--primary-light: #818cf8`
  static const Color primaryLight = Color(0xFF818CF8);
  /// `--primary-pale` dark: `#1e1b4b`
  static const Color primaryPale  = Color(0xFF1E1B4B);
  /// `--secondary: #6366f1`
  static const Color secondary    = Color(0xFF6366F1);

  // ─── Accent colours (CSS --accent-* family) ──────────────────────────────
  /// `--accent-green: #10b981`  (Emerald-500)
  static const Color success      = Color(0xFF10B981);
  /// `--accent-amber: #f59e0b`  (Amber-500)
  static const Color warning      = Color(0xFFF59E0B);
  /// `--accent-red: #ef4444`    (Red-500)
  static const Color error        = Color(0xFFEF4444);
  /// Additional semantic — no CSS counterpart, kept for Flutter widgets
  static const Color info         = Color(0xFF6366F1); // maps to --secondary

  // ─── Accent light variants (dark-mode overrides) ─────────────────────────
  static const Color successLight = Color(0xFF064E3B); // --accent-green-light dark
  static const Color warningLight = Color(0xFF78350F); // --accent-amber-light dark
  static const Color errorLight   = Color(0xFF7F1D1D); // --accent-red-light dark

  // ─── Dark theme backgrounds (CSS [data-theme="dark"]) ────────────────────
  /// `--bg: #000000` dark
  static const Color bg            = Color(0xFF000000);
  /// `--bg-card: #111111` dark
  static const Color surface       = Color(0xFF111111);
  /// `--bg-elevated: #111111` dark
  static const Color surface2      = Color(0xFF111111);
  /// No direct CSS counterpart — slightly elevated for modals/dialogs
  static const Color surfaceElevated = Color(0xFF1A1A1A);

  // ─── Text (CSS dark mode) ────────────────────────────────────────────────
  /// `--text: #f1f5f9` dark
  static const Color text         = Color(0xFFF1F5F9);
  /// `--text-secondary: #94a3b8` dark
  static const Color textSubtle   = Color(0xFF94A3B8);
  /// `--text-muted: #64748b` dark
  static const Color textMuted    = Color(0xFF64748B);

  // ─── Borders (CSS dark mode) ─────────────────────────────────────────────
  /// `--border: #334155` dark
  static const Color border       = Color(0xFF334155);
  /// `--border-light: #1e293b` dark
  static const Color borderLight  = Color(0xFF1E293B);

  // ─── Glass tokens (CSS dark mode) ────────────────────────────────────────
  static const Color glassBg     = Color(0xA80D0D0D); // rgba(13,13,13,0.65)
  static const Color glassBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

  // =========================================================================
  // Dark Theme
  // =========================================================================
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: text, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: text),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text),
        headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: text),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: text),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSubtle),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // --radius-xl
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // --radius-lg
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:  const TextStyle(color: textMuted,  fontFamily: 'Inter'),
        labelStyle: const TextStyle(color: textSubtle, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(fontFamily: 'Inter', color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: borderLight,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,
        unselectedLabelColor: textMuted,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        labelStyle: const TextStyle(color: text, fontSize: 12),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // =========================================================================
  // Light Theme  (CSS :root defaults)
  // =========================================================================
  static ThemeData get light {
    // Light palette from CSS :root
    const Color lBg             = Color(0xFFFFFFFF); // --bg
    const Color lSurface        = Color(0xFFF8FAFC); // --bg-card
    const Color lSurfaceElevated= Color(0xFFFFFFFF); // --bg-elevated
    const Color lBorder         = Color(0xFFE2E8F0); // --border
    const Color lBorderLight    = Color(0xFFF1F5F9); // --border-light
    const Color lText           = Color(0xFF0F172A); // --text
    const Color lTextSubtle     = Color(0xFF475569); // --text-secondary
    const Color lTextMuted      = Color(0xFF94A3B8); // --text-muted
    const Color lPrimaryPale    = Color(0xFFEEF2FF); // --primary-pale

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lText,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: lText, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: lText),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: lText),
        headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lText),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lText),
        titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lText),
        titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lText),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: lText),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lTextSubtle),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: lTextMuted),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: lText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lSurface,
        foregroundColor: lText,
        elevation: 1,
        shadowColor: lBorder,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lText,
        ),
      ),
      cardTheme: CardThemeData(
        color: lSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:  const TextStyle(color: lTextMuted,  fontFamily: 'Inter'),
        labelStyle: const TextStyle(color: lTextSubtle, fontFamily: 'Inter'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lText,
          side: const BorderSide(color: lBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lBorder,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lSurface,
        selectedItemColor: primary,
        unselectedItemColor: lTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lSurface,
        contentTextStyle: const TextStyle(fontFamily: 'Inter', color: lText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: lBorderLight,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primary,
        labelColor: primary,
        unselectedLabelColor: lTextMuted,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lPrimaryPale,
        labelStyle: const TextStyle(color: primary, fontSize: 12),
        side: const BorderSide(color: lBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
