import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

enum AppToastVariant { success, error, info, warning }

void showAppToast(
  BuildContext context, {
  required String message,
  AppToastVariant variant = AppToastVariant.success,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final bottom = _toastBottomMargin(context);

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.fromLTRB(
        AppTokens.spaceMd,
        0,
        AppTokens.spaceMd,
        bottom,
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      content: _AppToastContent(message: message, variant: variant),
    ),
  );
}

double _toastBottomMargin(BuildContext context) {
  final scaffoldWidget = context.findAncestorWidgetOfExactType<Scaffold>();
  final hasFab = scaffoldWidget?.floatingActionButton != null;
  if (hasFab) {
    return 76;
  }
  return AppTokens.spaceMd;
}

class _AppToastContent extends StatelessWidget {
  const _AppToastContent({
    required this.message,
    required this.variant,
  });

  final String message;
  final AppToastVariant variant;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final style = _styleFor(variant);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceSm + 2,
        ),
        decoration: BoxDecoration(
          color: surfaces.card,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: style.accent.withValues(alpha: 0.35)),
          boxShadow: AppTokens.shadowMd,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: style.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.accent, size: 20),
            ),
            const SizedBox(width: AppTokens.spaceSm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: surfaces.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ToastStyle _styleFor(AppToastVariant variant) {
    switch (variant) {
      case AppToastVariant.success:
        return const _ToastStyle(
          icon: Symbols.check_circle,
          accent: AppColors.teal,
        );
      case AppToastVariant.error:
        return const _ToastStyle(
          icon: Symbols.error,
          accent: AppColors.danger,
        );
      case AppToastVariant.warning:
        return const _ToastStyle(
          icon: Symbols.warning,
          accent: AppColors.warning,
        );
      case AppToastVariant.info:
        return const _ToastStyle(
          icon: Symbols.info,
          accent: AppColors.accent,
        );
    }
  }
}

class _ToastStyle {
  const _ToastStyle({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;
}
