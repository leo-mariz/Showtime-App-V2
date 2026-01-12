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

class GetContractsByClientEvent extends ContractsEvent {}

// ==================== GET CONTRACTS BY ARTIST EVENTS ====================

class GetContractsByArtistEvent extends ContractsEvent {}

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

// ==================== ACCEPT CONTRACT EVENTS ====================

class AcceptContractEvent extends ContractsEvent {
  final String contractUid;

  AcceptContractEvent({
    required this.contractUid,
  });

  @override
  List<Object?> get props => [contractUid];
}

// ==================== REJECT CONTRACT EVENTS ====================

class RejectContractEvent extends ContractsEvent {
  final String contractUid;

  RejectContractEvent({
    required this.contractUid,
  });

  @override
  List<Object?> get props => [contractUid];
}

// ==================== MAKE PAYMENT EVENTS ====================

class MakePaymentEvent extends ContractsEvent {
  final String linkPayment;

  MakePaymentEvent({
    required this.linkPayment,
  });

  @override
  List<Object?> get props => [linkPayment];
}

// ==================== CANCEL CONTRACT EVENTS ====================

class CancelContractEvent extends ContractsEvent {
  final String contractUid;
  final String canceledBy; // 'CLIENT' ou 'ARTIST'
  final String? cancelReason;

  CancelContractEvent({
    required this.contractUid,
    required this.canceledBy,
    this.cancelReason,
  });

  @override
  List<Object?> get props => [contractUid, canceledBy, cancelReason];
}

