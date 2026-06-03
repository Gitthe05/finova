import 'package:flutter/material.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final isDark = context.isDarkTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaces.card,
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
        border: Border.all(color: surfaces.border, width: 1),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ]
            : AppTokens.shadowLoginCard,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceLg,
          AppTokens.spaceLg,
          AppTokens.spaceMd,
        ),
        child: child,
      ),
    );
  }
}
