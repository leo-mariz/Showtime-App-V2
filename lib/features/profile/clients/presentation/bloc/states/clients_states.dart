import 'package:app/core/domain/client/client_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ClientsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ClientsInitial extends ClientsState {}

// ==================== GET CLIENT STATES ====================

class GetClientLoading extends ClientsState {}

class GetClientSuccess extends ClientsState {
  final ClientEntity client;

  GetClientSuccess({required this.client});

  @override
  List<Object?> get props => [client];
}

class GetClientFailure extends ClientsState {
  final String error;

  GetClientFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE CLIENT STATES ====================

class UpdateClientLoading extends ClientsState {}

class UpdateClientSuccess extends ClientsState {}

class UpdateClientFailure extends ClientsState {
  final String error;

  UpdateClientFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE CLIENT PREFERENCES STATES ====================

class UpdateClientPreferencesLoading extends ClientsState {}

class UpdateClientPreferencesSuccess extends ClientsState {}

class UpdateClientPreferencesFailure extends ClientsState {
  final String error;

  UpdateClientPreferencesFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE CLIENT PROFILE PICTURE STATES ====================

class UpdateClientProfilePictureLoading extends ClientsState {}

class UpdateClientProfilePictureSuccess extends ClientsState {}

class UpdateClientProfilePictureFailure extends ClientsState {
  final String error;

  UpdateClientProfilePictureFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE CLIENT AGREEMENT STATES ====================

class UpdateClientAgreementLoading extends ClientsState {}

class UpdateClientAgreementSuccess extends ClientsState {}

class UpdateClientAgreementFailure extends ClientsState {
  final String error;

  UpdateClientAgreementFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

