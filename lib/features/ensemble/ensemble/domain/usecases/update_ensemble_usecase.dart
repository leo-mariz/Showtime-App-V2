import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar um conjunto.
class UpdateEnsembleUseCase {
  final IEnsembleRepository repository;

  UpdateEnsembleUseCase({required this.repository});

  Future<Either<Failure, void>> call(
    String artistId,
    EnsembleEntity ensemble,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensemble.id == null || ensemble.id!.isEmpty) {
        return const Left(ValidationFailure('ensemble.id é obrigatório'));
      }
      return await repository.update(
        artistId: artistId,
        ensemble: ensemble,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
