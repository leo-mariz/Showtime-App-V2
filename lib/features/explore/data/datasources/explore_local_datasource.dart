import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';

/// Interface do DataSource local (cache) para Explore
/// Responsável APENAS por operações de cache com timestamp
/// 
/// REGRAS:
/// - Cache de artistas: validade de 2 horas
/// - Cache de disponibilidades por dia: validade de 2 horas
/// - Lança [CacheException] em caso de erro
abstract class IExploreLocalDataSource {
  // ==================== ARTISTS CACHE ====================
  
  /// Busca artistas do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  Future<List<ArtistEntity>?> getCachedArtists();
  
  /// Verifica se cache de artistas é válido (menos de 2 horas)
  Future<bool> isArtistsCacheValid();
  
  /// Salva artistas no cache com timestamp
  Future<void> cacheArtists(List<ArtistEntity> artists);
  
  // ==================== AVAILABILITY DAY CACHE ====================
  
  /// Busca disponibilidade de um dia específico do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  /// 
  /// [artistId]: ID do artista
  /// [date]: Data específica (formato: YYYY-MM-DD)
  Future<AvailabilityDayEntity?> getCachedAvailabilityDay(
    String artistId,
    DateTime date,
  );
  
  /// Verifica se cache de disponibilidade do dia é válido (menos de 2 horas)
  /// 
  /// [artistId]: ID do artista
  /// [date]: Data específica (formato: YYYY-MM-DD)
  Future<bool> isAvailabilityDayCacheValid(
    String artistId,
    DateTime date,
  );
  
  /// Salva disponibilidade do dia no cache com timestamp
  /// 
  /// [artistId]: ID do artista
  /// [date]: Data específica (formato: YYYY-MM-DD)
  /// [availabilityDay]: Disponibilidade do dia (pode ser null se não houver disponibilidade)
  Future<void> cacheAvailabilityDay(
    String artistId,
    DateTime date,
    AvailabilityDayEntity? availabilityDay,
  );
  
  /// Limpa cache de disponibilidade de um dia específico
  Future<void> clearAvailabilityDayCache(String artistId, DateTime date);
  
  /// Limpa cache de todas as disponibilidades de um artista
  Future<void> clearAllAvailabilitiesCache(String artistId);

  /// Busca todas as disponibilidades de um artista do cache (se válido)
  /// Retorna null se cache não existir ou estiver expirado
  /// 
  /// [artistId]: ID do artista
  Future<List<DateTime>?> getCachedAllAvailabilities(String artistId);

  /// Salva todas as disponibilidades de um artista no cache com timestamp
  /// 
  /// [artistId]: ID do artista
  /// [allAvailabilities]: Lista de datas de disponibilidades (pode ser vazia)
  Future<void> cacheAllAvailabilities(
    String artistId,
    List<DateTime> allAvailabilities,
  );


  /// Verifica se cache de todas as disponibilidades é válido (menos de 2 horas)
  /// 
  /// [artistId]: ID do artista
  Future<bool> isAllAvailabilitiesCacheValid(String artistId);


