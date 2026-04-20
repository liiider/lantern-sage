import 'package:flutter/material.dart';

class LanternSageTheme {
  static const background = Color(0xFF1C0A00);
  static const surface = Color(0xFF241006);
  static const surfaceMuted = Color(0xFF2B160A);
  static const accent = Color(0xFFCC9544);
  static const textStrong = Color(0xFFF5E8D6);
  static const textSoft = Color(0xFFCEBFA8);
  static const textFaint = Color(0xFF9B876E);
  static const divider = Color(0x33CC9544);

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
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textStrong,
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          color: textStrong,
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: textStrong,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: textStrong,
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textSoft,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSoft,
          fontSize: 14,
          height: 1.45,
        ),
        labelSmall: TextStyle(
          color: textFaint,
          fontSize: 11,
          height: 1.2,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
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
        backgroundColor: const Color(0xFF120700),
        indicatorColor: accent.withValues(alpha: 0.18),
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
