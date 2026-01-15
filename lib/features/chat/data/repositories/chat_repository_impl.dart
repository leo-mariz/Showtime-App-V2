import 'package:app/core/domain/chat/message_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Chat
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
/// - Stream vem diretamente do remoto (tempo real)
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource remoteDataSource;
  final IChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String contractId,
    bool forceRefresh = false,
  }) async {
    try {
      // Primeiro tenta buscar do cache
      if (!forceRefresh) {
        try {
          final cachedMessages = await localDataSource.getCachedMessages(
            contractId: contractId,
          );

          if (cachedMessages != null && cachedMessages.isNotEmpty) {
            return Right(cachedMessages);
          }
        } catch (e) {
          // Se cache falhar, continua para buscar do remoto
          // Não retorna erro aqui, apenas loga se necessário
        }
      }

      // Se não encontrou no cache, busca do remoto
      final messages = await remoteDataSource.getMessages(
        contractId: contractId,
      );

      // Salva no cache após buscar do remoto
      if (messages.isNotEmpty) {
        await localDataSource.cacheMessages(
          contractId: contractId,
          messages: messages,
        );
      }

      return Right(messages);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream({
    required String contractId,
  }) {
    try {
      return remoteDataSource.getMessagesStream(
        contractId: contractId,
      );
    } catch (e) {
      // Stream não retorna Either, então lançamos a exceção
      // O ErrorHandler será chamado no nível superior se necessário
      throw ErrorHandler.handle(e);
    }
  }

  // ==================== CREATE OPERATIONS ====================

  @override
  Future<Either<Failure, String>> sendMessage({
    required String contractId,
    required MessageEntity message,
  }) async {
    try {
      // Envia mensagem no remoto
      final messageId = await remoteDataSource.sendMessage(
        contractId: contractId,
        message: message,
      );

      // Adiciona mensagem ao cache local
      final messageWithId = message.copyWith(uid: messageId);
      await localDataSource.addMessageToCache(
        contractId: contractId,
        message: messageWithId,
      );

      return Right(messageId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String contractId,
    required List<String> messageIds,
    required String readerId,
  }) async {
    try {
      // Marca como lida no remoto
      await remoteDataSource.markMessagesAsRead(
        contractId: contractId,
        messageIds: messageIds,
        readerId: readerId,
      );

      // Atualiza cache local
      // Para isso, precisamos buscar as mensagens atualizadas
      // ou atualizar diretamente no cache
      // Por simplicidade, vamos invalidar o cache e recarregar
      // Uma implementação mais otimizada poderia atualizar apenas as mensagens específicas
      try {
        final updatedMessages = await remoteDataSource.getMessages(
          contractId: contractId,
        );
        await localDataSource.cacheMessages(
          contractId: contractId,
          messages: updatedMessages,
        );
      } catch (e) {
        // Se falhar ao atualizar cache, não é crítico
        // A próxima busca do cache será feita normalmente
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> markAllMessagesAsRead({
    required String contractId,
    required String readerId,
  }) async {
    try {
      // Marca todas como lidas no remoto
      await remoteDataSource.markAllMessagesAsRead(
        contractId: contractId,
        readerId: readerId,
      );

      // Atualiza cache local
      try {
        final updatedMessages = await remoteDataSource.getMessages(
          contractId: contractId,
        );
        await localDataSource.cacheMessages(
          contractId: contractId,
          messages: updatedMessages,
        );
      } catch (e) {
        // Se falhar ao atualizar cache, não é crítico
      }

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CACHE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> clearCache({
    required String contractId,
  }) async {
    try {
      await localDataSource.clearCache(contractId: contractId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}