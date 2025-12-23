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
  Future<List<AddressInfoEntity>> getCachedAddresses();

  Future<void> cacheAddresses(List<AddressInfoEntity> addresses);
  
  Future<AddressInfoEntity> getSingleCachedAddress(String addressId);

  Future<void> cacheSingleAddress(AddressInfoEntity address);
  
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
      if (cachedData.isEmpty) {
        return [];
      }

      List<AddressInfoEntity> addressesList = [];
      for (var entry in cachedData.entries) {
        final addressMap = entry.value as Map<String, dynamic>;
        final addressEntity = AddressInfoEntityMapper.fromMap(addressMap);
        final addressWithId = addressEntity.copyWith(uid: entry.key);
        addressesList.add(addressWithId);
      }
      return addressesList;
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

      final addressesMap = <String, dynamic>{};
      
      for (var address in addresses) {
        if (address.uid == null || address.uid!.isEmpty) {
          throw CacheException(
            'Endereço sem UID não pode ser salvo no cache. UID: ${address.uid}',
          );
        }
        addressesMap[address.uid!] = address.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, addressesMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar endereços no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AddressInfoEntity> getSingleCachedAddress(String addressId) async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        AddressInfoEntityReference.cachedKey(),
      );
      
      if (cachedData.isEmpty || !cachedData.containsKey(addressId)) {
        throw CacheException('Endereço não encontrado no cache: $addressId');
      }
      
      final addressMap = cachedData[addressId] as Map<String, dynamic>;
      final addressEntity = AddressInfoEntityMapper.fromMap(addressMap);
      final addressWithId = addressEntity.copyWith(uid: addressId);
      return addressWithId;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter endereço do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheSingleAddress(AddressInfoEntity address) async {
    try {
      if (address.uid == null || address.uid!.isEmpty) {
        throw CacheException('Endereço deve ter um UID válido para ser salvo no cache');
      }
      
      final cacheKey = AddressInfoEntityReference.cachedKey();
      // Busca cache existente para não sobrescrever outros endereços
      final existingCache = await autoCacheService.getCachedDataString(cacheKey);
      final addressMap = address.toMap();
      existingCache[address.uid!] = addressMap;
      await autoCacheService.cacheDataString(cacheKey, existingCache);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar endereço no cache',
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
