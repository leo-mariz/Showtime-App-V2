import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: buscar um conjunto por ID.
class GetEnsembleByIdUseCase {
  final IEnsembleRepository repository;

  GetEnsembleByIdUseCase({required this.repository});

  Future<Either<Failure, EnsembleEntity?>> call(
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
      return await repository.getById(
        artistId: artistId,
        ensembleId: ensembleId,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
