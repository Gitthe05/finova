import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'app_toast.dart';

class BiometricLoginButton extends StatelessWidget {
  const BiometricLoginButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed ??
          () {
            showAppToast(
              context,
              message: 'Face ID disponível após o primeiro acesso',
              variant: AppToastVariant.info,
            );
          },
      icon: Icon(Symbols.face, color: context.accentHighlight, size: 22),
      label: Text(
        'Entrar com Face ID',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: context.accentHighlight,
              fontWeight: FontWeight.w600,
            ),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.spaceXs),
      ),
    );
  }
}
