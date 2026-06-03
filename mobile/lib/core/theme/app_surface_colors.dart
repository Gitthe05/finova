import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppSurfaceColors extends ThemeExtension<AppSurfaceColors> {
  const AppSurfaceColors({
    required this.screenBackground,
    required this.screenTint,
    required this.card,
    required this.inputFill,
    required this.segmentTrack,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  final Color screenBackground;
  final Color screenTint;
  final Color card;
  final Color inputFill;
  final Color segmentTrack;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  static const light = AppSurfaceColors(
    screenBackground: AppColors.background,
    screenTint: AppColors.backgroundTint,
    card: AppColors.card,
    inputFill: AppColors.card,
    segmentTrack: Color(0xFFF1F5F9),
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
  );

  static const dark = AppSurfaceColors(
    screenBackground: AppColors.darkBackground,
    screenTint: Color(0xFF0A1018),
    card: AppColors.darkSurface,
    inputFill: AppColors.darkInput,
    segmentTrack: AppColors.darkSegment,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: Color(0xFF64748B),
  );

  @override
  AppSurfaceColors copyWith({
    Color? screenBackground,
    Color? screenTint,
    Color? card,
    Color? inputFill,
    Color? segmentTrack,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
  }) {
    return AppSurfaceColors(
      screenBackground: screenBackground ?? this.screenBackground,
      screenTint: screenTint ?? this.screenTint,
      card: card ?? this.card,
      inputFill: inputFill ?? this.inputFill,
      segmentTrack: segmentTrack ?? this.segmentTrack,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AppSurfaceColors lerp(ThemeExtension<AppSurfaceColors>? other, double t) {
    if (other is! AppSurfaceColors) return this;
    return AppSurfaceColors(
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      screenTint: Color.lerp(screenTint, other.screenTint, t)!,
      card: Color.lerp(card, other.card, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      segmentTrack: Color.lerp(segmentTrack, other.segmentTrack, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension AppSurfaceContext on BuildContext {
  AppSurfaceColors get surfaces =>
      Theme.of(this).extension<AppSurfaceColors>() ?? AppSurfaceColors.light;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  LinearGradient get brandGradient =>
      isDarkTheme ? AppColors.gradientBrandDark : AppColors.gradientBrand;

  LinearGradient get balanceGradient =>
      isDarkTheme ? AppColors.gradientBalanceDark : AppColors.gradientBalance;

  Color get accentHighlight => isDarkTheme ? AppColors.tealLight : AppColors.teal;
}
