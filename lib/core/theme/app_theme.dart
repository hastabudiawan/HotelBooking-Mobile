import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final textColor = dark ? Colors.white : AppColors.ink;

  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: brightness,
      ).copyWith(
        primary: AppColors.brand,
        onPrimary: Colors.white,
        error: AppColors.danger,
      );

  final base = ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    useMaterial3: true,
  );

  // Teks biasa memakai Raleway, judul memakai Poppins (sesuai desain).
  // TextTheme disusun manual karena GoogleFonts.ralewayTextTheme() tidak
  // cocok dengan tipe TextTheme di versi Flutter ini.
  final t = base.textTheme.apply(bodyColor: textColor, displayColor: textColor);
  TextStyle? raleway(TextStyle? s) => GoogleFonts.raleway(textStyle: s);
  TextStyle? poppins(TextStyle? s) =>
      GoogleFonts.poppins(textStyle: s, fontWeight: FontWeight.w600);

  final textTheme = t.copyWith(
    displayLarge: raleway(t.displayLarge),
    displayMedium: raleway(t.displayMedium),
    displaySmall: raleway(t.displaySmall),
    headlineLarge: raleway(t.headlineLarge),
    headlineMedium: raleway(t.headlineMedium),
    headlineSmall: poppins(t.headlineSmall),
    titleLarge: poppins(t.titleLarge),
    titleMedium: poppins(t.titleMedium),
    titleSmall: raleway(t.titleSmall),
    bodyLarge: raleway(t.bodyLarge),
    bodyMedium: raleway(t.bodyMedium),
    bodySmall: raleway(t.bodySmall),
    labelLarge: raleway(t.labelLarge),
    labelMedium: raleway(t.labelMedium),
    labelSmall: raleway(t.labelSmall),
  );

  Color navColor(Set<WidgetState> states) {
    final selected = states.contains(WidgetState.selected);
    if (selected) return dark ? Colors.white : AppColors.brand;
    return dark ? Colors.white60 : AppColors.muted;
  }

  return base.copyWith(
    scaffoldBackgroundColor: dark ? AppColors.darkBackground : Colors.white,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: textColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: navColor(states)),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: navColor(states),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
