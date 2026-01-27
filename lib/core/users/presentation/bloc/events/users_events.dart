import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET USER DATA EVENTS ====================

class GetUserDataEvent extends UsersEvent {}

// ==================== CHECK DOCUMENT EXISTS EVENTS ====================

class CheckCpfExistsEvent extends UsersEvent {
  final String cpf;

  CheckCpfExistsEvent({required this.cpf});

  @override
  List<Object?> get props => [cpf];
}

class CheckCnpjExistsEvent extends UsersEvent {
  final String cnpj;

  CheckCnpjExistsEvent({required this.cnpj});

  @override
  List<Object?> get props => [cnpj];
}


// ==================== RESET EVENT ====================

class ResetUsersEvent extends UsersEvent {}