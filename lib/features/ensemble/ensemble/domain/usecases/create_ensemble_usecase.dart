import 'package:app/core/domain/artist/professional_info_entity/professional_info_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/entities/create_ensemble_dto.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar um conjunto com os dados do DTO.
///
/// 1. Cria o conjunto via repositório com [ensembleName], [membersCount], [ensembleType], [talents], [bio].
/// 2. Sincroniza as informações incompletas (talents, professionalInfo, ensembleName, profilePhoto).
class CreateEnsembleUseCase {
  final IEnsembleRepository repository;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  CreateEnsembleUseCase({
    required this.repository,
    required this.syncEnsembleCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    CreateEnsembleDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }

      final count = dto.membersCount < 2 ? 2 : (dto.membersCount > 20 ? 20 : dto.membersCount);
      final professionalInfo = (dto.bio != null && dto.bio!.trim().isNotEmpty)
          ? ProfessionalInfoEntity(bio: dto.bio!.trim())
          : null;

      final entity = EnsembleEntity(
        ownerArtistId: artistId,
        ensembleName: dto.ensembleName?.trim(),
        members: count,
        ensembleType: dto.ensembleType?.trim().isNotEmpty == true ? dto.ensembleType?.trim() : null,
        talents: dto.talents,
        professionalInfo: professionalInfo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );

      final createdResult = await repository.create(
        artistId: artistId,
        ensemble: entity,
      );

      return await createdResult.fold(
        (f) => Left(f),
        (created) async {
          final ensembleId = created.id ?? '';
          if (ensembleId.isNotEmpty) {
            await syncEnsembleCompletenessIfChangedUseCase.call(artistId, ensembleId);
          }
          return Right(created);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
