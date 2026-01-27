import 'package:app/core/errors/failure.dart';
import 'package:app/features/chat/domain/dtos/create_chat_input_dto.dart';
import 'package:app/features/chat/domain/entities/chat_entity.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para criar um novo chat entre cliente e artista
/// 
/// Recebe DTO da camada de apresentação, valida os dados e chama o repository
/// Valida antes de criar e inicializa o chat com:
/// - Documento do chat no Firestore
/// - Índices para cliente e artista
/// - Mensagem de sistema inicial
class CreateChatUseCase {
  final IChatRepository repository;

  CreateChatUseCase({required this.repository});

  /// Cria um novo chat vinculado a um contrato
  /// 
  /// [input] - DTO com todos os dados necessários para criar o chat
  /// 
  /// Retorna [Right(ChatEntity)] com o chat criado
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, ChatEntity>> call(
    CreateChatInputDto input,
  ) async {
    // Validar contractId
    if (input.contractId.isEmpty) {
      return const Left(
        ValidationFailure('ID do contrato não pode ser vazio'),
      );
    }

    // Validar clientId
    if (input.clientId.isEmpty) {
      return const Left(
        ValidationFailure('ID do cliente não pode ser vazio'),
      );
    }

    // Validar artistId
    if (input.artistId.isEmpty) {
      return const Left(
        ValidationFailure('ID do artista não pode ser vazio'),
      );
    }

    // Validar que cliente e artista são diferentes
    if (input.clientId == input.artistId) {
      return const Left(
        ValidationFailure('Cliente e artista devem ser diferentes'),
      );
    }

    // Validar nomes
    if (input.clientName.trim().isEmpty) {
      return const Left(
        ValidationFailure('Nome do cliente não pode ser vazio'),
      );
    }

    if (input.artistName.trim().isEmpty) {
      return const Left(
        ValidationFailure('Nome do artista não pode ser vazio'),
      );
    }

    // Chamar repository com parâmetros individuais
    return await repository.createChat(
      contractId: input.contractId,
      clientId: input.clientId,
      artistId: input.artistId,
      clientName: input.clientName,
      artistName: input.artistName,
      clientPhoto: input.clientPhoto,
      artistPhoto: input.artistPhoto,
    );
  }
}
