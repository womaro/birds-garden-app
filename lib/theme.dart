import 'package:flutter/material.dart';

class AppTheme {
  static const primary       = Color(0xFF0F6E56);
  static const primaryDark   = Color(0xFF085041);
  static const primaryLight  = Color(0xFFE1F5EE);
  static const primaryMid    = Color(0xFF1D9E75);
  static const primaryPale   = Color(0xFF9FE1CB);
  static const bgSecondary   = Color(0xFFF4F2EC);
  static const textPrimary   = Color(0xFF1a1a18);
  static const textSecondary = Color(0xFF6b6a65);
  static const textTertiary  = Color(0xFF9e9d98);

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    useMaterial3: true,
    scaffoldBackgroundColor: bgSecondary,
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSecondary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primaryLight,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    ),
  );
}