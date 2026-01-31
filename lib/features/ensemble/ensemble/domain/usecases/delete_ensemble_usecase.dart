import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: remover um conjunto.
class DeleteEnsembleUseCase {
  final IEnsembleRepository repository;

  DeleteEnsembleUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    String ensembleId,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      return await repository.delete(
        artistId: artistId,
        ensembleId: ensembleId,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
