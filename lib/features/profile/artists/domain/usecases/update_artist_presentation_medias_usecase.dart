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
/// - Buscar artista atual (do cache se disponível)
/// - Fase 1: Remover (e deletar do Storage) talentos que não estão mais em professionalInfo.specialty
/// - Fase 1b: Remover (e deletar do Storage) vídeos que o artista deletou na UI (talento em specialty mas não em talentLocalFilePaths ou valor vazio)
/// - Para cada talento a salvar: atualizar map com URLs; uploads de arquivos locais em paralelo (delete do antigo + upload do novo por talento)
/// - Atualizar apenas o campo presentationMedias no Firestore
/// - Salvar atualização
/// 
/// Permite talentLocalFilePaths vazio (artista removeu todos os vídeos).
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
    {void Function(int completed, int total)? onProgress,
  }) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Permite map vazio: usuário pode ter removido todos os vídeos

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

          // Fase 1: Remover talentos que não estão mais em specialty — deletes em paralelo
          final keysNotInSpecialty = List<String>.from(updatedMedias.keys)
              .where((key) => !currentTalentsSet.contains(key))
              .toList();
          final urlsToDeletePhase1 = <String>[];
          for (final key in keysNotInSpecialty) {
            final url = updatedMedias[key];
            if (url != null && url.isNotEmpty) urlsToDeletePhase1.add(url);
            updatedMedias.remove(key);
          }
          if (urlsToDeletePhase1.isNotEmpty) {
            await Future.wait(
              urlsToDeletePhase1.map(
                (url) => storageService
                    .deleteFileFromFirebaseStorage(url)
                    .catchError((_) {}),
              ),
            );
          }

          // Fase 1b: Remover vídeos que o usuário deletou na UI (talento em specialty mas não em talentLocalFilePaths)
          final talentsToRemoveFromUi = currentTalentsSet
              .where((talent) {
                final value = talentLocalFilePaths[talent];
                return value == null || value.isEmpty;
              })
              .toList();
          final urlsToDeletePhase1b = <String>[];
          for (final talent in talentsToRemoveFromUi) {
            final url = updatedMedias[talent];
            if (url != null && url.isNotEmpty) urlsToDeletePhase1b.add(url);
            updatedMedias.remove(talent);
          }
          if (urlsToDeletePhase1b.isNotEmpty) {
            await Future.wait(
              urlsToDeletePhase1b.map(
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

          // Fase 3: Uploads de arquivos locais — todos em paralelo, reportando progresso
          final totalUploads = talentLocalFilePaths.entries
              .where((e) =>
                  e.value.isNotEmpty &&
                  !e.value.startsWith('http://') &&
                  !e.value.startsWith('https://'))
              .length;
          final completedCount = [0]; // lista para mutação dentro dos closures

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
              completedCount[0]++;
              onProgress?.call(completedCount[0], totalUploads);
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

