import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Groups
/// Responsável APENAS por operações de cache
abstract class IGroupsLocalDataSource {
  /// Salva informações de um grupo em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheGroup(GroupEntity group);
  
  /// Busca grupo do cache
  /// Retorna null se não encontrar
  /// Lança [CacheException] em caso de erro
  Future<GroupEntity?> getCachedGroup(String uid);
  
  /// Salva lista de grupos em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheGroupsList(List<GroupEntity> groups);
  
  /// Busca lista de grupos do cache
  /// Retorna lista vazia se não encontrar
  /// Lança [CacheException] em caso de erro
  Future<List<GroupEntity>> getCachedGroupsList();
  
  /// Limpa cache de um grupo específico
  /// Lança [CacheException] em caso de erro
  Future<void> clearGroupCache(String uid);
  
  /// Limpa todo o cache de grupos
  /// Lança [CacheException] em caso de erro
  Future<void> clearGroupsCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class GroupsLocalDataSourceImpl implements IGroupsLocalDataSource {
  final ILocalCacheService autoCacheService;

  GroupsLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<void> cacheGroup(GroupEntity group) async {
    try {
      if (group.uid == null || group.uid!.isEmpty) {
        throw const CacheException('UID do grupo não pode ser vazio para cache');
      }
      
      final groupCacheKey = GroupEntityReference.singleCachedKey(group.uid!);
      final groupMap = group.toMap();
      await autoCacheService.cacheDataString(groupCacheKey, groupMap);
    } catch (e, stackTrace) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(
        'Erro ao salvar informações do grupo no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<GroupEntity?> getCachedGroup(String uid) async {
    try {
      if (uid.isEmpty) {
        return null;
      }
      
      final groupCacheKey = GroupEntityReference.singleCachedKey(uid);
      final cachedData = await autoCacheService.getCachedDataString(groupCacheKey);
      
      if (cachedData.isEmpty) {
        return null;
      }
      
      final groupMap = cachedData;
      final group = GroupEntityMapper.fromMap(groupMap);
      return group.copyWith(uid: uid);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar informações do grupo no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheGroupsList(List<GroupEntity> groups) async {
    try {
      final groupsListCacheKey = GroupEntityReference.listCachedKey();
      final groupsMap = <String, dynamic>{};
      
      for (var group in groups) {
        if (group.uid == null || group.uid!.isEmpty) {
          continue; // Pula grupos sem UID
        }
        groupsMap[group.uid!] = group.toMap();
      }
      
      await autoCacheService.cacheDataString(groupsListCacheKey, groupsMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar lista de grupos no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<GroupEntity>> getCachedGroupsList() async {
    try {
      final groupsListCacheKey = GroupEntityReference.listCachedKey();
      final cachedData = await autoCacheService.getCachedDataString(groupsListCacheKey);
      
      if (cachedData.isEmpty) {
        return [];
      }
      
      final groupsList = <GroupEntity>[];
      for (var entry in cachedData.entries) {
        final groupMap = entry.value as Map<String, dynamic>;
        final group = GroupEntityMapper.fromMap(groupMap);
        groupsList.add(group.copyWith(uid: entry.key));
      }
      
      return groupsList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao buscar lista de grupos no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearGroupCache(String uid) async {
    try {
      if (uid.isEmpty) {
        return;
      }
      
      final groupCacheKey = GroupEntityReference.singleCachedKey(uid);
      await autoCacheService.deleteCachedDataString(groupCacheKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache do grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearGroupsCache() async {
    try {
      final groupsListCacheKey = GroupEntityReference.listCachedKey();
      await autoCacheService.deleteCachedDataString(groupsListCacheKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de grupos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

