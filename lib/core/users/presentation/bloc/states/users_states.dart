import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UsersInitial extends UsersState {}

// ==================== GET USER DATA STATES ====================

class GetUserDataLoading extends UsersState {}

class GetUserDataSuccess extends UsersState {
  final UserEntity user;

  GetUserDataSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class GetUserDataFailure extends UsersState {
  final String error;

  GetUserDataFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CHECK DOCUMENT EXISTS STATES ====================

class DocumentValidationLoading extends UsersState {
  final String document; // CPF ou CNPJ sendo validado

  DocumentValidationLoading({required this.document});

  @override
  List<Object?> get props => [document];
}

class DocumentValidationSuccess extends UsersState {
  final String document;
  final bool exists; // true se já existe, false se está disponível

  DocumentValidationSuccess({
    required this.document,
    required this.exists,
  });

  @override
  List<Object?> get props => [document, exists];
}

class DocumentValidationFailure extends UsersState {
  final String document;
  final String error;

  DocumentValidationFailure({
    required this.document,
    required this.error,
  });

  @override
  List<Object?> get props => [document, error];
}

