import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para marcar mensagens de um chat como lidas
/// 
/// Deve ser chamado quando o usuário abre um chat
class MarkMessagesAsReadUseCase {
  final IChatRepository repository;

  MarkMessagesAsReadUseCase({required this.repository});

  /// Marca todas as mensagens de um chat como lidas para um usuário
  /// 
  /// [chatId] - ID do chat
  /// [userId] - UID do usuário que leu as mensagens
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call({
    required String chatId,
    required String userId,
  }) async {
    // Validar chatId
    if (chatId.isEmpty) {
      return const Left(
        ValidationFailure('ID do chat não pode ser vazio'),
      );
    }

    // Validar userId
    if (userId.isEmpty) {
      return const Left(
        ValidationFailure('ID do usuário não pode ser vazio'),
      );
    }

    // Marcar como lidas
    return await repository.markMessagesAsRead(
      chatId: chatId,
      userId: userId,
    );
  }
}
