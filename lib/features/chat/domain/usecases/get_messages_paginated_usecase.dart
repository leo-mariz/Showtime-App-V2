import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para buscar mensagens paginadas de um chat
/// 
/// Útil para scroll infinito na tela de mensagens
class GetMessagesPaginatedUseCase {
  final IChatRepository repository;

  GetMessagesPaginatedUseCase({required this.repository});

  /// Busca mensagens paginadas de um chat
  /// 
  /// [chatId] - ID do chat
  /// [limit] - Número de mensagens por página (padrão: 50)
  /// [beforeDate] - Busca mensagens anteriores a esta data (para paginação)
  /// 
  /// Retorna [Right(List<MessageEntity>)] com as mensagens
  /// Retorna [Left(ValidationFailure)] se chatId inválido
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<MessageEntity>>> call({
    required String chatId,
    int limit = 50,
    DateTime? beforeDate,
  }) async {
    // Validar chatId
    if (chatId.isEmpty) {
      return const Left(
        ValidationFailure('ID do chat não pode ser vazio'),
      );
    }

    // Validar limit
    if (limit <= 0) {
      return const Left(
        ValidationFailure('Limite deve ser maior que zero'),
      );
    }

    // Limitar máximo de mensagens por página (evitar queries muito grandes)
    final effectiveLimit = limit > 100 ? 100 : limit;

    // Buscar mensagens
    return await repository.getMessagesPaginated(
      chatId: chatId,
      limit: effectiveLimit,
      beforeDate: beforeDate,
    );
  }
}
