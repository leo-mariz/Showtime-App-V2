import 'package:app/core/themes/android/android_dark_theme.dart';
import 'package:app/core/themes/ios/ios_dark_theme.dart';
import 'package:flutter/material.dart';


class AppThemes {
  static ThemeData get androidDarkTheme => AndroidDarkTheme.theme;
  static ThemeData get iosDarkTheme => IOSDarkTheme.theme;
}