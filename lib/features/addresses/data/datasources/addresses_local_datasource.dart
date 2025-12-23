import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Addresses
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IAddressesLocalDataSource {
  /// Retorna lista de endereços em cache, ou lista vazia se não existir
  /// Lança [CacheException] em caso de erro
  Future<List<AddressInfoEntity>> getCachedAddresses();
  
  /// Salva lista de endereços em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheAddresses(List<AddressInfoEntity> addresses);
  
  /// Limpa cache de endereços
  /// Lança [CacheException] em caso de erro
  Future<void> clearAddressesCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class AddressesLocalDataSourceImpl implements IAddressesLocalDataSource {
  final ILocalCacheService autoCacheService;

  AddressesLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<List<AddressInfoEntity>> getCachedAddresses() async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        AddressInfoEntityReference.cachedKey(),
      );
      
      // Verificar se dados não são vazios
      if (cachedData.isEmpty || !cachedData.containsKey('addresses')) {
        return [];
      }

      final addressesList = cachedData['addresses'] as List<dynamic>?;
      if (addressesList == null || addressesList.isEmpty) {
        return [];
      }

      return addressesList
          .map((addressMap) => AddressInfoEntityMapper.fromMap(
                Map<String, dynamic>.from(addressMap as Map),
              ))
          .toList();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter endereços do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheAddresses(List<AddressInfoEntity> addresses) async {
    try {
      final cacheKey = AddressInfoEntityReference.cachedKey();
      final addressesMap = {
        'addresses': addresses.map((address) => address.toMap()).toList(),
      };
      
      await autoCacheService.cacheDataString(cacheKey, addressesMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar endereços no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAddressesCache() async {
    try {
      await autoCacheService.deleteCachedDataString(
        AddressInfoEntityReference.cachedKey(),
      );
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de endereços',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
