import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_bank_account/data/datasources/bank_account_local_datasource.dart';
import 'package:app/features/profile/artist_bank_account/data/datasources/bank_account_remote_datasource.dart';
import 'package:app/features/profile/artist_bank_account/domain/repositories/bank_account_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de BankAccount
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class BankAccountRepositoryImpl implements IBankAccountRepository {
  final IBankAccountRemoteDataSource remoteDataSource;
  final IBankAccountLocalDataSource localDataSource;

  BankAccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, BankAccountEntity?>> getBankAccount(String artistId) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedBankAccount = await localDataSource.getCachedBankAccount(artistId);
        if (cachedBankAccount != null) {
          return Right(cachedBankAccount);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final bankAccount = await remoteDataSource.getBankAccount(artistId);
      
      // Salva no cache após buscar do remoto (se encontrou)
      if (bankAccount != null) {
        await localDataSource.cacheBankAccount(artistId, bankAccount);
      }
      
      return Right(bankAccount);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== SAVE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> saveBankAccount(
    String artistId,
    BankAccountEntity bankAccount,
  ) async {
    try {
      // Salva no remoto
      await remoteDataSource.saveBankAccount(artistId, bankAccount);
      
      // Salva no cache após salvar no remoto
      await localDataSource.cacheBankAccount(artistId, bankAccount);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteBankAccount(String artistId) async {
    try {
      // Remove do remoto
      await remoteDataSource.deleteBankAccount(artistId);
      
      // Remove do cache após deletar do remoto
      await localDataSource.clearBankAccountCache(artistId);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

