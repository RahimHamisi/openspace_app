import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryBlue,
      scaffoldBackgroundColor: AppConstants.lightGrey,
      cardColor: AppConstants.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: AppConstants.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryBlue,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppConstants.black,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppConstants.grey,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.white,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.primaryBlue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: AppConstants.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.lightAccent,
      scaffoldBackgroundColor: AppConstants.darkBackground,
      cardColor: AppConstants.darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkCard,
        foregroundColor: AppConstants.darkText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.lightAccent,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppConstants.darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppConstants.darkTextSecondary,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.darkCard,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.lightAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.lightAccent,
          foregroundColor: AppConstants.darkBackground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}