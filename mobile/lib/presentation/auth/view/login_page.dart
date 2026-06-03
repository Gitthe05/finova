import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/view_status.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_gradient_background.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/biometric_login_button.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/login_card.dart';
import '../../../shared/widgets/login_header.dart';
import '../viewmodel/auth_state.dart';
import '../viewmodel/auth_view_model.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _loginCard(BuildContext context, AuthState state) {
    return LoginCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Entrar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.surfaces.textPrimary,
                ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppTextField(
            controller: _email,
            label: 'E-mail',
            hint: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Symbols.mail,
            textInputAction: TextInputAction.next,
            errorText: state.emailError,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppTextField(
            controller: _password,
            label: 'Senha',
            obscure: true,
            prefixIcon: Symbols.lock,
            textInputAction: TextInputAction.done,
            errorText: state.passwordError,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          GradientButton(
            label: 'Entrar',
            loading: state.status == ViewStatus.loading,
            onPressed: () => ref.read(authViewModelProvider.notifier).login(
                  _email.text,
                  _password.text,
                ),
          ),
          const BiometricLoginButton(),
          const SizedBox(height: AppTokens.spaceMd),
          Row(
            children: [
              Expanded(child: Divider(color: context.surfaces.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceSm),
                child: Text(
                  'ou',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.surfaces.textMuted,
                      ),
                ),
              ),
              Expanded(child: Divider(color: context.surfaces.border)),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppButton(
            label: 'Criar conta',
            variant: AppButtonVariant.outline,
            onPressed: () => context.push('/register'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 120.ms, duration: 400.ms)
        .slideY(begin: 0.04, end: 0);
  }

  Widget _content(BuildContext context, AuthState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const LoginHeader().animate().fadeIn(duration: 320.ms),
        const SizedBox(height: AppTokens.spaceLg),
        _loginCard(context, state),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    ref.listen(authViewModelProvider, (prev, next) {
      if (next.status == ViewStatus.success && next.user != null) {
        context.go('/home');
      }
      if (next.status == ViewStatus.error && next.errorMessage != null) {
        showAppToast(
          context,
          message: next.errorMessage!,
          variant: AppToastVariant.error,
        );
      }
    });

    const horizontalPadding = EdgeInsets.symmetric(horizontal: AppTokens.spaceLg);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.surfaces.screenBackground,
      body: AppGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: horizontalPadding.copyWith(
                  top: AppTokens.spaceMd,
                  bottom: AppTokens.spaceMd,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: _content(context, state),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
