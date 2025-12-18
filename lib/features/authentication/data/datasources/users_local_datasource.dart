import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/domain/user/user_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache)
/// Responsável APENAS por operações de cache
abstract class IAuthLocalDataSource {
  /// Retorna o UID do usuário em cache, ou null se não existir
  Future<String?> getUserUid();
  
  /// Salva informações do usuário em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheUserInfo(UserEntity userInfo);
  
  /// Salva informações do artista em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheArtistInfo(ArtistEntity artistInfo);
  
  /// Salva informações do cliente em cache
  /// Lança [CacheException] em caso de erro
  Future<void> cacheClientInfo(ClientEntity clientInfo);
  
  /// Limpa todo o cache
  /// Lança [CacheException] em caso de erro
  Future<void> clearCache();
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
      
      if (userInfo != {}) {
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
  Future<void> cacheArtistInfo(ArtistEntity artistInfo) async {
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
  Future<void> cacheClientInfo(ClientEntity clientInfo) async {
    try {
      final clientInfoCacheKey = ClientEntityReference.cachedKey();
      final clientMap = clientInfo.toMap();
      await autoCacheService.cacheDataString(clientInfoCacheKey, clientMap);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao salvar informações do cliente no cache',
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
}



