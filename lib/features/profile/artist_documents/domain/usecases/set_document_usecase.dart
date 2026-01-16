import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/profile/artist_documents/domain/repositories/documents_repository.dart';
import 'package:app/features/authentication/domain/usecases/get_user_uid.dart';
import 'package:app/features/profile/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Salvar/atualizar documento do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar documento (documentType obrigatório)
/// - Se houver arquivo local (localFilePath), fazer upload para Firebase Storage
/// - Atualizar URL do documento com a URL do Firebase Storage
/// - Deletar arquivo antigo do Storage se estiver sendo substituído
/// - Salvar documento no repositório (Firestore)
class SetDocumentUseCase {
  final IDocumentsRepository documentsRepository;
  final IStorageService storageService;
  final GetUserUidUseCase getUserUidUseCase;
  final SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase;

  SetDocumentUseCase({
    required this.documentsRepository,
    required this.storageService,
    required this.getUserUidUseCase,
    required this.syncArtistCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, void>> call(
    DocumentsEntity document, {
    String? localFilePath,
  }) async {
    try {
      // Obter UID do usuário
      final uidResult = await getUserUidUseCase.call();
      final uid = uidResult.fold(
        (failure) => throw failure,
        (uid) => uid,
      );

      if (uid == null || uid.isEmpty) {
        return const Left(AuthFailure('UID do artista não encontrado'));
      }

      // Validar documentType
      if (document.documentType.isEmpty) {
        return const Left(ValidationFailure('Tipo de documento não pode ser vazio'));
      }

      // Se houver arquivo local, fazer upload
      String? documentUrl = document.url;
      
      if (localFilePath != null && localFilePath.isNotEmpty) {
        // Buscar documento atual para deletar arquivo antigo se existir
        final currentDocumentResult = await documentsRepository.getDocument(
          uid,
          document.documentType,
        );

        await currentDocumentResult.fold(
          (_) async {
            // Se não existe documento anterior, apenas continua
          },
          (currentDocument) async {
            // Deletar arquivo antigo se existir
            if (currentDocument?.url != null && currentDocument!.url!.isNotEmpty) {
              try {
                await storageService.deleteFileFromFirebaseStorage(
                  currentDocument.url!,
                );
              } catch (e) {
                // Não falhar se a imagem antiga não existir ou houver erro ao deletar
                // Apenas logar o erro e continuar
              }
            }
          },
        );

        // Obter referência do Firebase Storage para o documento
        final storageReference = DocumentsEntityReference.firestorageReference(
          uid,
          document.documentType,
        );

        // Fazer upload do arquivo e obter URL
        documentUrl = await storageService.uploadFileToFirebaseStorage(
          storageReference,
          localFilePath,
        );
      }

      // Criar documento com URL atualizada (se houver upload)
      final documentToSave = documentUrl != null && documentUrl.isNotEmpty
          ? document.copyWith(url: documentUrl)
          : document;

      // Salvar documento no repositório
      final result = await documentsRepository.setDocument(uid, documentToSave);

      // Sincronizar completude apenas se mudou
      await syncArtistCompletenessIfChangedUseCase.call();

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

