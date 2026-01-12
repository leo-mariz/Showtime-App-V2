import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/contracts/domain/repositories/contract_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar lista de contratos por artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Buscar contratos do repositório (cache primeiro, depois remoto)
/// - Retornar lista de contratos
class GetContractsByArtistUseCase {
  final IContractRepository repository;

  GetContractsByArtistUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ContractEntity>>> call(String artistUid, {bool forceRefresh = false}) async {
    try {
      // Validar UID
      if (artistUid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar contratos
      final result = await repository.getContractsByArtist(artistUid, forceRefresh: forceRefresh);

      return result.fold(
        (failure) => Left(failure),
        (contracts) => Right(contracts),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

