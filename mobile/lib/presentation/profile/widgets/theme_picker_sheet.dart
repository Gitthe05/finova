import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_mode_controller.dart';

Future<void> showThemePickerSheet(BuildContext context, WidgetRef ref) {
  final surfaces = context.surfaces;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: surfaces.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
    ),
    builder: (ctx) {
      final mode = ref.watch(themeModeProvider);
      final controller = ref.read(themeModeProvider.notifier);

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.spaceLg,
          AppTokens.spaceSm,
          AppTokens.spaceLg,
          AppTokens.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: surfaces.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Text(
              'Aparência',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escolha o tema do aplicativo',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: surfaces.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTokens.spaceMd),
            _ThemeOption(
              icon: Symbols.light_mode,
              title: 'Tema claro',
              subtitle: 'Fundo claro e alto contraste',
              selected: mode == ThemeMode.light,
              onTap: () async {
                await controller.setMode(ThemeMode.light);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: AppTokens.spaceSm),
            _ThemeOption(
              icon: Symbols.dark_mode,
              title: 'Tema escuro',
              subtitle: 'Confortável em ambientes com pouca luz',
              selected: mode == ThemeMode.dark,
              onTap: () async {
                await controller.setMode(ThemeMode.dark);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.spaceMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: selected ? AppColors.teal : surfaces.border,
              width: selected ? 2 : 1,
            ),
            color: selected
                ? AppColors.teal.withValues(alpha: 0.12)
                : surfaces.inputFill,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: surfaces.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Symbols.check_circle, color: AppColors.teal, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
