import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/open_url.dart';
import '../../../shared/widgets/finova_logo.dart';
import 'profile_sheet_scaffold.dart';

const _appVersion = '1.0.0';
const _bcbUrl = 'https://www.bcb.gov.br/cidadaniafinanceira';

Future<void> showAboutSheet(BuildContext context) {
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
        title: 'Sobre o FINOVA',
        subtitle: AppTokens.brandTagline,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppTokens.spaceMd),
              decoration: BoxDecoration(
                color: surfaces.inputFill,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(color: surfaces.border),
              ),
              child: const FinovaLogo(size: 48, showName: true),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spaceMd,
                vertical: AppTokens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Text(
                'Versão $_appVersion',
                style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          const _AboutInfoTile(
            icon: Symbols.account_balance_wallet,
            title: 'Controle financeiro pessoal',
            subtitle:
                'Registre receitas e despesas, organize categorias e acompanhe seu saldo.',
          ),
          const SizedBox(height: AppTokens.spaceSm),
          const _AboutInfoTile(
            icon: Symbols.phone_android,
            title: 'Funciona offline',
            subtitle:
                'Seus lançamentos ficam no aparelho. A API do backend é opcional para notícias.',
          ),
          const SizedBox(height: AppTokens.spaceSm),
          const _AboutInfoTile(
            icon: Symbols.school,
            title: 'Finova',
            subtitle:
                'Aplicativo desenvolvido para aprendizado com Flutter e boas práticas de UX.',
          ),
          const SizedBox(height: AppTokens.spaceLg),
          OutlinedButton.icon(
            onPressed: () => openExternalUrl(ctx, _bcbUrl),
            icon: const Icon(Symbols.open_in_new, size: 20),
            label: const Text('Educação financeira (BCB)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(AppTokens.buttonHeight),
              side: BorderSide(color: surfaces.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            '${AppConstants.appName} · build $_appVersion',
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                  color: surfaces.textMuted,
                ),
          ),
        ],
      );
    },
  );
}

class _AboutInfoTile extends StatelessWidget {
  const _AboutInfoTile({
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
          Icon(icon, color: AppColors.teal, size: 22),
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
