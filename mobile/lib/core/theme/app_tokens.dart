import 'package:flutter/material.dart';

abstract final class AppTokens {
  static const brandName = 'FINOVA';
  static const brandTagline =
      'Controle financeiro inteligente para sua vida.';

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radius2xl = 32;

  static const double buttonHeight = 56;
  static const double inputHeight = 64;

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.1),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.18),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowLoginCard => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
