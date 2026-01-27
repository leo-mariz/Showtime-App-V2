import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para atualizar o status de digitação de um usuário
/// 
/// Exibe "Digitando..." para o outro participante
class UpdateTypingStatusUseCase {
  final IChatRepository repository;

  UpdateTypingStatusUseCase({required this.repository});

  /// Atualiza o status de digitação de um usuário em um chat
  /// 
  /// [chatId] - ID do chat
  /// [userId] - UID do usuário
  /// [isTyping] - true se está digitando, false se parou
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call({
    required String chatId,
    required String userId,
    required bool isTyping,
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

    // Atualizar status
    return await repository.updateTypingStatus(
      chatId: chatId,
      userId: userId,
      isTyping: isTyping,
    );
  }
}
