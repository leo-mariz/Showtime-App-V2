import 'package:app/core/design_system/font/font_size_calculator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme appTextTheme(Color onSurfaceColor, Color onPrimaryColor) {
  return GoogleFonts.latoTextTheme().copyWith(
    //Poppins
    headlineLarge: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(32),
        fontWeight: FontWeight.bold,
        color: onPrimaryColor,
      ),
    ),
    headlineMedium: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(28),
        fontWeight: FontWeight.bold,
        color: onPrimaryColor,
      ),
    ),
    headlineSmall: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(22),
        fontWeight: FontWeight.bold,
        color: onPrimaryColor,
      ),
    ),
    // Adicionando mais variações de textos
    titleLarge: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(26),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,  // Título sobre superfície
      ),
    ),
    titleMedium: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(22),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,
      ),
    ),
    titleSmall: GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: calculateFontSize(18),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,
      ),
    ),

    //Lato
    bodyLarge: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(16),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,  // Textos sobre superfície (onSurface)
      ),
    ),
    bodyMedium: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(14),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,
      ),
    ),
    bodySmall: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(12),
        fontWeight: FontWeight.w400,
        color: onPrimaryColor,
      ),
    ),
    labelLarge: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(16),
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,  // Textos sobre cor primária (onPrimary)
      ),
    ),
    labelMedium: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(14),
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
    ),
    labelSmall: GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: calculateFontSize(12),
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
    ),
  );
}
