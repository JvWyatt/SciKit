import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? AppColors.primary : AppColors.primaryDark,
      onPrimary: isLight ? AppColors.onPrimary : AppColors.onPrimaryDark,
      primaryContainer:
          isLight ? AppColors.primaryContainer : AppColors.primaryContainerDark,
      onPrimaryContainer: isLight
          ? AppColors.onPrimaryContainer
          : AppColors.onPrimaryContainerDark,
      secondary: isLight ? AppColors.secondary : AppColors.secondaryDark,
      onSecondary: isLight ? AppColors.onSecondary : AppColors.onSecondaryDark,
      secondaryContainer: isLight
          ? AppColors.secondaryContainer
          : AppColors.secondaryContainerDark,
      onSecondaryContainer: isLight
          ? AppColors.onSecondaryContainer
          : AppColors.onSecondaryContainerDark,
      error: isLight ? AppColors.error : AppColors.errorDark,
      onError: isLight ? AppColors.onError : AppColors.onErrorDark,
      surface: isLight ? AppColors.surface : AppColors.surfaceDark,
      onSurface: isLight ? AppColors.onSurface : AppColors.onSurfaceDark,
      surfaceContainerHighest: isLight
          ? AppColors.surfaceVariant
          : AppColors.surfaceVariantDark,
      onSurfaceVariant: isLight
          ? AppColors.onSurfaceVariant
          : AppColors.onSurfaceVariantDark,
      outline: isLight ? const Color(0xFF73777F) : const Color(0xFF8A9198),
      outlineVariant:
          isLight ? const Color(0xFFC2C7CF) : const Color(0xFF43484E),
      inverseSurface:
          isLight ? const Color(0xFF2B3138) : const Color(0xFFE4E2E6),
      onInverseSurface:
          isLight ? const Color(0xFFF1F4F6) : const Color(0xFF2B3138),
      inversePrimary: isLight ? AppColors.primaryDark : AppColors.primary,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: isLight ? AppColors.primary : AppColors.primaryDark,
      errorContainer: isLight
          ? const Color(0xFFFFDAD6)
          : const Color(0xFF93000A),
      onErrorContainer: isLight
          ? const Color(0xFF410002)
          : const Color(0xFFFFDAD6),
      surfaceContainer: isLight ? const Color(0xFFF1F4F9) : const Color(0xFF1F262C),
      surfaceContainerLow: isLight ? const Color(0xFFF7FAFF) : const Color(0xFF171D23),
      surfaceContainerLowest: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F1419),
      surfaceContainerHigh: isLight ? const Color(0xFFEBEEF3) : const Color(0xFF293136),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }
}
