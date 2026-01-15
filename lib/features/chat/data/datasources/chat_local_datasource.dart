import 'package:app/core/domain/chat/message_entity.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/services/auto_cache_service.dart';

/// Interface para operações locais (cache) de mensagens
abstract class IChatLocalDataSource {
  /// Armazena mensagens em cache
  Future<void> cacheMessages({
    required String contractId,
    required List<MessageEntity> messages,
  });

  /// Busca mensagens do cache
  Future<List<MessageEntity>?> getCachedMessages({
    required String contractId,
  });

  /// Adiciona uma nova mensagem ao cache
  Future<void> addMessageToCache({
    required String contractId,
    required MessageEntity message,
  });

  /// Limpa o cache de mensagens de um contrato
  Future<void> clearCache({
    required String contractId,
  });

  /// Limpa todo o cache de mensagens
  Future<void> clearAllCache();
}

/// Implementação do DataSource local (cache) para mensagens
/// 
/// REGRAS:
/// - Lança [CacheException] em caso de erro
/// - Usa AutoCacheService para persistência local
/// - Armazena mensagens por contractId (chave: CACHED_MESSAGES_{contractId})
/// - NÃO faz validações de negócio
class ChatLocalDataSourceImpl implements IChatLocalDataSource {
  final ILocalCacheService autoCacheService;

  ChatLocalDataSourceImpl({required this.autoCacheService});

  String cachedMessagesKey(String contractId) => MessageEntityReference.cachedMessagesKey(contractId);

  @override
  Future<void> cacheMessages({
    required String contractId,
    required List<MessageEntity> messages,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw CacheException(
          'ID do contrato não pode ser vazio',
        );
      }

      final cacheKey = cachedMessagesKey(contractId);
      final messagesMap = <String, dynamic>{};

      for (var message in messages) {
        if (message.uid == null || message.uid!.isEmpty) {
          throw CacheException(
            'Mensagem sem UID não pode ser salva no cache. ContractId: $contractId',
          );
        }
        messagesMap[message.uid!] = message.toMap();
      }

      await autoCacheService.cacheDataString(cacheKey, messagesMap);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;

      throw CacheException(
        'Erro ao salvar mensagens no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<MessageEntity>?> getCachedMessages({
    required String contractId,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw CacheException(
          'ID do contrato não pode ser vazio',
        );
      }

      final cacheKey = cachedMessagesKey(contractId);
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);

      // Verificar se dados não são vazios
      if (cachedData.isEmpty) {
        return null;
      }

      final messagesList = <MessageEntity>[];
      
      for (var entry in cachedData.entries) {
        try {
          final messageMap = entry.value as Map<String, dynamic>;
          final messageEntity = MessageEntityMapper.fromMap(messageMap);
          final messageWithId = messageEntity.copyWith(uid: entry.key);
          messagesList.add(messageWithId);
        } catch (e) {
          // Se uma mensagem falhar, loga e continua com as outras
          // Não queremos falhar todo o cache por causa de uma mensagem corrompida
          continue;
        }
      }

      // Ordenar por timestamp
      messagesList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messagesList;
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao obter mensagens do cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addMessageToCache({
    required String contractId,
    required MessageEntity message,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw CacheException(
          'ID do contrato não pode ser vazio',
        );
      }

      if (message.uid == null || message.uid!.isEmpty) {
        throw CacheException(
          'Mensagem sem UID não pode ser salva no cache',
        );
      }

      final cacheKey = cachedMessagesKey(contractId);
      
      // Buscar mensagens existentes do cache
      final cachedData = await autoCacheService.getCachedDataString(cacheKey);
      
      // Adicionar nova mensagem
      cachedData[message.uid!] = message.toMap();
      
      // Salvar de volta
      await autoCacheService.cacheDataString(cacheKey, cachedData);
    } catch (e, stackTrace) {
      if (e is CacheException) rethrow;

      throw CacheException(
        'Erro ao adicionar mensagem no cache',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearCache({
    required String contractId,
  }) async {
    try {
      if (contractId.isEmpty) {
        throw CacheException(
          'ID do contrato não pode ser vazio',
        );
      }

      final cacheKey = cachedMessagesKey(contractId);
      await autoCacheService.deleteCachedDataString(cacheKey);
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar cache de mensagens',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      // Nota: Não há uma forma direta de limpar apenas mensagens
      // Uma opção seria manter uma lista de todas as chaves de mensagens
      // Por enquanto, vamos apenas limpar o cache geral se necessário
      // Mas isso não é ideal. Uma implementação melhor seria manter um registro
      // das chaves de cache de mensagens.
      
      // Para uma implementação completa, seria necessário manter uma lista
      // de todos os contractIds que têm mensagens em cache.
      // Por enquanto, este método não faz nada, pois não temos como saber
      // quais chaves de mensagens existem sem iterar sobre todo o cache.
      
      // Se realmente necessário, pode-se implementar um sistema de registro
      // de chaves de cache, mas isso está fora do escopo atual.
    } catch (e, stackTrace) {
      throw CacheException(
        'Erro ao limpar todo o cache de mensagens',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}