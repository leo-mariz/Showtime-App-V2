import 'package:app/core/themes/app_colors/app_colors.dart';
import 'package:app/core/themes/app_texts/app_text_theme.dart';
import 'package:flutter/material.dart';

class AndroidDarkTheme {
  static ThemeData get theme {
    return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      surface: AppColors.backgroundDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onSurfaceDark,
    ),
      textTheme: appTextTheme(AppColors.onSurfaceDark, AppColors.onPrimaryDark),
      cardTheme: CardThemeData(
        color: AppColors.primaryDark,
      )
    );
  }
}
