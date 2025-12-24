import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/clients/domain/repositories/clients_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar dados do cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Buscar cliente do repositório (cache primeiro, depois remoto)
/// - Retornar dados do cliente
class GetClientUseCase {
  final IClientsRepository repository;

  GetClientUseCase({
    required this.repository,
  });

  Future<Either<Failure, ClientEntity>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      // Buscar cliente
      final result = await repository.getClient(uid);

      return result.fold(
        (failure) => Left(failure),
        (client) => Right(client),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

