import 'package:app/core/services/auto_cache_service.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/entities/user_chat_info_entity.dart';
import 'package:flutter/foundation.dart';

/// Interface para operações locais (cache) de chat
abstract class IChatLocalDataSource {
  // ==================== CHAT CACHE ====================
  
  /// Armazena um chat específico em cache
  Future<void> cacheChat({
    required ChatEntity chat,
  });

  /// Busca um chat específico do cache
  Future<ChatEntity?> getCachedChat(String chatId);

  /// Armazena lista de chats de um usuário em cache
  Future<void> cacheUserChats({
    required String userId,
    required List<ChatEntity> chats,
  });

  /// Busca lista de chats de um usuário do cache
  Future<List<ChatEntity>?> getCachedUserChats(String userId);

  /// Verifica se o cache de chats de um usuário é válido
  Future<bool> isUserChatsCacheValid(String userId);

  // ==================== MESSAGES CACHE ====================

  /// Armazena mensagens de um chat em cache
  Future<void> cacheMessages({
    required String chatId,
    required List<MessageEntity> messages,
  });

  /// Busca mensagens de um chat do cache
  Future<List<MessageEntity>?> getCachedMessages(String chatId);

  /// Verifica se o cache de mensagens é válido
  Future<bool> isMessagesCacheValid(String chatId);

  // ==================== UNREAD COUNT CACHE ====================

  /// Armazena contador de mensagens não lidas em cache
  Future<void> cacheUnreadCount({
    required String userId,
    required int count,
  });

  /// Busca contador de mensagens não lidas do cache
  Future<int?> getCachedUnreadCount(String userId);

  // ==================== CLEAR CACHE ====================

  /// Limpa cache de um chat específico
  Future<void> clearChatCache(String chatId);

  /// Limpa cache de chats de um usuário
  Future<void> clearUserChatsCache(String userId);

  /// Limpa todo o cache de chat relacionado a um usuário (lista de chats + contador de não lidas).
  Future<void> clearChatsCache(String userId);

  /// Limpa todo o cache de chat
  Future<void> clearAllCache();
}

/// Implementação do datasource local de chat
class ChatLocalDataSourceImpl implements IChatLocalDataSource {
  final ILocalCacheService autoCache;

  // Duração do cache (24 horas)
  static const Duration cacheDuration = Duration(hours: 24);
  
  // Duração do cache de mensagens (mais curto - 1 hora)
  static const Duration messagesCacheDuration = Duration(hours: 1);

  ChatLocalDataSourceImpl({required this.autoCache});

  // ==================== CHAT CACHE ====================

