import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/utils/shell_layout.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/finova_logo.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../widgets/about_sheet.dart';
import '../widgets/security_sheet.dart';
import '../widgets/theme_picker_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final user = auth.user;
    final name = user?.name ?? 'Usuário';
    final email = user?.email ?? '';
    final initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();
    final memberSince = user != null
        ? DateFormat('MMMM yyyy', 'pt_BR').format(user.createdAt)
        : null;
    final padding = shellListPadding(context);
    final surfaces = context.surfaces;
    final themeMode = ref.watch(themeModeProvider);
    final themeLabel =
        themeMode == ThemeMode.dark ? 'Tema escuro' : 'Tema claro';

    return ColoredBox(
      color: surfaces.screenTint,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                AppTokens.spaceSm,
                padding.right,
                AppTokens.spaceSm,
              ),
              child: Text(
                'Perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  0,
                  padding.right,
                  AppTokens.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeroCard(
                      initial: initial,
                      name: name,
                      email: email,
                      memberSince: memberSince,
                    ).animate().fadeIn(duration: 280.ms),
                    const SizedBox(height: AppTokens.spaceSm),
                    _sectionLabel(context, 'Conta'),
                    const SizedBox(height: AppTokens.spaceSm),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _ProfileMenuTile(
                            icon: Symbols.verified_user,
                            iconColor: AppColors.accent,
                            title: 'Segurança',
                            subtitle: 'Dados protegidos no dispositivo',
                            onTap: () => showSecuritySheet(context, ref),
                          ),
                          Divider(
                            height: 1,
                            color: surfaces.border,
                            indent: 64,
                          ),
                          _ProfileMenuTile(
                            icon: Symbols.palette,
                            iconColor: AppColors.teal,
                            title: 'Aparência',
                            subtitle: themeLabel,
                            onTap: () => showThemePickerSheet(context, ref),
                          ),
                          Divider(
                            height: 1,
                            color: surfaces.border,
                            indent: 64,
                          ),
                          _ProfileMenuTile(
                            icon: Symbols.info,
                            iconColor: AppColors.textSecondary,
                            title: 'Sobre o app',
                            subtitle: 'FINOVA · versão $_appVersion',
                            onTap: () => showAboutSheet(context),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
                    const SizedBox(height: AppTokens.spaceSm),
                    _sectionLabel(context, 'Sessão'),
                    const SizedBox(height: AppTokens.spaceSm),
                    _LogoutCard(
                      onLogout: () => _confirmLogout(context, ref),
                    ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
                  ],
                ),
              ),
            ),
            _ProfileFooter(surfaces: surfaces)
                .animate()
                .fadeIn(delay: 180.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }

  static Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.surfaces.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sair da conta?',
      message: 'Você precisará entrar novamente para acessar seus dados.',
      confirmLabel: 'Sair',
      cancelLabel: 'Cancelar',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(authViewModelProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter({required this.surfaces});

  final AppSurfaceColors surfaces;

  @override
  Widget build(BuildContext context) {
    final padding = shellListPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        AppTokens.spaceXs,
        padding.right,
        shellBottomInset(context),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaces.screenTint,
          border: Border(top: BorderSide(color: surfaces.border)),
        ),
        child: PremiumCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FinovaLogo(size: 28, showName: true),
              const SizedBox(height: 6),
              Text(
                AppTokens.brandTagline,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: surfaces.textSecondary,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.initial,
    required this.name,
    required this.email,
    this.memberSince,
  });

  final String initial;
  final String name;
  final String email;
  final String? memberSince;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.brandGradient,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: context.isDarkTheme
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : AppTokens.shadowLg,
      ),
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (memberSince != null) ...[
            const SizedBox(height: AppTokens.spaceSm),
            _HeroChip(
              icon: Symbols.calendar_month,
              label: 'Membro desde $memberSince',
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: surfaces.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onLogout,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Symbols.logout,
              color: AppColors.danger,
              size: 22,
            ),
            const SizedBox(width: AppTokens.spaceSm),
            Text(
              'Sair da conta',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
