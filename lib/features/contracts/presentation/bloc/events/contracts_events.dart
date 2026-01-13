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
  final bool? forceRefresh;

  GetContractsByClientEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

// ==================== GET CONTRACTS BY ARTIST EVENTS ====================

class GetContractsByArtistEvent extends ContractsEvent {
  final bool? forceRefresh;

  GetContractsByArtistEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

// ==================== GET CONTRACTS BY GROUP EVENTS ====================

class GetContractsByGroupEvent extends ContractsEvent {
  final String groupUid;
  final bool? forceRefresh;

  GetContractsByGroupEvent({required this.groupUid, this.forceRefresh = false});

  @override
  List<Object?> get props => [groupUid, forceRefresh];
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
  final String contractUid;

  MakePaymentEvent({
    required this.linkPayment,
    required this.contractUid,
  });

  @override
  List<Object?> get props => [linkPayment, contractUid];
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

// ==================== VERIFY PAYMENT EVENTS ====================

class VerifyPaymentEvent extends ContractsEvent {
  final String contractUid;

  VerifyPaymentEvent({required this.contractUid});

  @override
  List<Object?> get props => [contractUid];
}

// ==================== CONFIRM SHOW EVENTS ====================

class ConfirmShowEvent extends ContractsEvent {
  final String contractUid;
  final String confirmationCode;

  ConfirmShowEvent({
    required this.contractUid,
    required this.confirmationCode,
  });

  @override
  List<Object?> get props => [contractUid, confirmationCode];
}

// ==================== RATE ARTIST EVENTS ====================

class RateArtistEvent extends ContractsEvent {
  final String contractUid;
  final double rating;
  final String? comment;

  RateArtistEvent({
    required this.contractUid,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [contractUid, rating, comment];
}

// ==================== SKIP RATING ARTIST EVENTS ====================

class SkipRatingArtistEvent extends ContractsEvent {
  final String contractUid;

  SkipRatingArtistEvent({
    required this.contractUid,
  });

  @override
  List<Object?> get props => [contractUid];
}

// ==================== RATE CLIENT EVENTS ====================

class RateClientEvent extends ContractsEvent {
  final String contractUid;
  final double rating;
  final String? comment;

  RateClientEvent({
    required this.contractUid,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [contractUid, rating, comment];
}