  @override
  Future<void> cacheChat({required ChatEntity chat}) async {
    try {
      final key = ChatEntityReference.cachedChatKey(chat.chatId);
      await autoCache.cacheDataString(
        key,
        {
          'chat': chat.toMap(),
          'cachedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Erro ao cachear não é crítico - apenas logar
      if (kDebugMode) {
        print('Erro ao cachear chat: $e');
      }
    }
  }

  @override
  Future<ChatEntity?> getCachedChat(String chatId) async {
    try {
      final key = ChatEntityReference.cachedChatKey(chatId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      // Verificar validade do cache
      final cachedAtStr = cachedData['cachedAt'] as String?;
      if (cachedAtStr != null) {
        final cachedAt = DateTime.parse(cachedAtStr);
        if (DateTime.now().difference(cachedAt) > cacheDuration) {
          await clearChatCache(chatId);
          return null;
        }
      }

      final chatMap = cachedData['chat'] as Map<String, dynamic>?;
      if (chatMap == null) {
        return null;
      }

      return ChatEntityMapper.fromMap(chatMap);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar chat do cache: $e');
      }
      return null;
    }
  }

  @override
  Future<void> cacheUserChats({
    required String userId,
    required List<ChatEntity> chats,
  }) async {
    try {
      final key = ChatEntityReference.cachedUserChatsKey(userId);
      final jsonList = chats.map((chat) => chat.toMap()).toList();

      await autoCache.cacheDataString(
        key,
        {
          'chats': jsonList,
          'cachedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cachear chats do usuário: $e');
      }
    }
  }

  @override
  Future<List<ChatEntity>?> getCachedUserChats(String userId) async {
    try {
      final key = ChatEntityReference.cachedUserChatsKey(userId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      // Verificar validade
      if (!await isUserChatsCacheValid(userId)) {
        await clearUserChatsCache(userId);
        return null;
      }

      final jsonList = cachedData['chats'] as List<dynamic>?;
      if (jsonList == null) {
        return null;
      }

      return jsonList
          .map((json) => ChatEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar chats do usuário do cache: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> isUserChatsCacheValid(String userId) async {
    try {
      final key = ChatEntityReference.cachedUserChatsKey(userId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return false;
      }

      final cachedAtStr = cachedData['cachedAt'] as String?;
      if (cachedAtStr == null) {
        return false;
      }

      final cachedAt = DateTime.parse(cachedAtStr);
      return DateTime.now().difference(cachedAt) <= cacheDuration;
    } catch (e) {
      return false;
    }
  }

  // ==================== MESSAGES CACHE ====================

  @override
  Future<void> cacheMessages({
    required String chatId,
    required List<MessageEntity> messages,
  }) async {
    try {
      final key = MessageEntityReference.cachedMessagesKey(chatId);
      final jsonList = messages.map((msg) => msg.toMap()).toList();

      await autoCache.cacheDataString(
        key,
        {
          'messages': jsonList,
          'cachedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cachear mensagens: $e');
      }
    }
  }

  @override
  Future<List<MessageEntity>?> getCachedMessages(String chatId) async {
    try {
      final key = MessageEntityReference.cachedMessagesKey(chatId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      // Verificar validade
      if (!await isMessagesCacheValid(chatId)) {
        return null;
      }

      final jsonList = cachedData['messages'] as List<dynamic>?;
      if (jsonList == null) {
        return null;
      }

      return jsonList
          .map((json) => MessageEntityMapper.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar mensagens do cache: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> isMessagesCacheValid(String chatId) async {
    try {
      final key = MessageEntityReference.cachedMessagesKey(chatId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return false;
      }

      final cachedAtStr = cachedData['cachedAt'] as String?;
      if (cachedAtStr == null) {
        return false;
      }

      final cachedAt = DateTime.parse(cachedAtStr);
      return DateTime.now().difference(cachedAt) <= messagesCacheDuration;
    } catch (e) {
      return false;
    }
  }

  // ==================== UNREAD COUNT CACHE ====================

  @override
  Future<void> cacheUnreadCount({
    required String userId,
    required int count,
  }) async {
    try {
      final key = UserChatInfoEntityReference.unreadCountCacheKey(userId);
      await autoCache.cacheDataString(
        key,
        {
          'count': count,
          'cachedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cachear contador de não lidas: $e');
      }
    }
  }

  @override
  Future<int?> getCachedUnreadCount(String userId) async {
    try {
      final key = UserChatInfoEntityReference.unreadCountCacheKey(userId);
      final cachedData = await autoCache.getCachedDataString(key);

      if (cachedData.isEmpty) {
        return null;
      }

      return cachedData['count'] as int?;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar contador de não lidas do cache: $e');
      }
      return null;
    }
  }

  // ==================== CLEAR CACHE ====================

  @override
  Future<void> clearChatCache(String chatId) async {
    try {
      final chatKey = ChatEntityReference.cachedChatKey(chatId);
      final messagesKey = MessageEntityReference.cachedMessagesKey(chatId);
      
      await Future.wait([
        autoCache.deleteCachedDataString(chatKey),
        autoCache.deleteCachedDataString(messagesKey),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar cache do chat: $e');
      }
    }
  }

  @override
  Future<void> clearUserChatsCache(String userId) async {
    try {
      final key = ChatEntityReference.cachedUserChatsKey(userId);
      await autoCache.deleteCachedDataString(key);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar cache de chats do usuário: $e');
      }
    }
  }

  @override
  Future<void> clearChatsCache(String userId) async {
    try {
      final userChatsKey = ChatEntityReference.cachedUserChatsKey(userId);
      final unreadKey = UserChatInfoEntityReference.unreadCountCacheKey(userId);
      await Future.wait([
        autoCache.deleteCachedDataString(userChatsKey),
        autoCache.deleteCachedDataString(unreadKey),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar cache de chats: $e');
      }
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      // Nota: Este método limpa todo o cache do AutoCacheService
      // Para uma implementação mais específica, seria necessário
      // manter uma lista de todas as chaves de cache criadas
      if (kDebugMode) {
        print('Limpeza completa do cache de chat não implementada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar todo o cache: $e');
      }
    }
  }
}