  /// Limpa todo o cache de explorar
  Future<void> clearExploreCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ExploreLocalDataSourceImpl implements IExploreLocalDataSource {
  final ILocalCacheService autoCacheService;

  // ==================== CACHE FIELD KEYS (Constantes) ====================
  /// Chave do campo 'artists' dentro do objeto de cache
  static const String _cacheFieldArtists = 'artists';
  
  /// Chave do campo 'availabilityDay' dentro do objeto de cache
  static const String _cacheFieldAvailabilityDay = 'availabilityDay';

  /// Chave do campo 'allAvailabilities' dentro do objeto de cache
  static const String _cacheFieldAllAvailabilities = 'artistDaysAvailable';
  
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

//   // ==================== AVAILABILITY DAY CACHE ====================

  /// Gera chave de cache para disponibilidade de um dia específico
  String _getAvailabilityDayCacheKey(String artistId, DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final dayId = '$year-$month-$day';
    return '${ArtistWithAvailabilitiesEntityReference.availabilitiesCacheKeyPrefix}${artistId}_$dayId';
  }

  @override
  Future<AvailabilityDayEntity?> getCachedAvailabilityDay(
    String artistId,
    DateTime date,
  ) async {
    try {
      if (!await isAvailabilityDayCacheValid(artistId, date)) {
        return null; // Cache expirado ou não existe
      }

      final key = _getAvailabilityDayCacheKey(artistId, date);
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldAvailabilityDay)) {
        return null;
      }

      // Se o valor for null, significa que não há disponibilidade para aquele dia
      final availabilityDayData = cached[_cacheFieldAvailabilityDay];
      if (availabilityDayData == null) {
        return null;
      }

      return AvailabilityDayEntityMapper.fromMap(
        availabilityDayData as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar disponibilidade do dia do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isAvailabilityDayCacheValid(
    String artistId,
    DateTime date,
  ) async {
    try {
      final key = _getAvailabilityDayCacheKey(artistId, date);
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
  Future<void> cacheAvailabilityDay(
    String artistId,
    DateTime date,
    AvailabilityDayEntity? availabilityDay,
  ) async {
    try {
      final key = _getAvailabilityDayCacheKey(artistId, date);
      
      // Se availabilityDay for null, salvar null no cache para indicar que não há disponibilidade
      final availabilityDayJson = availabilityDay?.toMap();
      
      await autoCacheService.cacheDataString(key, {
        _cacheFieldAvailabilityDay: availabilityDayJson,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar disponibilidade do dia no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAvailabilityDayCache(String artistId, DateTime date) async {
    try {
      final key = _getAvailabilityDayCacheKey(artistId, date);
      await autoCacheService.deleteCachedDataString(key);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de disponibilidade do dia',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== ALL AVAILABILITIES CACHE ====================

  /// Gera chave de cache para todas as disponibilidades de um artista (índice)
  String _getAllAvailabilitiesCacheKey(String artistId) {
    return '${ArtistWithAvailabilitiesEntityReference.availabilitiesCacheKeyPrefix}${artistId}_artistDaysAvailable';
  }

  @override
  Future<List<DateTime>?> getCachedAllAvailabilities(String artistId) async {
    try {
      if (!await isAllAvailabilitiesCacheValid(artistId)) {
        return null; // Cache expirado ou não existe
      }

      final key = _getAllAvailabilitiesCacheKey(artistId);
      final cached = await autoCacheService.getCachedDataString(key);
      
      if (cached.isEmpty || !cached.containsKey(_cacheFieldAllAvailabilities)) {
        return null;
      }

      final daysList = cached[_cacheFieldAllAvailabilities] as List<dynamic>;
      
      // Converter lista de timestamps ou strings para DateTime
      return daysList.map((day) {
        if (day is int) {
          // Se for timestamp em milissegundos
          return DateTime.fromMillisecondsSinceEpoch(day);
        } else if (day is String) {
          // Se for string ISO8601
          return DateTime.parse(day);
        } else {
          throw const FormatException('Formato de data inválido no cache');
        }
      }).toList();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar todas as disponibilidades do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isAllAvailabilitiesCacheValid(String artistId) async {
    try {
      final key = _getAllAvailabilitiesCacheKey(artistId);
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
  Future<void> cacheAllAvailabilities(
    String artistId,
    List<DateTime> allAvailabilities,
  ) async {
    try {
      final key = _getAllAvailabilitiesCacheKey(artistId);
      
      // Converter DateTime para timestamps em milissegundos para armazenar
      final daysTimestamps = allAvailabilities
          .map((date) => date.millisecondsSinceEpoch)
          .toList();
      
      await autoCacheService.cacheDataString(key, {
        _cacheFieldAllAvailabilities: daysTimestamps,
        _cacheFieldTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar todas as disponibilidades no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllAvailabilitiesCache(String artistId) async {
    try {
      final key = _getAllAvailabilitiesCacheKey(artistId);
      await autoCacheService.deleteCachedDataString(key);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de todas as disponibilidades',
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
}

