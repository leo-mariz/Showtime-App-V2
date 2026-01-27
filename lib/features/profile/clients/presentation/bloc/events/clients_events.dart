import 'package:app/core/domain/client/client_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ClientsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET CLIENT EVENTS ====================

class GetClientEvent extends ClientsEvent {}

// ==================== ADD CLIENT EVENTS ====================

class AddClientEvent extends ClientsEvent {}

// ==================== UPDATE CLIENT EVENTS ====================

class UpdateClientEvent extends ClientsEvent {
  final ClientEntity client;

  UpdateClientEvent({
    required this.client,
  });

  @override
  List<Object?> get props => [client];
}

// ==================== UPDATE CLIENT PREFERENCES EVENTS ====================

class UpdateClientPreferencesEvent extends ClientsEvent {
  final List<String> preferences;

  UpdateClientPreferencesEvent({
    required this.preferences,
  });

  @override
  List<Object?> get props => [preferences];
}

// ==================== UPDATE CLIENT PROFILE PICTURE EVENTS ====================

class UpdateClientProfilePictureEvent extends ClientsEvent {
  final String localFilePath;

  UpdateClientProfilePictureEvent({
    required this.localFilePath,
  });

  @override
  List<Object?> get props => [localFilePath];
}

// ==================== UPDATE CLIENT AGREEMENT EVENTS ====================

class UpdateClientAgreementEvent extends ClientsEvent {
  final bool agreedToTerms;

  UpdateClientAgreementEvent({
    required this.agreedToTerms,
  });

  @override
  List<Object?> get props => [agreedToTerms];
}


// ==================== RESET EVENT ====================

class ResetClientsEvent extends ClientsEvent {}
