import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/features/authentication/domain/entities/register_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Evento para registrar um usuário
class RegisterUserEmailAndPasswordEvent extends AuthEvent {
  final UserEntity user;

  RegisterUserEmailAndPasswordEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class RegisterUserOnboardingEvent extends AuthEvent {
  final RegisterEntity register;

  RegisterUserOnboardingEvent({required this.register});

  @override
  List<Object?> get props => [register];
}

class LoginUserEvent extends AuthEvent {
  final UserEntity user;

  LoginUserEvent({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class SendForgotPasswordEmailEvent extends AuthEvent {
  final String email;

  SendForgotPasswordEmailEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class CheckUserLoggedInEvent extends AuthEvent {}

class EnableBiometricsEvent extends AuthEvent {
  final UserEntity user;

  EnableBiometricsEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginWithBiometricsEvent extends AuthEvent {}


class DisableBiometricsEvent extends AuthEvent {
  final UserEntity user;

  DisableBiometricsEvent({required this.user});

  @override
  List<Object?> get props => [user];
}


class UserLogoutEvent extends AuthEvent {
  final bool? resetBiometrics;

  UserLogoutEvent({this.resetBiometrics});

  @override
  List<Object?> get props => [resetBiometrics ?? false];
}

// Eventos para validação de documentos
class CheckCpfExistsEvent extends AuthEvent {
  final String cpf;

  CheckCpfExistsEvent({required this.cpf});

  @override
  List<Object?> get props => [cpf];
}

class CheckCnpjExistsEvent extends AuthEvent {
  final String cnpj;

  CheckCnpjExistsEvent({required this.cnpj});

  @override
  List<Object?> get props => [cnpj];
}

// Evento para verificar se deve mostrar prompt de biometria
class CheckShouldShowBiometricsPromptEvent extends AuthEvent {}

// Evento para verificar se biometria está habilitada
class CheckBiometricsEnabledEvent extends AuthEvent {}