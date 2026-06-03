import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surface_colors.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final resolved = gradient ??
        (context.isDarkTheme
            ? AppColors.screenGradientDark
            : AppColors.screenGradient);

    return DecoratedBox(
      decoration: BoxDecoration(gradient: resolved),
      child: child,
    );
  }
}
