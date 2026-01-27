import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para buscar um chat específico por ID
/// 
/// Suporta cache para reduzir leituras do Firestore
class GetChatByIdUseCase {
  final IChatRepository repository;

  GetChatByIdUseCase({required this.repository});

  /// Busca um chat por ID
  /// 
  /// [chatId] - ID do chat
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(ChatEntity)] com o chat encontrado
  /// Retorna [Left(ValidationFailure)] se chatId inválido
  /// Retorna [Left(NotFoundFailure)] se chat não encontrado
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, ChatEntity>> call({
    required String chatId,
    bool forceRefresh = false,
  }) async {
    // Validar chatId
    if (chatId.isEmpty) {
      return const Left(
        ValidationFailure('ID do chat não pode ser vazio'),
      );
    }

    // Buscar chat
    return await repository.getChatById(
      chatId: chatId,
      forceRefresh: forceRefresh,
    );
  }
}
