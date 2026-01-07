import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de BankAccount
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar conta bancária (primeiro do cache, depois do remoto)
/// - Save: Salvar ou atualizar conta bancária (cria ou atualiza o documento "account")
/// - Delete: Remover conta bancária
abstract class IBankAccountRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca a conta bancária do artista
  /// Retorna null se não existir
  Future<Either<Failure, BankAccountEntity?>> getBankAccount(String artistId);

  // ==================== SAVE OPERATIONS ====================
  
  /// Salva ou atualiza a conta bancária do artista
  /// Como cada artista tem apenas uma conta, sempre salva no documento "account"
  Future<Either<Failure, void>> saveBankAccount(
    String artistId,
    BankAccountEntity bankAccount,
  );

  // ==================== DELETE OPERATIONS ====================
  
  /// Remove a conta bancária do artista
  Future<Either<Failure, void>> deleteBankAccount(String artistId);
}

