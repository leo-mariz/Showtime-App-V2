import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/ensemble/ensemble/domain/usecases/sync_ensemble_completeness_if_changed_usecase.dart';
import 'package:app/features/ensemble/member_documents/domain/repositories/member_documents_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: salvar/atualizar um documento do integrante.
/// Se [localFilePath] for informado, faz upload para o Storage e atualiza a URL do documento.
class SaveMemberDocumentUseCase {
  final IMemberDocumentsRepository repository;
  final IStorageService storageService;
  final SyncEnsembleCompletenessIfChangedUseCase syncEnsembleCompletenessIfChangedUseCase;

  SaveMemberDocumentUseCase({
    required this.repository,
    required this.storageService,
    required this.syncEnsembleCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, void>> call(
    String artistId,
    MemberDocumentEntity document, {
    String? localFilePath,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      if (document.documentType != MemberDocumentType.identity &&
          document.documentType != MemberDocumentType.antecedents) {
        return const Left(
          ValidationFailure('documentType deve ser identity ou antecedents'),
        );
      }

      String? documentUrl = document.url;

      if (localFilePath != null && localFilePath.isNotEmpty) {
        final currentResult = await repository.get(
          artistId: artistId,
          ensembleId: document.ensembleId,
          memberId: document.memberId,
          documentType: document.documentType,
        );
        await currentResult.fold(
          (_) async {},
          (currentDocument) async {
            if (currentDocument?.url != null &&
                currentDocument!.url!.isNotEmpty) {
              try {
                await storageService.deleteFileFromFirebaseStorage(
                  currentDocument.url!,
                );
              } catch (_) {}
            }
          },
        );

        final ref = MemberDocumentEntityReference.firestorageMemberDocumentReference(
          artistId,
          document.ensembleId,
          document.memberId,
          document.documentType,
        );
        documentUrl = await storageService.uploadFileToFirebaseStorage(
          ref,
          localFilePath,
        );
      }

      final documentToSave = documentUrl != null && documentUrl.isNotEmpty
          ? document.copyWith(url: documentUrl)
          : document;

      final saveResult = await repository.save(
        artistId: artistId,
        document: documentToSave,
      );

      return await saveResult.fold(
        (failure) => Future.value(Left(failure)),
        (_) async {
          await syncEnsembleCompletenessIfChangedUseCase.call(artistId, document.ensembleId);
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
