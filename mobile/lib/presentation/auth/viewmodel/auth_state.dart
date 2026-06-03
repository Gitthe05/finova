import '../../../core/utils/view_status.dart';
import '../../../domain/entities/user_entity.dart';

class AuthState {
  const AuthState({
    this.status = ViewStatus.initial,
    this.user,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.nameError,
    this.confirmPasswordError,
  });

  final ViewStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;
  final String? nameError;
  final String? confirmPasswordError;

  AuthState copyWith({
    ViewStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? emailError,
    String? passwordError,
    String? nameError,
    String? confirmPasswordError,
    bool clearErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      emailError: clearErrors ? null : (emailError ?? this.emailError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      nameError: clearErrors ? null : (nameError ?? this.nameError),
      confirmPasswordError:
          clearErrors ? null : (confirmPasswordError ?? this.confirmPasswordError),
    );
  }
}
