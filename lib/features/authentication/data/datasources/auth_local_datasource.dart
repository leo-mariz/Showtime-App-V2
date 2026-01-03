import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache)
/// Responsável APENAS por operações de cache
abstract class IAuthLocalDataSource {
  /// Retorna o UID do usuário em cache, ou null se não existir
  Future<String?> getUserUid();
  
  /// Limpa todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> clearCache();

  /// Imprime todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> printCache(String key);
}

/// Implementação do DataSource local usando ILocalCacheService
class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  final ILocalCacheService autoCacheService;

  AuthLocalDataSourceImpl({required this.autoCacheService});

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
  Future<void> clearCache() async {
    try {
      await autoCacheService.clearCache();
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> printCache(String key) async {
    try {
      final cache = await autoCacheService.getCachedDataString(key);
      print('cache: $cache');
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao imprimir cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}



