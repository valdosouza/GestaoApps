import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema padrão da aplicação
class AppTheme {
  // Cores do app
  final Color primaryColor;
  final Color accentColor;
  final LinearGradient primaryGradient;

  const AppTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.primaryGradient,
  });

  /// Factory para tema Blue (Budget Sales)
  factory AppTheme.budgetSales() {
    return const AppTheme(
      primaryColor: AppColors.primaryBlue,
      accentColor: Color(0xFF1976D2),
      primaryGradient: AppColors.blueGradient,
    );
  }

  /// Factory para tema Orange (Budget AutoCenter)
  factory AppTheme.budgetAutocenter() {
    return const AppTheme(
      primaryColor: AppColors.primaryOrange,
      accentColor: Color(0xFFE65100),
      primaryGradient: AppColors.orangeGradient,
    );
  }

  /// Factory para tema Green (Stock Count)
  factory AppTheme.stockCount() {
    return const AppTheme(
      primaryColor: AppColors.primaryGreen,
      accentColor: Color(0xFF388E3C),
      primaryGradient: AppColors.greenGradient,
    );
  }

  /// Retorna o ThemeData do Material
  ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      primarySwatch: _getMaterialColor(primaryColor),

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.white,
        elevation: 4,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.grey300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(
          color: AppColors.grey600,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.grey500,
          fontSize: 14,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),

        // Titles
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),

        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.grey900,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.grey800,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.grey700,
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grey600,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.white,
        shadowColor: AppColors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Other
      scaffoldBackgroundColor: AppColors.white,
      highlightColor: primaryColor.withOpacity(0.1),
      splashColor: primaryColor.withOpacity(0.2),
    );
  }

  /// Converte Color para MaterialColor
  static MaterialColor _getMaterialColor(Color color) {
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    final shades = {
      50: Color.fromARGB(255, red + (255 - red) ~/ 10 * 9,
                               green + (255 - green) ~/ 10 * 9,
                               blue + (255 - blue) ~/ 10 * 9),
      100: Color.fromARGB(255, red + (255 - red) ~/ 10 * 8,
                                green + (255 - green) ~/ 10 * 8,
                                blue + (255 - blue) ~/ 10 * 8),
      200: Color.fromARGB(255, red + (255 - red) ~/ 10 * 6,
                                green + (255 - green) ~/ 10 * 6,
                                blue + (255 - blue) ~/ 10 * 6),
      300: Color.fromARGB(255, red + (255 - red) ~/ 10 * 4,
                                green + (255 - green) ~/ 10 * 4,
                                blue + (255 - blue) ~/ 10 * 4),
      400: Color.fromARGB(255, red + (255 - red) ~/ 10 * 2,
                                green + (255 - green) ~/ 10 * 2,
                                blue + (255 - blue) ~/ 10 * 2),
      500: color,
      600: Color.fromARGB(255, (red * 0.9).toInt(),
                                (green * 0.9).toInt(),
                                (blue * 0.9).toInt()),
      700: Color.fromARGB(255, (red * 0.8).toInt(),
                                (green * 0.8).toInt(),
                                (blue * 0.8).toInt()),
      800: Color.fromARGB(255, (red * 0.7).toInt(),
                                (green * 0.7).toInt(),
                                (blue * 0.7).toInt()),
      900: Color.fromARGB(255, (red * 0.6).toInt(),
                                (green * 0.6).toInt(),
                                (blue * 0.6).toInt()),
    };

    return MaterialColor(color.value, shades);
  }
}
