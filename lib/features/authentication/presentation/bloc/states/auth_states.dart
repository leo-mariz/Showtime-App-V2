import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthConnectionFailure extends AuthState {
  final String message;

  AuthConnectionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthInitial extends AuthState {}

class LoginInitial extends AuthState {}

class LoginLoading extends AuthState {}

class RegisterLoading extends AuthState {}

class RegisterOnboardingLoading extends AuthState {}

class InitialLoading extends AuthState {} // ou CheckBiometricsLoading

class CheckUserLoggedInLoading extends AuthState {}

class LogoutLoading extends AuthState {}

class EnableBiometricsLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity? user;
  final String message;

  AuthSuccess({
    this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class AuthDataIncomplete extends AuthState {
  final String message;

  AuthDataIncomplete({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado para quando email não está verificado
class EmailNotVerified extends AuthState {
  final String email;

  EmailNotVerified({required this.email});

  @override
  List<Object?> get props => [email];
}



// Forgot password states
class ForgotPasswordLoading extends AuthState {}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends AuthState {
  final String error;

  ForgotPasswordFailure({required this.error});

  @override
  List<Object?> get props => [error];
}


class GoogleLoginSuccess extends AuthState {}

class GoogleLoginFailure extends AuthState {
  final String error;

  GoogleLoginFailure({required this.error});
}

class CheckUserLoggedInSuccess extends AuthState {
  final bool isLoggedIn;
  final bool isArtist;

  CheckUserLoggedInSuccess({required this.isLoggedIn, required this.isArtist});

  @override
  List<Object?> get props => [isLoggedIn, isArtist];
}

class LoginSuccess extends AuthState {
  final UserEntity user;

  LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginWithBiometricsSuccess extends AuthState {
  final bool isArtist;

  LoginWithBiometricsSuccess({required this.isArtist});

  @override
  List<Object?> get props => [isArtist];
}

class BiometricFailure extends AuthState {
  final String error;
  BiometricFailure(this.error);
}

class AuthLoggedOut extends AuthState {}

// Estado para quando o perfil do usuário não corresponde ao tipo selecionado
class AuthProfileMismatch extends AuthState {
  final String error;

  AuthProfileMismatch({required this.error});

  @override
  List<Object?> get props => [error];
}

// Estado para verificar se deve mostrar prompt de biometria
class CheckShouldShowBiometricsPromptSuccess extends AuthState {
  final bool shouldShow;
  final UserEntity? user; // User para passar ao modal se shouldShow for true

  CheckShouldShowBiometricsPromptSuccess({
    required this.shouldShow,
    this.user,
  });

  @override
  List<Object?> get props => [shouldShow, user];
}

// Estado para verificar se biometria está habilitada
class CheckBiometricsEnabledSuccess extends AuthState {
  final bool isEnabled;

  CheckBiometricsEnabledSuccess({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

// Estados para verificação de email
class CheckEmailVerifiedLoading extends AuthState {}

class CheckEmailVerifiedSuccess extends AuthState {
  final bool isVerified;

  CheckEmailVerifiedSuccess({required this.isVerified});

  @override
  List<Object?> get props => [isVerified];
}

class CheckEmailVerifiedFailure extends AuthState {
  final String error;

  CheckEmailVerifiedFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ResendEmailVerificationLoading extends AuthState {}

class ResendEmailVerificationSuccess extends AuthState {
  final String message;

  ResendEmailVerificationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResendEmailVerificationFailure extends AuthState {
  final String error;

  ResendEmailVerificationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class CheckNewEmailVerifiedLoading extends AuthState {}

class CheckNewEmailVerifiedSuccess extends AuthState {
  final bool isVerified;

  CheckNewEmailVerifiedSuccess({required this.isVerified});

  @override
  List<Object?> get props => [isVerified];
}

class CheckNewEmailVerifiedFailure extends AuthState {
  final String error;

  CheckNewEmailVerifiedFailure({required this.error});

  @override
  List<Object?> get props => [error];
}




