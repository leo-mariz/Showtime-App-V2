import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/features/app_lists/domain/entities/app_list_item_entity.dart';

/// Interface do DataSource local (cache) para AppLists
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IAppListsLocalDataSource {
  /// Busca lista do cache
  Future<List<AppListItemEntity>> getCachedListItems(AppListType listType);

  /// Salva lista no cache
  Future<void> cacheListItems(AppListType listType, List<AppListItemEntity> items);

  /// Limpa cache da lista
  Future<void> clearListItemsCache(AppListType listType);
}

/// Implementação do DataSource local usando ILocalCacheService
class AppListsLocalDataSourceImpl implements IAppListsLocalDataSource {
  final ILocalCacheService autoCacheService;

  AppListsLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<List<AppListItemEntity>> getCachedListItems(AppListType listType) async {
    try {
      final cachedKey = AppListItemEntityReference.cachedKey(listType);
      final cachedData = await autoCacheService.getCachedDataString(cachedKey);

      if (cachedData.isEmpty) {
        return [];
      }

      final itemsList = <AppListItemEntity>[];
      for (var entry in cachedData.entries) {
        final itemMap = entry.value as Map<String, dynamic>;
        final itemEntity = AppListItemEntityMapper.fromMap(itemMap);
        final itemWithId = itemEntity.copyWith(id: entry.key);
        itemsList.add(itemWithId);
      }

      return itemsList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter lista do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheListItems(AppListType listType, List<AppListItemEntity> items) async {
    try {
      final cachedKey = AppListItemEntityReference.cachedKey(listType);
      final itemsMap = <String, Map<String, dynamic>>{};

      for (var item in items) {
        final itemMap = item.toMap();
        // Remove o id do map antes de salvar (já que o id é a chave)
        itemMap.remove('id');
        itemsMap[item.id ?? ''] = itemMap;
      }

      await autoCacheService.cacheDataString(cachedKey, itemsMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar lista no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearListItemsCache(AppListType listType) async {
    try {
      final cachedKey = AppListItemEntityReference.cachedKey(listType);
      await autoCacheService.deleteCachedDataString(cachedKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache da lista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

