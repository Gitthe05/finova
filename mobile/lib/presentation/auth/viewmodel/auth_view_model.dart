import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/usecases/auth/get_session_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/transactions/sync_transactions_usecase.dart';
import 'auth_state.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    login: ref.watch(loginUseCaseProvider),
    register: ref.watch(registerUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
    session: ref.watch(getSessionUseCaseProvider),
    syncTransactions: ref.watch(syncTransactionsUseCaseProvider),
  );
});

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetSessionUseCase session,
    required SyncTransactionsUseCase syncTransactions,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _session = session,
        _syncTransactions = syncTransactions,
        super(const AuthState());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetSessionUseCase _session;
  final SyncTransactionsUseCase _syncTransactions;

  Future<void> checkSession() async {
    state = state.copyWith(status: ViewStatus.loading, clearErrors: true);
    try {
      final logged = await _session.isLoggedIn().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!logged) {
        state = const AuthState(status: ViewStatus.empty);
        return;
      }
      final user = await _session.call().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (user == null) {
        state = const AuthState(status: ViewStatus.empty);
        return;
      }
      state = AuthState(status: ViewStatus.success, user: user);
      await _syncTransactions.call();
    } catch (_) {
      state = const AuthState(status: ViewStatus.empty);
    }
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email.trim());
  }

  Future<void> login(String email, String password) async {
    String? emailError;
    String? passwordError;
    if (email.trim().isEmpty) emailError = 'E-mail obrigatório';
    else if (!_validateEmail(email)) emailError = 'E-mail inválido';
    if (password.isEmpty) passwordError = 'Senha obrigatória';
    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        status: ViewStatus.initial,
      );
      return;
    }
    state = state.copyWith(status: ViewStatus.loading, clearErrors: true);
    try {
      final user = await _login.call(email: email, password: password);
      await _syncTransactions.call();
      state = AuthState(status: ViewStatus.success, user: user);
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirm,
  ) async {
    String? nameError;
    String? emailError;
    String? passwordError;
    String? confirmError;
    if (name.trim().length < 2) nameError = 'Nome obrigatório';
    if (!_validateEmail(email)) emailError = 'E-mail inválido';
    if (password.length < AppConstants.minPasswordLength) {
      passwordError = 'Senha mínima de ${AppConstants.minPasswordLength} caracteres';
    }
    if (password != confirm) confirmError = 'Senhas não conferem';
    if (nameError != null || emailError != null || passwordError != null || confirmError != null) {
      state = state.copyWith(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
        confirmPasswordError: confirmError,
      );
      return;
    }
    state = state.copyWith(status: ViewStatus.loading, clearErrors: true);
    try {
      final user = await _register.call(
        name: name,
        email: email,
        password: password,
      );
      await _syncTransactions.call();
      state = AuthState(status: ViewStatus.success, user: user);
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _logout.call();
    state = const AuthState(status: ViewStatus.empty);
  }
}
