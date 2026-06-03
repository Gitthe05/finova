import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import 'profile_sheet_scaffold.dart';

Future<void> showSecuritySheet(BuildContext context, WidgetRef ref) {
  final surfaces = context.surfaces;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: surfaces.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
    ),
    builder: (ctx) {
      return ProfileSheetScaffold(
        title: 'Segurança',
        subtitle: 'Como o FINOVA protege sua conta neste aparelho',
        children: [
          const _SecurityInfoTile(
            icon: Symbols.lock,
            title: 'Senha com hash',
            subtitle:
                'Sua senha nunca é salva em texto puro. Usamos hash com salt no SQLite.',
          ),
          const SizedBox(height: AppTokens.spaceSm),
          const _SecurityInfoTile(
            icon: Symbols.encrypted,
            title: 'Sessão no Keychain',
            subtitle:
                'Token e dados da sessão ficam no armazenamento seguro do sistema (iOS/Android).',
          ),
          const SizedBox(height: AppTokens.spaceSm),
          const _SecurityInfoTile(
            icon: Symbols.storage,
            title: 'Dados no dispositivo',
            subtitle:
                'Transações e categorias são gravadas localmente. Você mantém o controle dos seus dados.',
          ),
          const SizedBox(height: AppTokens.spaceSm),
          const _SecurityInfoTile(
            icon: Symbols.face,
            title: 'Biometria (em breve)',
            subtitle:
                'Face ID / digital será habilitado após o primeiro login com e-mail e senha.',
          ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton.icon(
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                ctx,
                title: 'Encerrar sessão?',
                message:
                    'Você sairá deste aparelho e precisará entrar novamente com e-mail e senha.',
                confirmLabel: 'Encerrar sessão',
                cancelLabel: 'Cancelar',
                destructive: true,
              );
              if (confirmed != true || !ctx.mounted) return;
              await ref.read(authViewModelProvider.notifier).logout();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ctx.go('/login');
              }
            },
            icon: const Icon(Symbols.logout, size: 20),
            label: const Text('Encerrar sessão neste aparelho'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _SecurityInfoTile extends StatelessWidget {
  const _SecurityInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: surfaces.inputFill,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: surfaces.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: surfaces.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
