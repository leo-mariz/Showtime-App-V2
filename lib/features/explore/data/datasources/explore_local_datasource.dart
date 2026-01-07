import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';

/// Interface do DataSource local (cache) para Explore
/// Responsável APENAS por operações de cache com timestamp
/// 
/// REGRAS:
/// - Cache de artistas: validade de 1 hora
/// - Cache de disponibilidades: validade de 30 minutos
/// - Lança [CacheException] em caso de erro
abstract class IExploreLocalDataSource {
  // ==================== ARTISTS CACHE ====================
  
  /// Busca artistas do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  Future<List<ArtistEntity>?> getCachedArtists();
  
  /// Verifica se cache de artistas é válido (menos de 1 hora)
  Future<bool> isArtistsCacheValid();
  
  /// Salva artistas no cache com timestamp
  Future<void> cacheArtists(List<ArtistEntity> artists);
  
  // ==================== AVAILABILITIES CACHE ====================
  
  /// Busca disponibilidades do artista do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  Future<List<AvailabilityEntity>?> getCachedAvailabilities(String artistId);
  
  /// Verifica se cache de disponibilidades é válido (menos de 2 horas)
  Future<bool> isAvailabilitiesCacheValid(String artistId);
  
  /// Salva disponibilidades no cache com timestamp
  Future<void> cacheAvailabilities(
    String artistId,
    List<AvailabilityEntity> availabilities,
  );
  
