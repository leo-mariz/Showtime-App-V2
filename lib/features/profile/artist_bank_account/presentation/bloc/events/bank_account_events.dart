import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class BankAccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ==================== GET BANK ACCOUNT EVENTS ====================

class GetBankAccountEvent extends BankAccountEvent {}

// ==================== SAVE BANK ACCOUNT EVENTS ====================

class SaveBankAccountEvent extends BankAccountEvent {
  final BankAccountEntity bankAccount;

  SaveBankAccountEvent({
    required this.bankAccount,
  });

  @override
  List<Object?> get props => [bankAccount];
}

// ==================== DELETE BANK ACCOUNT EVENTS ====================

class DeleteBankAccountEvent extends BankAccountEvent {}

