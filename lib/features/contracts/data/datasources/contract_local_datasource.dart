import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Contracts
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IContractLocalDataSource {
  /// Busca contrato do cache por UID
  Future<ContractEntity?> getCachedContract(String contractUid);

  /// Salva contrato no cache
  Future<void> cacheContract(ContractEntity contract);
  
  /// Busca lista de contratos do cache por cliente
  Future<List<ContractEntity>> getCachedContractsByClient(String clientUid);

  /// Salva lista de contratos do cliente no cache
  Future<void> cacheContractsByClient(String clientUid, List<ContractEntity> contracts);
  
  /// Busca lista de contratos do cache por artista
  Future<List<ContractEntity>> getCachedContractsByArtist(String artistUid);

  /// Salva lista de contratos do artista no cache
  Future<void> cacheContractsByArtist(String artistUid, List<ContractEntity> contracts);
  
  /// Busca lista de contratos do cache por grupo
  Future<List<ContractEntity>> getCachedContractsByGroup(String groupUid);

  /// Salva lista de contratos do grupo no cache
  Future<void> cacheContractsByGroup(String groupUid, List<ContractEntity> contracts);
  
  /// Limpa cache de contratos
  Future<void> clearContractsCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ContractLocalDataSourceImpl implements IContractLocalDataSource {
  final ILocalCacheService autoCacheService;

  ContractLocalDataSourceImpl({required this.autoCacheService});

  String _getContractCacheKey(String contractUid) {
    return '${ContractEntityReference.cachedKey()}_$contractUid';
  }

  String _getClientContractsCacheKey(String clientUid) {
    return '${ContractEntityReference.cachedKey()}_client_$clientUid';
  }

  String _getArtistContractsCacheKey(String artistUid) {
    return '${ContractEntityReference.cachedKey()}_artist_$artistUid';
  }

  String _getGroupContractsCacheKey(String groupUid) {
    return '${ContractEntityReference.cachedKey()}_group_$groupUid';
  }

  @override
  Future<ContractEntity?> getCachedContract(String contractUid) async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        _getContractCacheKey(contractUid),
      );
      
      if (cachedData.isEmpty) {
        return null;
      }

      final contract = ContractEntityMapper.fromMap(cachedData);
      return contract.copyWith(uid: contractUid);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter contrato do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheContract(ContractEntity contract) async {
    try {
      if (contract.uid == null || contract.uid!.isEmpty) {
        throw CacheException(
          'Contrato sem UID não pode ser salvo no cache. UID: ${contract.uid}',
        );
      }
      
      final cacheKey = _getContractCacheKey(contract.uid!);
      final contractMap = contract.toMap();
      
      await autoCacheService.cacheDataString(cacheKey, contractMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar contrato no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getCachedContractsByClient(String clientUid) async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        _getClientContractsCacheKey(clientUid),
      );
      
      if (cachedData.isEmpty) {
        return [];
      }

      final contractsList = <ContractEntity>[];
      
      for (var entry in cachedData.entries) {
        final contractMap = entry.value as Map<String, dynamic>;
        final contract = ContractEntityMapper.fromMap(contractMap);
        contractsList.add(contract.copyWith(uid: entry.key));
      }
      
      return contractsList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter contratos do cliente do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheContractsByClient(String clientUid, List<ContractEntity> contracts) async {
    try {
      final cacheKey = _getClientContractsCacheKey(clientUid);
      final contractsMap = <String, dynamic>{};
      
      for (var contract in contracts) {
        if (contract.uid == null || contract.uid!.isEmpty) {
          throw CacheException(
            'Contrato sem UID não pode ser salvo no cache. UID: ${contract.uid}',
          );
        }
        contractsMap[contract.uid!] = contract.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, contractsMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar contratos do cliente no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getCachedContractsByArtist(String artistUid) async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        _getArtistContractsCacheKey(artistUid),
      );
      
      if (cachedData.isEmpty) {
        return [];
      }

      final contractsList = <ContractEntity>[];
      
      for (var entry in cachedData.entries) {
        final contractMap = entry.value as Map<String, dynamic>;
        final contract = ContractEntityMapper.fromMap(contractMap);
        contractsList.add(contract.copyWith(uid: entry.key));
      }
      
      return contractsList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter contratos do artista do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheContractsByArtist(String artistUid, List<ContractEntity> contracts) async {
    try {
      final cacheKey = _getArtistContractsCacheKey(artistUid);
      final contractsMap = <String, dynamic>{};
      
      for (var contract in contracts) {
        if (contract.uid == null || contract.uid!.isEmpty) {
          throw CacheException(
            'Contrato sem UID não pode ser salvo no cache. UID: ${contract.uid}',
          );
        }
        contractsMap[contract.uid!] = contract.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, contractsMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar contratos do artista no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getCachedContractsByGroup(String groupUid) async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        _getGroupContractsCacheKey(groupUid),
      );
      
      if (cachedData.isEmpty) {
        return [];
      }

      final contractsList = <ContractEntity>[];
      
      for (var entry in cachedData.entries) {
        final contractMap = entry.value as Map<String, dynamic>;
        final contract = ContractEntityMapper.fromMap(contractMap);
        contractsList.add(contract.copyWith(uid: entry.key));
      }
      
      return contractsList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter contratos do grupo do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheContractsByGroup(String groupUid, List<ContractEntity> contracts) async {
    try {
      final cacheKey = _getGroupContractsCacheKey(groupUid);
      final contractsMap = <String, dynamic>{};
      
      for (var contract in contracts) {
        if (contract.uid == null || contract.uid!.isEmpty) {
          throw CacheException(
            'Contrato sem UID não pode ser salvo no cache. UID: ${contract.uid}',
          );
        }
        contractsMap[contract.uid!] = contract.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, contractsMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar contratos do grupo no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearContractsCache() async {
    try {
      // Limpar cache individual de contratos seria complexo sem saber todos os UIDs
      // Por enquanto, apenas logamos que o cache foi limpo
      // Em produção, pode-se implementar uma lista de chaves de cache para limpar
      // ou usar um padrão de chave prefixada
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de contratos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

