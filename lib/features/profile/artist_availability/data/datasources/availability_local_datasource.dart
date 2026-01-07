import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Availability
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IAvailabilityLocalDataSource {
  /// Busca lista de disponibilidades do artista do cache
  /// Retorna lista vazia se não existir no cache
  Future<List<AvailabilityEntity>> getCachedAvailabilities(String artistId);

  /// Salva lista de disponibilidades do artista no cache
  Future<void> cacheAvailabilities(String artistId, List<AvailabilityEntity> availabilities);
  
  /// Busca uma disponibilidade específica do cache
  /// Lança [CacheException] se não encontrada
  Future<AvailabilityEntity> getSingleCachedAvailability(String artistId, String availabilityId);

  /// Salva uma disponibilidade específica no cache
  Future<void> cacheSingleAvailability(String artistId, AvailabilityEntity availability);
  
  /// Limpa cache de disponibilidades do artista
  Future<void> clearAvailabilitiesCache(String artistId);
  
  /// Limpa cache de todas as disponibilidades
  Future<void> clearAllAvailabilitiesCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class AvailabilityLocalDataSourceImpl implements IAvailabilityLocalDataSource {
  final ILocalCacheService autoCacheService;

  AvailabilityLocalDataSourceImpl({required this.autoCacheService});

  /// Gera chave de cache para disponibilidades de um artista
  String _getCacheKey(String artistId) {
    return '${ArtistAvailabilityEntityReference.cachedKey()}_$artistId';
  }

  @override
  Future<List<AvailabilityEntity>> getCachedAvailabilities(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      // Verificar se dados não são vazios
      if (cachedData.isEmpty) {
        return [];
      }

      List<AvailabilityEntity> availabilitiesList = [];
      for (var entry in cachedData.entries) {
        final availabilityMap = entry.value as Map<String, dynamic>;
        final availabilityEntity = AvailabilityEntityMapper.fromMap(availabilityMap);
        final availabilityWithId = availabilityEntity.copyWith(id: entry.key);
        availabilitiesList.add(availabilityWithId);
      }
      return availabilitiesList;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter disponibilidades do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheAvailabilities(String artistId, List<AvailabilityEntity> availabilities) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final availabilitiesMap = <String, dynamic>{};
      
      for (var availability in availabilities) {
        if (availability.id == null || availability.id!.isEmpty) {
          throw CacheException(
            'Disponibilidade sem ID não pode ser salva no cache. ID: ${availability.id}',
          );
        }
        availabilitiesMap[availability.id!] = availability.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, availabilitiesMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar disponibilidades no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityEntity> getSingleCachedAvailability(
    String artistId,
    String availabilityId,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      if (availabilityId.isEmpty) {
        throw const CacheException('ID da disponibilidade não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      if (cachedData.isEmpty || !cachedData.containsKey(availabilityId)) {
        throw CacheException(
          'Disponibilidade não encontrada no cache: $availabilityId',
        );
      }
      
      final availabilityMap = cachedData[availabilityId] as Map<String, dynamic>;
      final availabilityEntity = AvailabilityEntityMapper.fromMap(availabilityMap);
      final availabilityWithId = availabilityEntity.copyWith(id: availabilityId);
      return availabilityWithId;
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao obter disponibilidade do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheSingleAvailability(
    String artistId,
    AvailabilityEntity availability,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      if (availability.id == null || availability.id!.isEmpty) {
        throw const CacheException(
          'Disponibilidade deve ter um ID válido para ser salva no cache',
        );
      }
      
      final cacheKey = _getCacheKey(artistId);
      // Busca cache existente para não sobrescrever outras disponibilidades
      final existingCache = await autoCacheService.getCachedDataString(cacheKey);
      final availabilityMap = availability.toMap();
      existingCache[availability.id!] = availabilityMap;
      await autoCacheService.cacheDataString(cacheKey, existingCache);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;
      throw CacheException(
        'Erro ao salvar disponibilidade no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAvailabilitiesCache(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const CacheException('ID do artista não pode ser vazio');
      }

      final cacheKey = _getCacheKey(artistId);
      await autoCacheService.deleteCachedDataString(cacheKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de disponibilidades',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllAvailabilitiesCache() async {
    try {
      // Limpar todo o cache (isso limpa tudo, não apenas disponibilidades)
      // Se quiser uma implementação mais específica, seria necessário
      // manter uma lista de chaves de cache de disponibilidades
      await autoCacheService.clearCache();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar todo o cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

