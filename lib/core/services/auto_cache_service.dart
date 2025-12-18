import 'package:app/core/errors/exceptions.dart';
import 'package:flutter_auto_cache/flutter_auto_cache.dart';

abstract class ILocalCacheService {
  /// Salva dados no cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheDataString(String key, Map<String, dynamic> data);
  
  /// Busca dados do cache
  /// Lança [CacheException] em caso de erro
  Future<Map<String, dynamic>> getCachedDataString(String key);
  
  /// Deleta dados específicos do cache
  /// Lança [CacheException] em caso de erro
  Future<void> deleteCachedDataString(String key);
  
  /// Limpa todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> clearCache();
}

class AutoCacheServiceImplementation implements ILocalCacheService {
  @override
  Future<void> cacheDataString(String key, Map<String, dynamic> data) async {
    try {
      await AutoCache.data.saveJson(key: key, data: data);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar dados no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCachedDataString(String key) async {
    try {
      final response = await AutoCache.data.getJson(key: key);
      return response.data ?? {};
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar dados do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteCachedDataString(String key) async {
    try {
      await AutoCache.data.delete(key: key);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao deletar dados do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await AutoCache.data.clear();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}


