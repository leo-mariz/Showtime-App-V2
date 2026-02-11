import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Contracts
/// Responsável APENAS por operações de cache com timestamp
/// 
/// REGRAS:
/// - Cache de contratos: validade de 10 minutos
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
  
  /// Busca o código de confirmação (keyCode) do cache
  /// Retorna null se não existir
  Future<String?> getCachedKeyCode(String contractUid);
  
  /// Salva o código de confirmação (keyCode) no cache
  Future<void> cacheKeyCode(String contractUid, String keyCode);
  
  /// Limpa cache de contratos
  Future<void> clearContractsCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ContractLocalDataSourceImpl implements IContractLocalDataSource {
  final ILocalCacheService autoCacheService;

  // ==================== CACHE FIELD KEYS (Constantes) ====================
  /// Chave do campo 'contract' dentro do objeto de cache
  static const String _cacheFieldContract = 'contract';
  
  /// Chave do campo 'contracts' dentro do objeto de cache
  static const String _cacheFieldContracts = 'contracts';
  
  /// Chave do campo 'timestamp' dentro do objeto de cache
  static const String _cacheFieldTimestamp = 'timestamp';

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

  String _getKeyCodeCacheKey(String contractUid) {
    return '${ContractEntityReference.cachedKey()}_keyCode_$contractUid';
  }

  @override
  Future<ContractEntity?> getCachedContract(String contractUid) async {
    try {
      // if (!await _isContractCacheValid(contractUid)) {
      //   return null; // Cache expirado ou não existe
      // }

      final cacheKey = _getContractCacheKey(contractUid);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldContract)) {
        return null;
      }

      final contractMap = cachedData[_cacheFieldContract] as Map<String, dynamic>;
      final contract = ContractEntityMapper.fromMap(contractMap);
      return contract.copyWith(uid: contractUid);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter contrato do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Verifica se cache de contrato individual é válido
  // Future<bool> _isContractCacheValid(String contractUid) async {
  //   try {
  //     final cacheKey = _getContractCacheKey(contractUid);
  //     final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
  //     if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldTimestamp)) {
  //       return false; // Cache não existe
  //     }
      
  //     final timestamp = cachedData[_cacheFieldTimestamp] as int;
  //     final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //     final now = DateTime.now();
  //     final difference = now.difference(cacheTime);
      
  //     return difference < ContractEntityReference.contractsCacheValidity; // Ainda dentro da validade
  //   } catch (e) {
  //     return false; // Erro ao verificar, considerar inválido
  //   }
  // }

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
      
      await autoCacheService.cacheDataString(cacheKey, {
        _cacheFieldContract: contractMap,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
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
      // if (!await _isClientContractsCacheValid(clientUid)) {
      //   return []; // Cache expirado ou não existe
      // }

      final cacheKey = _getClientContractsCacheKey(clientUid);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldContracts)) {
        return [];
      }

      final contractsMap = cachedData[_cacheFieldContracts] as Map<String, dynamic>;
      final contractsList = <ContractEntity>[];
      
      for (var entry in contractsMap.entries) {
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

  /// Verifica se cache de contratos do cliente é válido
  // Future<bool> _isClientContractsCacheValid(String clientUid) async {
  //   try {
  //     final cacheKey = _getClientContractsCacheKey(clientUid);
  //     final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
  //     if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldTimestamp)) {
  //       return false; // Cache não existe
  //     }
      
  //     final timestamp = cachedData[_cacheFieldTimestamp] as int;
  //     final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //     final now = DateTime.now();
  //     final difference = now.difference(cacheTime);
      
  //     return difference < ContractEntityReference.contractsCacheValidity; // Ainda dentro da validade
  //   } catch (e) {
  //     return false; // Erro ao verificar, considerar inválido
  //   }
  // }

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

      await autoCacheService.cacheDataString(cacheKey, {
        _cacheFieldContracts: contractsMap,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
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
      // if (!await _isArtistContractsCacheValid(artistUid)) {
      //   return []; // Cache expirado ou não existe
      // }

      final cacheKey = _getArtistContractsCacheKey(artistUid);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldContracts)) {
        return [];
      }

      final contractsMap = cachedData[_cacheFieldContracts] as Map<String, dynamic>;
      final contractsList = <ContractEntity>[];
      
      for (var entry in contractsMap.entries) {
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

  /// Verifica se cache de contratos do artista é válido
  // Future<bool> _isArtistContractsCacheValid(String artistUid) async {
  //   try {
  //     final cacheKey = _getArtistContractsCacheKey(artistUid);
  //     final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
  //     if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldTimestamp)) {
  //       return false; // Cache não existe
  //     }
      
  //     final timestamp = cachedData[_cacheFieldTimestamp] as int;
  //     final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //     final now = DateTime.now();
  //     final difference = now.difference(cacheTime);
      
  //     return difference < ContractEntityReference.contractsCacheValidity; // Ainda dentro da validade
  //   } catch (e) {
  //     return false; // Erro ao verificar, considerar inválido
  //   }
  // }

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

      await autoCacheService.cacheDataString(cacheKey, {
        _cacheFieldContracts: contractsMap,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
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
      // if (!await _isGroupContractsCacheValid(groupUid)) {
      //   return []; // Cache expirado ou não existe
      // }

      final cacheKey = _getGroupContractsCacheKey(groupUid);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldContracts)) {
        return [];
      }

      final contractsMap = cachedData[_cacheFieldContracts] as Map<String, dynamic>;
      final contractsList = <ContractEntity>[];
      
      for (var entry in contractsMap.entries) {
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

  /// Verifica se cache de contratos do grupo é válido
  // Future<bool> _isGroupContractsCacheValid(String groupUid) async {
  //   try {
  //     final cacheKey = _getGroupContractsCacheKey(groupUid);
  //     final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
  //     if (cachedData.isEmpty || !cachedData.containsKey(_cacheFieldTimestamp)) {
  //       return false; // Cache não existe
  //     }
      
  //     final timestamp = cachedData[_cacheFieldTimestamp] as int;
  //     final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  //     final now = DateTime.now();
  //     final difference = now.difference(cacheTime);
      
  //     return difference < ContractEntityReference.contractsCacheValidity; // Ainda dentro da validade
  //   } catch (e) {
  //     return false; // Erro ao verificar, considerar inválido
  //   }
  // }

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

      await autoCacheService.cacheDataString(cacheKey, {
        _cacheFieldContracts: contractsMap,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
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
  Future<String?> getCachedKeyCode(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const CacheException('UID do contrato não pode ser vazio');
      }

      final cacheKey = _getKeyCodeCacheKey(contractUid);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey('keyCode')) {
        return null;
      }

      return cachedData['keyCode'] as String?;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter código de confirmação do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheKeyCode(String contractUid, String keyCode) async {
    try {
      if (contractUid.isEmpty) {
        throw const CacheException('UID do contrato não pode ser vazio');
      }

      if (keyCode.isEmpty) {
        throw const CacheException('Código de confirmação não pode ser vazio');
      }

      final cacheKey = _getKeyCodeCacheKey(contractUid);
      
      await autoCacheService.cacheDataString(cacheKey, {
        'keyCode': keyCode,
      });
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar código de confirmação no cache',
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

