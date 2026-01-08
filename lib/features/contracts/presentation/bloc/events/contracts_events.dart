import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ContractsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET CONTRACT EVENTS ====================

class GetContractEvent extends ContractsEvent {
  final String contractUid;

  GetContractEvent({required this.contractUid});

  @override
  List<Object?> get props => [contractUid];
}

// ==================== GET CONTRACTS BY CLIENT EVENTS ====================

class GetContractsByClientEvent extends ContractsEvent {
  final String clientUid;

  GetContractsByClientEvent({required this.clientUid});

  @override
  List<Object?> get props => [clientUid];
}

// ==================== GET CONTRACTS BY ARTIST EVENTS ====================

class GetContractsByArtistEvent extends ContractsEvent {
  final String artistUid;

  GetContractsByArtistEvent({required this.artistUid});

  @override
  List<Object?> get props => [artistUid];
}

// ==================== GET CONTRACTS BY GROUP EVENTS ====================

class GetContractsByGroupEvent extends ContractsEvent {
  final String groupUid;

  GetContractsByGroupEvent({required this.groupUid});

  @override
  List<Object?> get props => [groupUid];
}

// ==================== ADD CONTRACT EVENTS ====================

class AddContractEvent extends ContractsEvent {
  final ContractEntity contract;

  AddContractEvent({
    required this.contract,
  });

  @override
  List<Object?> get props => [contract];
}

// ==================== UPDATE CONTRACT EVENTS ====================

class UpdateContractEvent extends ContractsEvent {
  final ContractEntity contract;

  UpdateContractEvent({
    required this.contract,
  });

  @override
  List<Object?> get props => [contract];
}

// ==================== DELETE CONTRACT EVENTS ====================

class DeleteContractEvent extends ContractsEvent {
  final String contractUid;

  DeleteContractEvent({
    required this.contractUid,
  });

  @override
  List<Object?> get props => [contractUid];
}

