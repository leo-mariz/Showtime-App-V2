import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Validar dados do cliente
/// - Adicionar cliente no repositório
class AddClientUseCase {
  final IClientsRepository repository;

  AddClientUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      final client = ClientEntity.defaultClientEntity();

      // Validar se dateRegistered está presente (obrigatório)
      if (client.dateRegistered == null) {
        return const Left(ValidationFailure('Data de registro não pode ser vazia'));
      }

      // Adicionar cliente
      final result = await repository.addClient(uid, client);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

