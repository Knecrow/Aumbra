import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData buildDarkTheme(Color rankColor) {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: rankColor,
    colorScheme: ColorScheme.dark(
      primary: rankColor,
      secondary: rankColor.withValues(alpha: 0.8),
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
    fontFamily: 'monospace',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w900, letterSpacing: 3.0),
      displayMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w900, letterSpacing: 2.0),
      headlineLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 2.0),
      headlineMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 1.5),
      headlineSmall: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1.2),
      titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1.0),
      titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.8),
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 14, letterSpacing: 0.4),
      bodyMedium: TextStyle(color: AppColors.darkSubText, fontSize: 12, letterSpacing: 0.3),
      bodySmall: TextStyle(color: AppColors.darkSubText, fontSize: 10, letterSpacing: 0.2),
      labelLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.5,
        fontFamily: 'monospace',
      ),
      iconTheme: IconThemeData(color: AppColors.darkText),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: rankColor,
      unselectedItemColor: AppColors.darkSubText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
      unselectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 0.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rankColor,
        foregroundColor: Colors.black,
        elevation: 6,
        shadowColor: rankColor.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: rankColor, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 4,
      shadowColor: rankColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF0C0E1A),
      elevation: 16,
      shadowColor: rankColor.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: rankColor.withValues(alpha: 0.5), width: 1.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: rankColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.darkSubText, fontFamily: 'monospace'),
      hintStyle: const TextStyle(color: AppColors.darkSubText, fontFamily: 'monospace'),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: rankColor,
      thumbColor: rankColor,
      inactiveTrackColor: AppColors.darkBorder,
      overlayColor: rankColor.withValues(alpha: 0.2),
      valueIndicatorTextStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? rankColor : AppColors.darkSubText),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? rankColor.withValues(alpha: 0.4) : AppColors.darkBorder),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: rankColor,
    ),
  );
}

ThemeData buildLightTheme(Color rankColor) {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: rankColor,
    colorScheme: ColorScheme.light(
      primary: rankColor,
      secondary: rankColor.withValues(alpha: 0.7),
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightBorder,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w700, fontSize: 28),
      headlineMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 22),
      headlineSmall: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 16),
      titleMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500, fontSize: 14),
      bodyLarge: TextStyle(color: AppColors.lightText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.lightSubText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.lightSubText, fontSize: 12),
      labelLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600, fontSize: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.lightText),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: rankColor,
      unselectedItemColor: AppColors.lightSubText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rankColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightFauxGlass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.lightFauxGlassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.lightFauxGlassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: rankColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.lightSubText),
      hintStyle: const TextStyle(color: AppColors.lightSubText),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: rankColor,
      thumbColor: rankColor,
      inactiveTrackColor: AppColors.lightBorder,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? rankColor : AppColors.lightSubText),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? rankColor.withValues(alpha: 0.4) : AppColors.lightBorder),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: rankColor,
    ),
  );
}
