import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

class BrandFab extends StatelessWidget {
  const BrandFab({super.key, required this.onPressed, this.heroTag});

  final VoidCallback onPressed;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: context.brandGradient,
          boxShadow: context.isDarkTheme
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTokens.shadowMd,
        ),
        child: const Icon(Symbols.add, size: 28),
      ),
    );
  }
}
