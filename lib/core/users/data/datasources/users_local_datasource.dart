
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache)
/// Responsável APENAS por operações de cache
abstract class IUsersLocalDataSource {
  /// Retorna o UID do usuário em cache, ou null se não existir
  Future<String?> getUserUid();
  
  /// Salva informações do usuário em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheUserInfo(UserEntity userInfo);
  
  /// Limpa todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> clearUsersCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class UsersLocalDataSourceImpl implements IUsersLocalDataSource {
  final ILocalCacheService autoCacheService;

  UsersLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<String?> getUserUid() async {
    try {
      final userInfo = await autoCacheService.getCachedDataString(
        UserEntityReference.cachedKey(),
      );
      
      // Verificar se userInfo não é vazio (Map vazio retorna {})
      if (userInfo.isNotEmpty && userInfo.keys.isNotEmpty) {
        final userEntity = UserEntityMapper.fromMap(userInfo);
        return userEntity.uid;
      }
      
      return null;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter UID do usuário do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheUserInfo(UserEntity userInfo) async {
    try {
      final userInfoCacheKey = UserEntityReference.cachedKey();
      final userMap = userInfo.toMap();
      await autoCacheService.cacheDataString(userInfoCacheKey, userMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar informações do usuário no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearUsersCache() async {
    try {
      await autoCacheService.deleteCachedDataString(
        UserEntityReference.cachedKey(),
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



