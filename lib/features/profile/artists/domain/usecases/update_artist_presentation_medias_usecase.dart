import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar mídias de apresentação do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar map de talentos e caminhos de arquivos
/// - Buscar artista atual (do cache se disponível)
/// - Remover de presentationMedias (e deletar do Storage) talentos que não estão mais em professionalInfo.specialty (deletes em paralelo)
/// - Para cada talento a salvar: atualizar map com URLs; uploads de arquivos locais feitos em paralelo (delete do antigo + upload do novo por talento)
/// - Atualizar apenas o campo presentationMedias no Firestore
/// - Salvar atualização
class UpdateArtistPresentationMediasUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final IStorageService storageService;
  final SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase;

  UpdateArtistPresentationMediasUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.storageService,
    required this.syncArtistCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, void>> call(
    String uid,

    Map<String, String> talentLocalFilePaths, // Map<talent, localFilePath>
  ) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Validar map de arquivos
      if (talentLocalFilePaths.isEmpty) {
        return const Left(ValidationFailure('Map de arquivos não pode ser vazio'));
      }

      // Buscar artista atual (cache-first)
      final getResult = await getArtistUseCase(uid);
      
      return await getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Obter referência base do Firebase Storage para mídias de apresentação
          final baseStorageReference = ArtistEntityReference.firestoragePresentationMediasReference(uid);
          
          // Lista atual de talentos (professionalInfo.specialty)
          final currentTalents = currentArtist.professionalInfo?.specialty ?? [];
          final currentTalentsSet = currentTalents.toSet();

          // Map para armazenar as novas URLs (talent -> downloadUrl)
          final Map<String, String> updatedMedias = Map<String, String>.from(
            currentArtist.presentationMedias ?? {},
          );

          // Fase 1: Remover talentos que não estão mais na lista — deletes em paralelo
          final keysToRemove = List<String>.from(updatedMedias.keys)
              .where((key) => !currentTalentsSet.contains(key))
              .toList();
          final urlsToDelete = <String>[];
          for (final key in keysToRemove) {
            final url = updatedMedias[key];
            if (url != null && url.isNotEmpty) urlsToDelete.add(url);
            updatedMedias.remove(key);
          }
          if (urlsToDelete.isNotEmpty) {
            await Future.wait(
              urlsToDelete.map(
                (url) => storageService
                    .deleteFileFromFirebaseStorage(url)
                    .catchError((_) {}),
              ),
            );
          }

          // Fase 2: Atualizar map com URLs que já existem (síncrono)
          for (final entry in talentLocalFilePaths.entries) {
            final talent = entry.key;
            final filePathOrUrl = entry.value;
            if (filePathOrUrl.isEmpty) continue;

            final existingUrl = updatedMedias[talent];
            final isUrl = filePathOrUrl.startsWith('http://') || filePathOrUrl.startsWith('https://');

            if (isUrl) {
              if (existingUrl != null && existingUrl == filePathOrUrl) continue;
              updatedMedias[talent] = filePathOrUrl;
            }
          }

          // Fase 3: Uploads de arquivos locais — todos em paralelo
          final uploadFutures = <Future<void>>[];
          for (final entry in talentLocalFilePaths.entries) {
            final talent = entry.key;
            final filePathOrUrl = entry.value;
            if (filePathOrUrl.isEmpty) continue;

            final isUrl = filePathOrUrl.startsWith('http://') || filePathOrUrl.startsWith('https://');
            if (isUrl) continue;

            final existingUrl = updatedMedias[talent];
            final talentStorageReference = baseStorageReference.child(talent);

            final future = () async {
              if (existingUrl != null && existingUrl.isNotEmpty) {
                try {
                  await storageService.deleteFileFromFirebaseStorage(existingUrl);
                } catch (_) {}
              }
              final newVideoUrl = await storageService.uploadFileToFirebaseStorage(
                talentStorageReference,
                filePathOrUrl,
              );
              updatedMedias[talent] = newVideoUrl;
            }();
            uploadFutures.add(future);
          }
          if (uploadFutures.isNotEmpty) {
            await Future.wait(uploadFutures);
          }

          // Criar nova entidade com apenas presentationMedias atualizado
          final updatedArtist = currentArtist.copyWith(
            presentationMedias: updatedMedias,
          );

          // Atualizar artista no Firestore
          final updateResult = await updateArtistUseCase(uid, updatedArtist);

          // Sincronizar completude apenas se mudou
          await syncArtistCompletenessIfChangedUseCase.call();
          
          return updateResult;
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

