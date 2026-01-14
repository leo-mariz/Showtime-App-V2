import 'package:app/core/domain/favorites/favorite_entity.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:flutter/foundation.dart';

/// Interface para operações locais (cache) de favoritos
abstract class IFavoriteLocalDataSource {
  /// Armazena a lista de favoritos em cache
  Future<void> cacheFavorites({
    required List<FavoriteEntity> favorites,
  });

  /// Busca a lista de favoritos do cache
  Future<List<FavoriteEntity>?> getCachedFavorites();

  /// Remove um favorito específico do cache
  Future<void> removeFavorite({
    required String artistId,
  });

  /// Adiciona um favorito específico ao cache
  Future<void> addFavorite({
    required FavoriteEntity favorite,
  });

  /// Limpa todo o cache de favoritos
  Future<void> clearCache();
}

/// Implementação do datasource local de favoritos
class FavoriteLocalDataSourceImpl implements IFavoriteLocalDataSource {
  final ILocalCacheService autoCache;

  static final String key = FavoriteEntityReference.cachedFavoritesKey();
  static const String favoritesFieldKey = 'favorites';
  static const String cachedAtFieldKey = 'cachedAt';

  FavoriteLocalDataSourceImpl({required this.autoCache});

  @override
  Future<void> cacheFavorites({
    required List<FavoriteEntity> favorites,
  }) async {
    try {
      // Serializar a lista para JSON
      final jsonList = favorites.map((fav) => fav.toMap()).toList();
      
      await autoCache.cacheDataString(
        key,
        {
          favoritesFieldKey: jsonList,
          cachedAtFieldKey: DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Em caso de erro ao serializar/cachear, limpar cache
      await clearCache();
      rethrow;
    }
  }

  @override
  Future<List<FavoriteEntity>?> getCachedFavorites() async {
    try {
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      // Deserializar a lista
      final jsonList = cachedData[favoritesFieldKey] as List<dynamic>?;
      if (jsonList == null) {
        return null;
      }

      return jsonList
          .map((json) => FavoriteEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Se houver erro ao deserializar, limpar cache
      await clearCache();
      return null;
    }
  }

  @override
  Future<void> removeFavorite({required String artistId}) async {
    try {
      if (artistId.isEmpty) {
        throw ArgumentError('artistId não pode ser vazio');
      }

      final cachedData = await getCachedFavorites();
      
      // Se não houver cache, não há nada para remover
      if (cachedData == null || cachedData.isEmpty) {
        return;
      }

      // Filtrar removendo o favorito com o artistId especificado
      final updatedFavorites = cachedData
          .where((favorite) => favorite.artistId != artistId)
          .toList();

      // Atualizar cache com a lista atualizada
      await cacheFavorites(favorites: updatedFavorites);
    } catch (e) {
      // Em caso de erro, limpar cache para evitar inconsistências
      await clearCache();
      rethrow;
    }
  }

  @override
  Future<void> addFavorite({required FavoriteEntity favorite}) async {
    try {
      if (favorite.artistId.isEmpty) {
        throw ArgumentError('artistId do favorito não pode ser vazio');
      }

      final cachedData = await getCachedFavorites();
      
      // Se não houver cache, criar nova lista apenas com este favorito
      if (cachedData == null || cachedData.isEmpty) {
        await cacheFavorites(favorites: [favorite]);
        return;
      }

      // Verificar se o favorito já existe
      final favoriteExists = cachedData.any(
        (cachedFavorite) => cachedFavorite.artistId == favorite.artistId,
      );

      // Se já existe, não adicionar novamente (evitar duplicatas)
      if (favoriteExists) {
        return;
      }

      // Adicionar o novo favorito à lista existente
      final updatedFavorites = [...cachedData, favorite];
      
      // Atualizar cache com a lista atualizada
      await cacheFavorites(favorites: updatedFavorites);
    } catch (e) {
      // Em caso de erro, limpar cache para evitar inconsistências
      await clearCache();
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await autoCache.deleteCachedDataString(key);
    } catch (e) {
      // Erro ao limpar cache - logar mas não propagar
      // (não é crítico se falhar ao limpar)
      if (kDebugMode) {
        print('Erro ao limpar cache de favoritos: $e');
      }
    }
  }
}

