import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData buildDarkTheme(Color rankColor) {
  final primaryColor = rankColor == const Color(0xFF00E5FF) ? AppColors.goldPrimary : rankColor;

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: AppColors.goldLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w900, letterSpacing: 1.2),
      displayMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      headlineLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 0.8),
      headlineMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: 0.6),
      headlineSmall: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.4),
      titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
      titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.2),
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.4),
      bodyMedium: TextStyle(color: AppColors.darkSubText, fontSize: 12, height: 1.4),
      bodySmall: TextStyle(color: AppColors.darkDimText, fontSize: 10, letterSpacing: 0.5),
      labelLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
      iconTheme: IconThemeData(color: AppColors.darkText),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: primaryColor,
      unselectedItemColor: AppColors.darkSubText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.0),
      unselectedLabelStyle: const TextStyle(fontSize: 10, letterSpacing: 0.4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 6,
        shadowColor: primaryColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.8), width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 20,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.35), width: 1.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.darkSubText),
      hintStyle: const TextStyle(color: AppColors.darkDimText),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      thumbColor: primaryColor,
      inactiveTrackColor: AppColors.darkBorder,
      overlayColor: primaryColor.withValues(alpha: 0.2),
      valueIndicatorTextStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primaryColor : AppColors.darkSubText),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primaryColor.withValues(alpha: 0.4) : AppColors.darkBorder),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
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
