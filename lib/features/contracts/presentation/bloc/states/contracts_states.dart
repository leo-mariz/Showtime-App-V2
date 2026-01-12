import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ContractsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ContractsInitial extends ContractsState {}

// ==================== GET CONTRACT STATES ====================

class GetContractLoading extends ContractsState {}

class GetContractSuccess extends ContractsState {
  final ContractEntity contract;

  GetContractSuccess({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class GetContractFailure extends ContractsState {
  final String error;

  GetContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET CONTRACTS BY CLIENT STATES ====================

class GetContractsByClientLoading extends ContractsState {}

class GetContractsByClientSuccess extends ContractsState {
  final List<ContractEntity> contracts;

  GetContractsByClientSuccess({
    required this.contracts,
  });

  @override
  List<Object?> get props => [contracts];
}

class GetContractsByClientFailure extends ContractsState {
  final String error;

  GetContractsByClientFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET CONTRACTS BY ARTIST STATES ====================

class GetContractsByArtistLoading extends ContractsState {}

class GetContractsByArtistSuccess extends ContractsState {
  final List<ContractEntity> contracts;

  GetContractsByArtistSuccess({
    required this.contracts,
  });

  @override
  List<Object?> get props => [contracts];
}

class GetContractsByArtistFailure extends ContractsState {
  final String error;

  GetContractsByArtistFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== GET CONTRACTS BY GROUP STATES ====================

class GetContractsByGroupLoading extends ContractsState {}

class GetContractsByGroupSuccess extends ContractsState {
  final List<ContractEntity> contracts;

  GetContractsByGroupSuccess({
    required this.contracts,
  });

  @override
  List<Object?> get props => [contracts];
}

class GetContractsByGroupFailure extends ContractsState {
  final String error;

  GetContractsByGroupFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ADD CONTRACT STATES ====================

class AddContractLoading extends ContractsState {}

class AddContractSuccess extends ContractsState {
  final String contractUid;
  final ContractEntity contract;

  AddContractSuccess({
    required this.contractUid,
    required this.contract,
  });

  @override
  List<Object?> get props => [contractUid, contract];
}

class AddContractFailure extends ContractsState {
  final String error;

  AddContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== UPDATE CONTRACT STATES ====================

class UpdateContractLoading extends ContractsState {}

class UpdateContractSuccess extends ContractsState {
  final ContractEntity contract;

  UpdateContractSuccess({required this.contract});

  @override
  List<Object?> get props => [contract];
}

class UpdateContractFailure extends ContractsState {
  final String error;

  UpdateContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE CONTRACT STATES ====================

class DeleteContractLoading extends ContractsState {}

class DeleteContractSuccess extends ContractsState {
  final String contractUid;

  DeleteContractSuccess({required this.contractUid});

  @override
  List<Object?> get props => [contractUid];
}

class DeleteContractFailure extends ContractsState {
  final String error;

  DeleteContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== ACCEPT CONTRACT STATES ====================

class AcceptContractLoading extends ContractsState {}

class AcceptContractSuccess extends ContractsState {}

class AcceptContractFailure extends ContractsState {
  final String error;

  AcceptContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== REJECT CONTRACT STATES ====================

class RejectContractLoading extends ContractsState {}

class RejectContractSuccess extends ContractsState {}

class RejectContractFailure extends ContractsState {
  final String error;

  RejectContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== MAKE PAYMENT STATES ====================

class MakePaymentLoading extends ContractsState {}

class MakePaymentSuccess extends ContractsState {}

class MakePaymentFailure extends ContractsState {
  final String error;

  MakePaymentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== CANCEL CONTRACT STATES ====================

class CancelContractLoading extends ContractsState {}

class CancelContractSuccess extends ContractsState {}

class CancelContractFailure extends ContractsState {
  final String error;

  CancelContractFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== VERIFY PAYMENT STATES ====================

class VerifyPaymentLoading extends ContractsState {}

class VerifyPaymentSuccess extends ContractsState {}

class VerifyPaymentFailure extends ContractsState {
  final String error;

  VerifyPaymentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

