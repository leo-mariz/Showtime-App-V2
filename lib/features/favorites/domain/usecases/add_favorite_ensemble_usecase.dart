import 'package:app/core/domain/favorites/favorite_ensemble_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para adicionar um conjunto aos favoritos do cliente.
class AddFavoriteEnsembleUseCase {
  final IFavoriteRepository repository;

  AddFavoriteEnsembleUseCase({required this.repository});

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
    final favorite = FavoriteEnsembleEntity(ensembleId: ensembleId);
    return await repository.addFavoriteEnsemble(
      clientId: clientId,
      favorite: favorite,
    );
  }
}
