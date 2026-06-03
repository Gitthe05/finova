import 'package:flutter/material.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'finova_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Column(
      children: [
        const FinovaLogo(size: 30, showName: false),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          AppTokens.brandName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1,
                color: surfaces.textPrimary,
              ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        Text(
          AppTokens.brandTagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: surfaces.textSecondary,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
