import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/update_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: atualizar vídeo de apresentação do conjunto.
///
/// Faz upload do novo vídeo para o Firebase Storage, remove o antigo (se existir)
/// e atualiza o conjunto no Firestore com presentationVideoUrl.
/// Se [localFilePath] for vazio, remove o vídeo (deleta do Storage e zera a URL).
/// A sincronização da completude é feita dentro de [UpdateEnsembleUseCase].
class UpdateEnsemblePresentationVideoUseCase {
  final GetEnsembleUseCase getEnsembleUseCase;
  final UpdateEnsembleUseCase updateEnsembleUseCase;
  final IStorageService storageService;

  UpdateEnsemblePresentationVideoUseCase({
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

      final getResult = await getEnsembleUseCase.call(artistId, ensembleId);

      return await getResult.fold(
        (failure) => Left(failure),
        (currentEnsemble) async {
          if (currentEnsemble == null) {
            return const Left(NotFoundFailure('Conjunto não encontrado'));
          }

          final oldUrl = currentEnsemble.presentationVideoUrl;
          if (oldUrl != null && oldUrl.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(oldUrl);
            } catch (_) {}
          }

          String? newUrl;
          if (localFilePath.isNotEmpty) {
            final ref = EnsembleEntityReference
                .firestoragePresentationVideoReference(ensembleId);
            newUrl = await storageService.uploadFileToFirebaseStorage(
              ref,
              localFilePath,
            );
          }

          final updated = currentEnsemble.copyWith(
            presentationVideoUrl: newUrl,
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
