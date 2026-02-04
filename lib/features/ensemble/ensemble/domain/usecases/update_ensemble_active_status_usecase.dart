import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Atualiza apenas o campo [isActive] do conjunto.
/// Retorna o [EnsembleEntity] atualizado em caso de sucesso.
class UpdateEnsembleActiveStatusUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;

  UpdateEnsembleActiveStatusUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    bool isActive,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }

      final getResult = await getEnsembleUseCase.call(artistId, ensembleId);
      return await getResult.fold(
        (f) => Left(f),
        (ensemble) async {
          if (ensemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }
          final updated = ensemble.copyWith(
            isActive: isActive,
            updatedAt: DateTime.now(),
          );
          final updateResult = await updateEnsembleUseCase.call(artistId, updated);
          return updateResult.fold(
            (f) => Left(f),
            (_) => Right(updated),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
