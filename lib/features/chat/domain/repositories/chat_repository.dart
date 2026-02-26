import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:dartz/dartz.dart';

/// Interface do repositório de chat
/// Define as operações para gerenciamento de chats e mensagens
abstract class IChatRepository {
  // ==================== CHAT OPERATIONS ====================

  /// Cria um novo chat entre cliente e artista
  /// 
  /// [contractId] - ID do contrato associado
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista
  /// [clientName] - Nome do cliente
  /// [artistName] - Nome do artista
  /// [clientPhoto] - URL da foto do cliente (opcional)
  /// [artistPhoto] - URL da foto do artista (opcional)
  /// 
  /// Retorna [Right(ChatEntity)] com o chat criado
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, ChatEntity>> createChat({
    required String contractId,
    required String clientId,
    required String artistId,
    required String clientName,
    required String artistName,
    String? clientPhoto,
    String? artistPhoto,
  });

  /// Busca um chat por ID
  /// 
  /// [chatId] - ID do chat
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(ChatEntity)] com o chat encontrado
  /// Retorna [Left(Failure)] em caso de erro ou chat não encontrado
  Future<Either<Failure, ChatEntity>> getChatById({
    required String chatId,
    bool forceRefresh = false,
  });

  /// Stream de um chat específico para atualizações em tempo real
  /// 
  /// [chatId] - ID do chat
  /// 
  /// Retorna Stream<ChatEntity> que emite o chat atualizado
  Stream<ChatEntity> getChatStream(String chatId);

  /// Stream de todos os chats de um usuário
  /// 
  /// [userId] - UID do usuário
  /// [isArtist] - Se true, filtra apenas chats onde o usuário é artista. Se false, filtra apenas chats onde o usuário é cliente (anfitrião)
  /// 
  /// Retorna Stream<List<ChatEntity>> com os chats do usuário
  /// ordenados por data da última mensagem (mais recente primeiro)
  Stream<List<ChatEntity>> getUserChatsStream(String userId, {bool isArtist = false});

  /// Fecha um chat
  /// 
  /// [chatId] - ID do chat a ser fechado
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> closeChat(String chatId);

  // ==================== MESSAGE OPERATIONS ====================

  /// Envia uma mensagem em um chat
  /// 
  /// [chatId] - ID do chat
  /// [senderId] - UID do remetente
  /// [text] - Conteúdo da mensagem
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });

  /// Stream de mensagens de um chat para atualizações em tempo real
  /// 
  /// [chatId] - ID do chat
  /// [limit] - Número máximo de mensagens a retornar
  /// 
  /// Retorna Stream<List<MessageEntity>> com as mensagens mais recentes
  /// ordenadas por data (mais recente primeiro)
  Stream<List<MessageEntity>> getMessagesStream({
    required String chatId,
    int limit = 50,
  });

  /// Busca mensagens paginadas de um chat
  /// 
  /// [chatId] - ID do chat
  /// [limit] - Número de mensagens por página
  /// [beforeDate] - Busca mensagens anteriores a esta data (paginação)
  /// 
  /// Retorna [Right(List<MessageEntity>)] com as mensagens
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<MessageEntity>>> getMessagesPaginated({
    required String chatId,
    int limit = 50,
    DateTime? beforeDate,
  });

  /// Marca todas as mensagens de um chat como lidas para um usuário
  /// 
  /// [chatId] - ID do chat
  /// [userId] - UID do usuário que leu as mensagens
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatId,
    required String userId,
  });

  // ==================== TYPING STATUS ====================

  /// Atualiza o status de digitação de um usuário em um chat
  /// 
  /// [chatId] - ID do chat
  /// [userId] - UID do usuário
  /// [isTyping] - true se está digitando, false se parou
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  });

  // ==================== UNREAD COUNT ====================

  /// Stream do contador total de mensagens não lidas de um usuário
  /// 
  /// [userId] - UID do usuário
  /// 
  /// Retorna Stream<int> que emite o total de mensagens não lidas
  Stream<int> getUnreadCountStream(String userId);

  // ==================== CACHE ====================

  /// Limpa o cache local de chats do usuário (lista de chats + contador de não lidas).
  Future<Either<Failure, void>> clearChatsCache(String userId);
}
