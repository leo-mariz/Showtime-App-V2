import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface do DataSource local (cache) para Clients
/// Responsável APENAS por operações de cache
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - NÃO faz validações de negócio
abstract class IClientsLocalDataSource {
  /// Busca cliente do cache
  /// Retorna null se não existir
  Future<ClientEntity?> getCachedClient();

  /// Salva cliente no cache
  Future<void> cacheClient(ClientEntity client);
  
  /// Limpa o cache do cliente
  Future<void> clearClientCache();
}

/// Implementação do DataSource local usando ILocalCacheService
class ClientsLocalDataSourceImpl implements IClientsLocalDataSource {
  final ILocalCacheService autoCacheService;

  ClientsLocalDataSourceImpl({required this.autoCacheService});

  @override
  Future<ClientEntity?> getCachedClient() async {
    try {
      final cachedData = await autoCacheService.getCachedDataString(
        ClientEntityReference.cachedKey(),
      );
      
      // Verificar se dados não são vazios
      if (cachedData.isEmpty) {
        return null;
      }

      final clientEntity = ClientEntityMapper.fromMap(cachedData);
      return clientEntity;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter cliente do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheClient(ClientEntity client) async {
    try {
      if (client.uid == null || client.uid!.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio ao salvar no cache',
        );
      }

      final clientMap = client.toMap();
      await autoCacheService.cacheDataString(
        ClientEntityReference.cachedKey(),
        clientMap,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) {
        rethrow;
      }
      throw CacheException(
        'Erro ao salvar cliente no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearClientCache() async {
    try {
      await autoCacheService.deleteCachedDataString(
        ClientEntityReference.cachedKey(),
      );
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache do cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

