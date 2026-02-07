import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para remover um conjunto dos favoritos do cliente.
class RemoveFavoriteEnsembleUseCase {
  final IFavoriteRepository repository;

  RemoveFavoriteEnsembleUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String clientId,
    required String ensembleId,
  }) async {
    if (clientId.isEmpty) {
      return const Left(ValidationFailure('ID do cliente não pode ser vazio'));
    }
    if (ensembleId.isEmpty) {
      return const Left(ValidationFailure('ID do conjunto não pode ser vazio'));
    }
    return await repository.removeFavoriteEnsemble(
      clientId: clientId,
      ensembleId: ensembleId,
    );
  }
}
