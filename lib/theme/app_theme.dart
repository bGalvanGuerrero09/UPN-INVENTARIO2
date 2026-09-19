import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // ===================================================
    // COLOR PRINCIPAL
    // ===================================================

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    // ===================================================
    // FONDO
    // ===================================================

    scaffoldBackgroundColor:
    AppColors.background,

    // ===================================================
    // APP BAR
    // ===================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      centerTitle: true,

      elevation: 0,
    ),

    // ===================================================
    // INPUTS
    // ===================================================

    inputDecorationTheme:
    InputDecorationTheme(
      filled: true,

      fillColor:
      AppColors.inputBackground,

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(15),
        ),

        borderSide: BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(15),
        ),

        borderSide: BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(15),
        ),

        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),

    // ===================================================
    // BOTONES
    // ===================================================

    elevatedButtonTheme:
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor:
        AppColors.white,

        backgroundColor:
        AppColors.primary,

        elevation: 3,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
    ),

    // ===================================================
    // SNACKBAR
    // ===================================================

    snackBarTheme:
    const SnackBarThemeData(
      behavior:
      SnackBarBehavior.floating,
    ),
  );
}
