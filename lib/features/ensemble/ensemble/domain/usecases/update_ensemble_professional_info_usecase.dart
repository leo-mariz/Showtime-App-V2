import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar as informações profissionais do conjunto.
/// A sincronização da completude é feita dentro de [UpdateEnsembleUseCase].
class UpdateEnsembleProfessionalInfoUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;

  UpdateEnsembleProfessionalInfoUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    ProfessionalInfoEntity professionalInfo,
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
        (failure) => Left(failure),
        (ensemble) async {
          if (ensemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }
          final updated = ensemble.copyWith(
            professionalInfo: professionalInfo,
            updatedAt: DateTime.now(),
          );
          final updateResult = await updateEnsembleUseCase.call(artistId, updated);
          return await updateResult.fold(
            (failure) => Future.value(Left(failure)),
            (_) async {
              // Sync rodou no update; re-buscar do cache para ter hasIncompleteSections/incompleteSections atualizados.
              final getResult = await getEnsembleUseCase.call(artistId, ensembleId);
              return getResult.fold(
                (f) => Right(updated),
                (refetched) => Right(refetched ?? updated),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
