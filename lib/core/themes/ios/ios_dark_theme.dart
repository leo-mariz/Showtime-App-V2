import 'package:app/core/themes/app_colors/app_colors.dart';
import 'package:app/core/themes/app_texts/app_text_theme.dart';
import 'package:flutter/material.dart';

class IOSDarkTheme {
  static ThemeData get theme {
    return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,  // Defina as cores específicas para iOS
    colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        error: AppColors.errorDark,
        onError: Color.fromARGB(255, 224, 28, 38),
        surface: AppColors.backgroundDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        secondaryContainer: AppColors.secondaryContainerDark,
      ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onSurfaceDark,
    ),
      textTheme: appTextTheme(AppColors.onSurfaceDark, AppColors.onPrimaryDark),
    );
  }
}
