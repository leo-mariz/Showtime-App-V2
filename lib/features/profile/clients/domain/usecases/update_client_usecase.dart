import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar cliente existente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Validar dados do cliente
/// - Atualizar cliente no repositório
class UpdateClientUseCase {
  final IClientsRepository repository;

  UpdateClientUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid, ClientEntity client) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      // Validar se dateRegistered está presente (obrigatório)
      if (client.dateRegistered == null) {
        return const Left(ValidationFailure('Data de registro não pode ser vazia'));
      }

      // Atualizar cliente
      final result = await repository.updateClient(uid, client);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

