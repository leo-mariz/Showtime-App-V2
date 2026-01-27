import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para fechar um chat
/// 
/// Fecha o chat quando:
/// - Contrato é finalizado
/// - Contrato é cancelado
/// - Evento é concluído
class CloseChatUseCase {
  final IChatRepository repository;

  CloseChatUseCase({required this.repository});

  /// Fecha um chat
  /// 
  /// [chatId] - ID do chat a ser fechado
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se chatId inválido
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call({
    required String chatId,
  }) async {
    // Validar chatId
    if (chatId.isEmpty) {
      return const Left(
        ValidationFailure('ID do chat não pode ser vazio'),
      );
    }

    // Fechar chat
    return await repository.closeChat(chatId);
  }
}
