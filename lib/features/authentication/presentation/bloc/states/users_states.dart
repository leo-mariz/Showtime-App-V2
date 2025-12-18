import 'package:app/core/domain/user/user_entity.dart';
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

class AuthLoading extends AuthState {}

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




