import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/get_ensemble_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use case: remover um conjunto.
///
/// Antes de deletar o documento no Firestore, remove do Firebase Storage
/// o vídeo de apresentação e a foto de perfil do conjunto (quando existirem).
class DeleteEnsembleUseCase {
  final IEnsembleRepository repository;
  final GetEnsembleUseCase getEnsembleByIdUseCase;
  final IStorageService storageService;

  DeleteEnsembleUseCase({
    required this.repository,
    required this.getEnsembleByIdUseCase,
    required this.storageService
  });

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

      final getResult = await getEnsembleByIdUseCase.call(artistId, ensembleId);
      await getResult.fold(
        (_) async {},
        (ensemble) async {
          if (ensemble == null) return;
          if (ensemble.presentationVideoUrl != null &&
              ensemble.presentationVideoUrl!.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(
                ensemble.presentationVideoUrl!,
              );
            } catch (_) {}
          }
          if (ensemble.profilePhotoUrl != null &&
              ensemble.profilePhotoUrl!.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(
                ensemble.profilePhotoUrl!,
              );
            } catch (_) {}
          }
        },
      );

      return await repository.delete(
        artistId: artistId,
        ensembleId: ensembleId,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
