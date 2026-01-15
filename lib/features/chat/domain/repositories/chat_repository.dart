import 'package:app/core/domain/chat/message_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Chat
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados (primeiro do cache, depois do remoto)
/// - Create: Adicionar nova mensagem
/// - Update: Atualizar mensagem existente (marcar como lida)
/// - Stream: Stream de mensagens em tempo real
abstract class IChatRepository {
  // ==================== GET OPERATIONS ====================
  
  /// Busca todas as mensagens de um contrato
  /// Primeiro tenta buscar do cache, depois do remoto
  /// Se forceRefresh for true, ignora o cache
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String contractId,
    bool forceRefresh = false,
  });

  /// Stream de mensagens em tempo real
  /// Retorna um Stream que emite QuerySnapshot quando há mudanças
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream({
    required String contractId,
  });

  // ==================== CREATE OPERATIONS ====================
  
  /// Envia uma nova mensagem
  /// Retorna o UID da mensagem criada
  Future<Either<Failure, String>> sendMessage({
    required String contractId,
    required MessageEntity message,
  });

  // ==================== UPDATE OPERATIONS ====================
  
  /// Marca mensagens específicas como lidas
  Future<Either<Failure, void>> markMessagesAsRead({
    required String contractId,
    required List<String> messageIds,
    required String readerId,
  });

  /// Marca todas as mensagens não lidas de um contrato como lidas
  Future<Either<Failure, void>> markAllMessagesAsRead({
    required String contractId,
    required String readerId,
  });

  // ==================== CACHE OPERATIONS ====================
  
  /// Limpa o cache de mensagens de um contrato
  Future<Either<Failure, void>> clearCache({
    required String contractId,
  });
}