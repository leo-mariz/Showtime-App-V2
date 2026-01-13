import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface para operações locais (cache) de favoritos
abstract class IFavoriteLocalDataSource {
  /// Armazena a lista de favoritos em cache
  Future<void> cacheFavorites({
    required String clientId,
    required List<FavoriteArtistEntity> favorites,
  });

  /// Busca a lista de favoritos do cache
  Future<List<FavoriteArtistEntity>?> getCachedFavorites({
    required String clientId,
  });

  /// Armazena a verificação de favorito em cache
  Future<void> cacheIsFavorite({
    required String clientId,
    required String artistId,
    required bool isFavorite,
  });

  /// Busca a verificação de favorito do cache
  Future<bool?> getCachedIsFavorite({
    required String clientId,
    required String artistId,
  });

  /// Limpa todo o cache de favoritos de um cliente
  Future<void> clearCache({required String clientId});

  /// Limpa cache específico de verificação de favorito
  Future<void> clearIsFavoriteCache({
    required String clientId,
    required String artistId,
  });
}

/// Implementação do datasource local de favoritos
class FavoriteLocalDataSourceImpl implements IFavoriteLocalDataSource {
  final ILocalCacheService autoCache;

  /// TTL (Time To Live) para o cache de favoritos: 5 minutos
  static const Duration favoritesCacheTTL = Duration(minutes: 5);

  FavoriteLocalDataSourceImpl({required this.autoCache});

  @override
  Future<void> cacheFavorites({
    required String clientId,
    required List<FavoriteArtistEntity> favorites,
  }) async {
    final key = FavoriteArtistEntityReference.cachedFavoritesKey(clientId);
    
    // Serializar a lista para JSON
    final jsonList = favorites.map((fav) => fav.toMap()).toList();
    
    await autoCache.cacheDataString(
      key,
      {'favorites': jsonList, 'cachedAt': DateTime.now().toIso8601String()},
    );
  }

  @override
  Future<List<FavoriteArtistEntity>?> getCachedFavorites({
    required String clientId,
  }) async {
    final key = FavoriteArtistEntityReference.cachedFavoritesKey(clientId);
    
    try {
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      // Verificar se o cache ainda é válido (TTL manual)
      final cachedAtStr = cachedData['cachedAt'] as String?;
      if (cachedAtStr != null) {
        final cachedAt = DateTime.parse(cachedAtStr);
        final now = DateTime.now();
        
        if (now.difference(cachedAt) > favoritesCacheTTL) {
          // Cache expirado
          await clearCache(clientId: clientId);
          return null;
        }
      }

      // Deserializar a lista
      final jsonList = cachedData['favorites'] as List<dynamic>?;
      if (jsonList == null) {
        return null;
      }

      return jsonList
          .map((json) => FavoriteArtistEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Se houver erro ao deserializar, limpar cache
      await clearCache(clientId: clientId);
      return null;
    }
  }

  @override
  Future<void> cacheIsFavorite({
    required String clientId,
    required String artistId,
    required bool isFavorite,
  }) async {
    final key = FavoriteArtistEntityReference.cachedIsFavoriteKey(
      clientId,
      artistId,
    );
    
    await autoCache.cacheDataString(
      key,
      {'isFavorite': isFavorite, 'cachedAt': DateTime.now().toIso8601String()},
    );
  }

  @override
  Future<bool?> getCachedIsFavorite({
    required String clientId,
    required String artistId,
  }) async {
    final key = FavoriteArtistEntityReference.cachedIsFavoriteKey(
      clientId,
      artistId,
    );
    
    try {
      final cachedData = await autoCache.getCachedDataString(key);
      
      if (cachedData.isEmpty) {
        return null;
      }

      // Verificar se o cache ainda é válido (TTL manual)
      final cachedAtStr = cachedData['cachedAt'] as String?;
      if (cachedAtStr != null) {
        final cachedAt = DateTime.parse(cachedAtStr);
        final now = DateTime.now();
        
        if (now.difference(cachedAt) > favoritesCacheTTL) {
          // Cache expirado
          await clearIsFavoriteCache(clientId: clientId, artistId: artistId);
          return null;
        }
      }

      return cachedData['isFavorite'] as bool?;
    } catch (e) {
      // Se houver erro, limpar cache específico
      await clearIsFavoriteCache(clientId: clientId, artistId: artistId);
      return null;
    }
  }

  @override
  Future<void> clearCache({required String clientId}) async {
    final key = FavoriteArtistEntityReference.cachedFavoritesKey(clientId);
    await autoCache.deleteCachedDataString(key);
  }

  @override
  Future<void> clearIsFavoriteCache({
    required String clientId,
    required String artistId,
  }) async {
    final key = FavoriteArtistEntityReference.cachedIsFavoriteKey(
      clientId,
      artistId,
    );
    await autoCache.deleteCachedDataString(key);
  }
}

