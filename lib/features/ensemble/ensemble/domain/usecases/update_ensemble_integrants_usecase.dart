import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/update_ensemble_integrants_dto.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Atualiza número de integrantes, talentos e tipo de conjunto.
/// Obtém o conjunto atual, aplica os campos de [dto] e persiste.
class UpdateEnsembleIntegrantsUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;

  UpdateEnsembleIntegrantsUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    UpdateEnsembleIntegrantsDto dto,
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
        (current) async {
          if (current == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }
          final ensembleType = dto.ensembleType?.trim().isNotEmpty == true
              ? dto.ensembleType?.trim()
              : current.ensembleType;
          final now = DateTime.now();
          final updated = current.copyWith(
            members: dto.membersCount,
            talents: dto.talents,
            ensembleType: ensembleType,
            updatedAt: now,
            lastUpdatedAt: now,
          );
          final updateResult = await updateEnsembleUseCase.call(
            artistId,
            updated,
          );
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
