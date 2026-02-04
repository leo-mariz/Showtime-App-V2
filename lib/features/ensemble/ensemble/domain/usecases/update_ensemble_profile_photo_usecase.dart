import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar foto de perfil do conjunto.
///
/// Faz upload da nova imagem para o Firebase Storage, remove a antiga (se existir)
/// e atualiza o conjunto no Firestore.
class UpdateEnsembleProfilePhotoUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final IStorageService storageService;

  UpdateEnsembleProfilePhotoUseCase({
    required this.getEnsembleUseCase,
    required this.updateEnsembleUseCase,
    required this.storageService,
  });

  Future<Either<Failure, EnsembleEntity>> call(
    String artistId,
    String ensembleId,
    String localFilePath,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ensembleId é obrigatório'));
      }
      if (localFilePath.isEmpty) {
        return const Left(ValidationFailure('Caminho do arquivo não pode ser vazio'));
      }

      final getResult = await getEnsembleUseCase.call(artistId, ensembleId);

      return await getResult.fold(
        (failure) => Left(failure),
        (currentEnsemble) async {
          if (currentEnsemble == null) {
            return const Left(NotFoundFailure('Ensemble não encontrado'));
          }
          if (currentEnsemble.profilePhotoUrl != null &&
              currentEnsemble.profilePhotoUrl!.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(
                currentEnsemble.profilePhotoUrl!,
              );
            } catch (_) {}
          }

          final ref = EnsembleEntityReference.firestorageProfilePictureReference(ensembleId);
          final newUrl = await storageService.uploadFileToFirebaseStorage(ref, localFilePath);

          final updated = currentEnsemble.copyWith(
            profilePhotoUrl: newUrl,
            updatedAt: DateTime.now(),
          );

          final updateResult = await updateEnsembleUseCase.call(artistId, updated);
          return await updateResult.fold(
            (failure) => Future.value(Left(failure)),
            (_) async {
              // Sync já rodou no UpdateEnsembleUseCase; re-buscar do cache para ter hasIncompleteSections/incompleteSections atualizados.
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
