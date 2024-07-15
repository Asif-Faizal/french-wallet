import 'package:flutter/material.dart';
import '../font/text_styles.dart'; // Import the text styles

class AppColors {
  static const Color amber = Colors.amber;

  static const Color lightPrimary = Colors.white;
  static const Color lightBackground = Color(0xFFFFF8E1);
  static const Color lightSurface = Color.fromARGB(255, 255, 228, 147);
  static const Color lightOnPrimary = Colors.black;
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black;

  static const Color darkPrimary = Colors.black;
  static const Color darkBackground = Color(0xFF303030);
  static const Color darkSurface = Color(0xFF424242);
  static const Color darkOnPrimary = Colors.white;
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.amber,
      primaryContainer: AppColors.amber,
      secondary: AppColors.amber,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.lightOnPrimary,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      bodyLarge: AppTextStyles.bodyText,
      labelLarge: AppTextStyles.buttonText,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.amber,
      secondary: AppColors.amber,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.darkOnPrimary,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      bodyLarge: AppTextStyles.bodyText2,
      bodyMedium: AppTextStyles.bodyText,
      labelLarge: AppTextStyles.buttonText,
    ),
    useMaterial3: true,
  );
}
