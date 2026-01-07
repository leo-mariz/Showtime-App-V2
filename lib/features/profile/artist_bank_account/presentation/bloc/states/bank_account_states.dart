import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BankAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BankAccountInitial extends BankAccountState {}

// ==================== GET BANK ACCOUNT STATES ====================

class GetBankAccountLoading extends BankAccountState {}

class GetBankAccountSuccess extends BankAccountState {
  final BankAccountEntity? bankAccount;

  GetBankAccountSuccess({required this.bankAccount});

  @override
  List<Object?> get props => [bankAccount];
}

class GetBankAccountFailure extends BankAccountState {
  final String error;

  GetBankAccountFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== SAVE BANK ACCOUNT STATES ====================

class SaveBankAccountLoading extends BankAccountState {}

class SaveBankAccountSuccess extends BankAccountState {}

class SaveBankAccountFailure extends BankAccountState {
  final String error;

  SaveBankAccountFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

// ==================== DELETE BANK ACCOUNT STATES ====================

class DeleteBankAccountLoading extends BankAccountState {}

class DeleteBankAccountSuccess extends BankAccountState {}

class DeleteBankAccountFailure extends BankAccountState {
  final String error;

  DeleteBankAccountFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

