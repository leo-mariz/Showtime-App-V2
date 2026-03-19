import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/features/app_content/domain/entities/app_content_entity.dart';

/// Interface do DataSource local (cache) para AppContent.
abstract class IAppContentLocalDataSource {
  /// Busca conteúdo do cache.
  Future<AppContentEntity?> getCachedContent(AppContentType type);

  /// Salva conteúdo no cache.
  Future<void> cacheContent(AppContentType type, AppContentEntity entity);

  /// Limpa cache do tipo.
  Future<void> clearContentCache(AppContentType type);
}

/// Implementação usando ILocalCacheService.
class AppContentLocalDataSourceImpl implements IAppContentLocalDataSource {
  final ILocalCacheService autoCacheService;

  AppContentLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<AppContentEntity?> getCachedContent(AppContentType type) async {
    try {
      final key = AppContentEntity.cachedKey(type);
      final cached = await autoCacheService.getCachedDataString(key);
      if (cached.isEmpty) return null;

      final content = cached['content'] as String? ?? '';
      final updatedAtMs = cached['updatedAt'];
      final updatedAt = updatedAtMs is int
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs)
          : null;

      return AppContentEntity(content: content, updatedAt: updatedAt);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter conteúdo do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheContent(AppContentType type, AppContentEntity entity) async {
    try {
      final key = AppContentEntity.cachedKey(type);
      final map = <String, dynamic>{
        'content': entity.content,
        if (entity.updatedAt != null)
          'updatedAt': entity.updatedAt!.millisecondsSinceEpoch,
      };
      await autoCacheService.cacheDataString(key, map);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar conteúdo no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearContentCache(AppContentType type) async {
    try {
      final key = AppContentEntity.cachedKey(type);
      await autoCacheService.deleteCachedDataString(key);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache do conteúdo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