  /// Busca disponibilidades filtradas do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  Future<List<AvailabilityEntity>?> getCachedFilteredAvailabilities(
    String artistId, {
    DateTime? selectedDate,
    String? userGeohash,
  });
  
  /// Verifica se cache de disponibilidades filtradas é válido (menos de 2 horas)
  Future<bool> isFilteredAvailabilitiesCacheValid(
    String artistId, {
    DateTime? selectedDate,
    String? userGeohash,
  });
  
  /// Salva disponibilidades filtradas no cache com timestamp
  Future<void> cacheFilteredAvailabilities(
    String artistId,
    List<AvailabilityEntity> availabilities, {
    DateTime? selectedDate,
    String? userGeohash,
  });
  
  /// Limpa cache de disponibilidades de um artista específico
  Future<void> clearAvailabilitiesCache(String artistId);
  
  /// Limpa todo o cache de explorar
  Future<void> clearExploreCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ExploreLocalDataSourceImpl implements IExploreLocalDataSource {
  final ILocalCacheService autoCacheService;

  // ==================== CACHE FIELD KEYS (Constantes) ====================
  /// Chave do campo 'artists' dentro do objeto de cache
  static const String _cacheFieldArtists = 'artists';
  
  /// Chave do campo 'availabilities' dentro do objeto de cache
  static const String _cacheFieldAvailabilities = 'availabilities';
  
  /// Chave do campo 'timestamp' dentro do objeto de cache
  static const String _cacheFieldTimestamp = 'timestamp';

  ExploreLocalDataSourceImpl({required this.autoCacheService});

  // ==================== ARTISTS CACHE ====================

  @override
  Future<List<ArtistEntity>?> getCachedArtists() async {
    try {
      if (!await isArtistsCacheValid()) {
        return null; // Cache expirado ou não existe
      }

      final cached = await autoCacheService.getCachedDataString(
        ArtistWithAvailabilitiesEntityReference.artistsCacheKey,
      );
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldArtists)) {
        return null;
      }

      final artistsList = cached[_cacheFieldArtists] as List<dynamic>;
      return artistsList
          .map((json) => ArtistEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar artistas do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isArtistsCacheValid() async {
    try {
      final cached = await autoCacheService.getCachedDataString(
        ArtistWithAvailabilitiesEntityReference.artistsCacheKey,
      );
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldTimestamp)) {
        return false; // Cache não existe
      }
      
      final timestamp = cached[_cacheFieldTimestamp] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);
      
      return difference < ArtistWithAvailabilitiesEntityReference.artistsCacheValidity; // Ainda dentro da validade
    } catch (e) {
      return false; // Erro ao verificar, considerar inválido
    }
  }

  @override
  Future<void> cacheArtists(List<ArtistEntity> artists) async {
    try {
      final artistsJson = artists.map((a) => a.toMap()).toList();
      
      await autoCacheService.cacheDataString(
        ArtistWithAvailabilitiesEntityReference.artistsCacheKey,
        {
        _cacheFieldArtists: artistsJson,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar artistas no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== AVAILABILITIES CACHE ====================

  @override
  Future<List<AvailabilityEntity>?> getCachedAvailabilities(String artistId) async {
    try {
      if (!await isAvailabilitiesCacheValid(artistId)) {
        return null; // Cache expirado ou não existe
      }

      final key = ArtistWithAvailabilitiesEntityReference.artistAvailabilitiesCacheKey(artistId);
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldAvailabilities)) {
        return null;
      }

      final availabilitiesList = cached[_cacheFieldAvailabilities] as List<dynamic>;
      return availabilitiesList
          .map((json) => AvailabilityEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar disponibilidades do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isAvailabilitiesCacheValid(String artistId) async {
    try {
      final key = ArtistWithAvailabilitiesEntityReference.artistAvailabilitiesCacheKey(artistId);
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldTimestamp)) {
        return false; // Cache não existe
      }
      
      final timestamp = cached[_cacheFieldTimestamp] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);
      
      return difference < ArtistWithAvailabilitiesEntityReference.availabilitiesCacheValidity; // Ainda dentro da validade
    } catch (e) {
      return false; // Erro ao verificar, considerar inválido
    }
  }

  @override
  Future<void> cacheAvailabilities(
    String artistId,
    List<AvailabilityEntity> availabilities,
  ) async {
    try {
      final key = ArtistWithAvailabilitiesEntityReference.artistAvailabilitiesCacheKey(artistId);
      final availabilitiesJson = availabilities.map((a) => a.toMap()).toList();
      
      await autoCacheService.cacheDataString(key, {
        _cacheFieldAvailabilities: availabilitiesJson,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar disponibilidades no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAvailabilitiesCache(String artistId) async {
    try {
      final key = ArtistWithAvailabilitiesEntityReference.artistAvailabilitiesCacheKey(artistId);
      await autoCacheService.deleteCachedDataString(key);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de disponibilidades',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearExploreCache() async {
    try {
      await autoCacheService.deleteCachedDataString(
        ArtistWithAvailabilitiesEntityReference.artistsCacheKey,
      );
      // Nota: Não limpa disponibilidades individuais aqui
      // Elas expiram naturalmente ou podem ser limpas individualmente
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== FILTERED AVAILABILITIES CACHE ====================

  @override
  Future<List<AvailabilityEntity>?> getCachedFilteredAvailabilities(
    String artistId, {
    DateTime? selectedDate,
    String? userGeohash,
  }) async {
    try {
      if (!await isFilteredAvailabilitiesCacheValid(
        artistId,
        selectedDate: selectedDate,
        userGeohash: userGeohash,
      )) {
        return null; // Cache expirado ou não existe
      }

      final key = ArtistWithAvailabilitiesEntityReference
          .artistAvailabilitiesFilteredCacheKey(
        artistId,
        selectedDate: selectedDate,
        userGeohash: userGeohash,
      );
      
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldAvailabilities)) {
        return null;
      }

      final availabilitiesList = cached[_cacheFieldAvailabilities] as List<dynamic>;
      return availabilitiesList
          .map((json) => AvailabilityEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar disponibilidades filtradas do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isFilteredAvailabilitiesCacheValid(
    String artistId, {
    DateTime? selectedDate,
    String? userGeohash,
  }) async {
    try {
      final key = ArtistWithAvailabilitiesEntityReference
          .artistAvailabilitiesFilteredCacheKey(
        artistId,
        selectedDate: selectedDate,
        userGeohash: userGeohash,
      );
      
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldTimestamp)) {
        return false; // Cache não existe
      }
      
      final timestamp = cached[_cacheFieldTimestamp] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);
      
      return difference < ArtistWithAvailabilitiesEntityReference.availabilitiesCacheValidity;
    } catch (e) {
      return false; // Erro ao verificar, considerar inválido
    }
  }

  @override
  Future<void> cacheFilteredAvailabilities(
    String artistId,
    List<AvailabilityEntity> availabilities, {
    DateTime? selectedDate,
    String? userGeohash,
  }) async {
    try {
      final key = ArtistWithAvailabilitiesEntityReference
          .artistAvailabilitiesFilteredCacheKey(
        artistId,
        selectedDate: selectedDate,
        userGeohash: userGeohash,
      );
      
      final availabilitiesJson = availabilities.map((a) => a.toMap()).toList();
      
      await autoCacheService.cacheDataString(key, {
        _cacheFieldAvailabilities: availabilitiesJson,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar disponibilidades filtradas no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

