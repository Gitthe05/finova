import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0F172A);
  static const accent = Color(0xFF3B82F6);
  static const accentLight = Color(0xFF60A5FA);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFF2DD4BF);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const background = Color(0xFFF8FAFC);
  static const backgroundTint = Color(0xFFEEF4FF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundTint],
  );

  static const screenGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF060B14), Color(0xFF0A1220), Color(0xFF0F172A)],
  );

  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
  );

  static const gradientBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
  );

  static const gradientAccent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, teal],
  );

  static const gradientBalance = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF0D9488), Color(0xFF0F172A)],
    stops: [0.0, 0.55, 1.0],
  );

  static const gradientBrandDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF155E75)],
  );

  static const gradientBalanceDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3352), Color(0xFF134E4A), Color(0xFF0C1220)],
    stops: [0.0, 0.55, 1.0],
  );

  static const darkBackground = Color(0xFF060B14);
  static const darkSurface = Color(0xFF131D2E);
  static const darkInput = Color(0xFF1A2438);
  static const darkSegment = Color(0xFF0E1522);
  static const darkBorder = Color(0xFF2A3548);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  static const lightBackground = background;
  static const lightSurface = card;
  static const lightTextPrimary = textPrimary;
  static const lightTextSecondary = textSecondary;
  static const lightBorder = border;
  static const secondary = teal;
}
