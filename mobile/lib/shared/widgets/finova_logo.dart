import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

class FinovaLogo extends StatelessWidget {
  const FinovaLogo({
    super.key,
    this.size = 30,
    this.showName = true,
    this.showTagline = false,
  });

  final double size;
  final bool showName;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final mark = _FinovaMark(size: size);

    if (!showName && !showTagline) return mark;

    if (showTagline) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mark,
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTokens.brandName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTokens.brandTagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (showName) ...[
          const SizedBox(width: AppTokens.spaceSm),
          Text(
            AppTokens.brandName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
          ),
        ],
      ],
    );
  }
}

class _FinovaMark extends StatelessWidget {
  const _FinovaMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.brandGradient,
        boxShadow: context.isDarkTheme ? null : AppTokens.shadowSm,
      ),
      child: Center(
        child: Text(
          'F',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
