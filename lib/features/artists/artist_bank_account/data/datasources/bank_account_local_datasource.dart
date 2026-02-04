import 'package:app/core/domain/artist/bank_account_entity/bank_account_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para BankAccount
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IBankAccountLocalDataSource {
  /// Busca a conta bancária do cache
  Future<BankAccountEntity?> getCachedBankAccount(String artistId);

  /// Salva a conta bancária no cache
  Future<void> cacheBankAccount(String artistId, BankAccountEntity bankAccount);
  
  /// Remove a conta bancária do cache
  Future<void> clearBankAccountCache(String artistId);
}

/// Implementação do DataSource local usando ILocalCacheService
class BankAccountLocalDataSourceImpl implements IBankAccountLocalDataSource {
  final ILocalCacheService autoCacheService;

  BankAccountLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<BankAccountEntity?> getCachedBankAccount(String artistId) async {
    try {
      final cacheKey = BankAccountEntityReference.cachedKey(artistId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      // Verificar se dados não são vazios
      if (cachedData.isEmpty) {
        return null;
      }

      return BankAccountEntityMapper.fromMap(cachedData);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter conta bancária do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheBankAccount(String artistId, BankAccountEntity bankAccount) async {
    try {
      final cacheKey = BankAccountEntityReference.cachedKey(artistId);
      final bankAccountMap = bankAccount.toMap();
      
      await autoCacheService.cacheDataString(cacheKey, bankAccountMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar conta bancária no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearBankAccountCache(String artistId) async {
    try {
      final cacheKey = BankAccountEntityReference.cachedKey(artistId);
      await autoCacheService.deleteCachedDataString(cacheKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de conta bancária',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

