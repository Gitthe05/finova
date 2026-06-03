import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/view_status.dart';
import '../../../shared/widgets/app_gradient_background.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/login_header.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/login_card.dart';
import '../viewmodel/auth_view_model.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
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

    final surfaces = context.surfaces;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: surfaces.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nova conta'),
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),
                const SizedBox(height: AppTokens.spaceMd),
                LoginCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Comece agora',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: surfaces.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppTokens.spaceXs),
                      Text(
                        'Crie sua conta e organize suas finanças em minutos.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: surfaces.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppTokens.spaceMd),
                      AppTextField(
                        controller: _name,
                        label: 'Nome completo',
                        prefixIcon: Symbols.person,
                        errorText: state.nameError,
                      ),
                      const SizedBox(height: AppTokens.spaceSm),
                      AppTextField(
                        controller: _email,
                        label: 'E-mail',
                        prefixIcon: Symbols.mail,
                        keyboardType: TextInputType.emailAddress,
                        errorText: state.emailError,
                      ),
                      const SizedBox(height: AppTokens.spaceSm),
                      AppTextField(
                        controller: _password,
                        label: 'Senha',
                        obscure: true,
                        prefixIcon: Symbols.lock,
                        errorText: state.passwordError,
                      ),
                      const SizedBox(height: AppTokens.spaceSm),
                      AppTextField(
                        controller: _confirm,
                        label: 'Confirmar senha',
                        obscure: true,
                        prefixIcon: Symbols.lock,
                        errorText: state.confirmPasswordError,
                      ),
                      const SizedBox(height: AppTokens.spaceMd),
                      GradientButton(
                        label: 'Criar conta',
                        loading: state.status == ViewStatus.loading,
                        onPressed: () => ref.read(authViewModelProvider.notifier).register(
                              _name.text,
                              _email.text,
                              _password.text,
                              _confirm.text,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
