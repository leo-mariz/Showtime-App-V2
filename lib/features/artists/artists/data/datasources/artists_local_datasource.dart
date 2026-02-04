import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache)
/// Responsável APENAS por operações de cache
abstract class IArtistsLocalDataSource {
  /// Salva informações do artista em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheArtist(ArtistEntity artistInfo);
  
  /// Limpa todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> clearArtistCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ArtistsLocalDataSourceImpl implements IArtistsLocalDataSource {
  final ILocalCacheService autoCacheService;

  ArtistsLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<void> cacheArtist(ArtistEntity artistInfo) async {
    try {
      final artistInfoCacheKey = ArtistEntityReference.cachedKey();
      final artistMap = artistInfo.toMap();
      await autoCacheService.cacheDataString(artistInfoCacheKey, artistMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar informações do artista no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearArtistCache() async {
    try {
      await autoCacheService.deleteCachedDataString(
        ArtistEntityReference.cachedKey(),
      );
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}



