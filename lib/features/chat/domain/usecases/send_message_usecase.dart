import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/dtos/send_message_input_dto.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para enviar uma mensagem em um chat
/// 
/// Recebe DTO da camada de apresentação, valida e chama o repository
/// A mensagem já deve estar filtrada (regex) antes de chegar aqui
class SendMessageUseCase {
  final IChatRepository repository;

  SendMessageUseCase({required this.repository});

  /// Envia uma mensagem em um chat
  /// 
  /// [input] - DTO com dados da mensagem (chatId, senderId, text)
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call(
    SendMessageInputDto input,
    String senderId,
  ) async {
    // Validar chatId
    if (input.chatId.isEmpty) {
      return const Left(
        ValidationFailure('ID do chat não pode ser vazio'),
      );
    }

    // Validar senderId
    if (senderId.isEmpty) {
      return const Left(
        ValidationFailure('ID do remetente não pode ser vazio'),
      );
    }

    // Validar texto
    final trimmedText = input.text.trim();
    if (trimmedText.isEmpty) {
      return const Left(
        ValidationFailure('Mensagem não pode ser vazia'),
      );
    }

    // Validar tamanho máximo (1000 caracteres)
    if (trimmedText.length > 1000) {
      return const Left(
        ValidationFailure('Mensagem muito longa (máximo 1000 caracteres)'),
      );
    }

    // Chamar repository com parâmetros individuais
    return await repository.sendMessage(
      chatId: input.chatId,
      senderId: senderId,
      text: trimmedText,
    );
  }
}
