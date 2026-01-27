import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de chat
/// 
/// Coordena operações entre datasource remoto (Firestore) e local (cache)
/// Implementa estratégia de cache para otimizar leituras e reduzir custos
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource remoteDataSource;
  final IChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== CHAT OPERATIONS ====================

  @override
  Future<Either<Failure, ChatEntity>> createChat({
    required String contractId,
    required String clientId,
    required String artistId,
    required String clientName,
    required String artistName,
    String? clientPhoto,
    String? artistPhoto,
  }) async {
    try {
      // Criar chat no Firestore
      final chat = await remoteDataSource.createChat(
        contractId: contractId,
        clientId: clientId,
        artistId: artistId,
        clientName: clientName,
        artistName: artistName,
        clientPhoto: clientPhoto,
        artistPhoto: artistPhoto,
      );

      // Cachear o chat criado
      await localDataSource.cacheChat(chat: chat);

      // Limpar cache de chats do usuário para forçar atualização
      await localDataSource.clearUserChatsCache(clientId);
      await localDataSource.clearUserChatsCache(artistId);

      return Right(chat);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById({
    required String chatId,
    bool forceRefresh = false,
  }) async {
    try {
      // Se não forçar refresh, tentar buscar do cache
      if (!forceRefresh) {
        final cachedChat = await localDataSource.getCachedChat(chatId);
        if (cachedChat != null) {
          return Right(cachedChat);
        }
      }

      // Buscar do Firestore
      final chat = await remoteDataSource.getChatById(chatId);

      // Armazenar em cache
      await localDataSource.cacheChat(chat: chat);

      return Right(chat);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Stream<ChatEntity> getChatStream(String chatId) {
    // Streams não usam cache pois já fornecem dados em tempo real
    return remoteDataSource.getChatStream(chatId);
  }

  @override
  Stream<List<ChatEntity>> getUserChatsStream(String userId, {bool isArtist = false}) {
    // Streams não usam cache pois já fornecem dados em tempo real
    return remoteDataSource.getUserChatsStream(userId, isArtist: isArtist);
  }

  @override
  Future<Either<Failure, void>> closeChat(String chatId) async {
    try {
      // Fechar chat no Firestore
      await remoteDataSource.closeChat(chatId);

      // Limpar cache do chat
      await localDataSource.clearChatCache(chatId);

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== MESSAGE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      // Enviar mensagem no Firestore
      await remoteDataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
      );

      // Não precisamos cachear aqui pois o stream já vai atualizar
      // Mas podemos limpar o cache de mensagens para forçar refresh
      // caso alguém busque novamente sem stream
      // (Opcional, dependendo da estratégia)

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream({
    required String chatId,
    int limit = 50,
  }) {
    // Streams não usam cache pois já fornecem dados em tempo real
    return remoteDataSource.getMessagesStream(
      chatId: chatId,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessagesPaginated({
    required String chatId,
    int limit = 50,
    DateTime? beforeDate,
  }) async {
    try {
      // Para paginação, sempre buscar do remoto
      // (cache de mensagens paginadas seria muito complexo)
      final messages = await remoteDataSource.getMessagesPaginated(
        chatId: chatId,
        limit: limit,
        beforeDate: beforeDate,
      );

      // Opcionalmente, cachear a primeira página se beforeDate for null
      if (beforeDate == null) {
        await localDataSource.cacheMessages(
          chatId: chatId,
          messages: messages,
        );
      }

      return Right(messages);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Marcar como lidas no Firestore
      await remoteDataSource.markMessagesAsRead(
        chatId: chatId,
        userId: userId,
      );

      // Atualizar cache local do contador
      // (será sobrescrito quando o stream atualizar)
      final cachedCount = await localDataSource.getCachedUnreadCount(userId);
      if (cachedCount != null && cachedCount > 0) {
        // Não temos como saber quantas eram deste chat no cache,
        // então vamos limpar o cache para forçar atualização
        await localDataSource.cacheUnreadCount(
          userId: userId,
          count: 0,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== TYPING STATUS ====================

  @override
  Future<Either<Failure, void>> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      // Atualizar status de digitação no Firestore
      await remoteDataSource.updateTypingStatus(
        chatId: chatId,
        userId: userId,
        isTyping: isTyping,
      );

      // Não precisamos cachear status de digitação
      // pois é uma informação muito volátil

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UNREAD COUNT ====================

  @override
  Stream<int> getUnreadCountStream(String userId) {
    // Stream direto do Firestore para tempo real
    // Opcionalmente, podemos cachear o último valor
    return remoteDataSource.getUnreadCountStream(userId).asyncMap((count) async {
      // Atualizar cache com o novo valor
      await localDataSource.cacheUnreadCount(
        userId: userId,
        count: count,
      );
      return count;
    });
  }
}
