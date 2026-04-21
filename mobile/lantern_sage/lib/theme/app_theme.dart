import 'package:flutter/material.dart';

class LanternSageTheme {
  static const background = Color(0xFF1C0A00);
  static const backgroundDeep = Color(0xFF0F0500);
  static const heroSurface = Color(0xFF150800);
  static const panelDark = Color(0xFF361500);
  static const surface = Color(0xFF241006);
  static const surfaceMuted = Color(0xFF2A1305);
  static const accent = Color(0xFFCC9544);
  static const textStrong = Color(0xF5CC9544);
  static const textSoft = Color(0xCCCC9544);
  static const textFaint = Color(0x8CCC9544);
  static const divider = Color(0x33CC9544);
  static const lineSoft = Color(0x24CC9544);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: surface,
    ).copyWith(
      primary: accent,
      secondary: accent,
      surface: surface,
      onSurface: textStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Palatino Linotype',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textStrong,
          fontSize: 52,
          height: 0.92,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: textStrong,
          fontSize: 34,
          height: 1,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: textStrong,
          fontSize: 18,
          height: 1.15,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: textStrong,
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textSoft,
          fontSize: 15,
          height: 1.72,
        ),
        bodyMedium: TextStyle(
          color: textSoft,
          fontSize: 13,
          height: 1.65,
        ),
        labelSmall: TextStyle(
          color: textFaint,
          fontSize: 11,
          height: 1.2,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: accent.withValues(alpha: 0.05),
        labelStyle: const TextStyle(color: textFaint),
        hintStyle: const TextStyle(color: textFaint),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent.withValues(alpha: 0.18),
          foregroundColor: textStrong,
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 13,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: 0.28)),
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textStrong,
          minimumSize: const Size(48, 44),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: divider),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0A0300),
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? textStrong : textFaint,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? accent : textFaint,
            size: 22,
          );
        }),
      ),
    );
  }
}
