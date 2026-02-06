import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: retorna os IDs dos conjuntos dos quais o artista é dono.
/// Usado pelo fluxo de contratos para incluir contratos dos conjuntos na lista do artista.
class GetEnsembleIdsByOwnerUseCase {
  final IEnsembleRepository repository;

  GetEnsembleIdsByOwnerUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call(
    String artistId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      final result = await repository.getAllByArtist(
        artistId: artistId,
        forceRemote: forceRemote,
      );
      return result.map(
        (ensembles) => ensembles
            .where((e) => e.id != null && e.id!.isNotEmpty)
            .map((e) => e.id!)
            .toList(),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
