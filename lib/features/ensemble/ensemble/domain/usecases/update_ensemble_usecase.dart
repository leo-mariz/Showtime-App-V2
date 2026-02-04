import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar um conjunto.
/// Após atualizar, sincroniza a completude do conjunto (hasIncompleteSections / incompleteSections).
class UpdateEnsembleUseCase {
  final IEnsembleRepository repository;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  UpdateEnsembleUseCase({
    required this.repository,
    required this.syncEnsembleCompletenessIfChangedUseCase,
  });

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
      final result = await repository.update(
        artistId: artistId,
        ensemble: ensemble,
      );
      if (result.isRight()) {
        await syncEnsembleCompletenessIfChangedUseCase.call(
          artistId,
          ensemble.id!,
        );
      }
      return result;
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
