import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar mídias de apresentação do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar map de talentos e caminhos de arquivos
/// - Buscar artista atual (do cache se disponível)
/// - Para cada talento:
///   - Deletar vídeo antigo do Firebase Storage (se existir)
///   - Fazer upload do novo vídeo e obter URL
/// - Atualizar apenas o campo presentationMedias no Firestore
/// - Salvar atualização
class UpdateArtistPresentationMediasUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final IStorageService storageService;

  UpdateArtistPresentationMediasUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.storageService,
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
          
          // Map para armazenar as novas URLs (talent -> downloadUrl)
          final Map<String, String> updatedMedias = Map<String, String>.from(
            currentArtist.presentationMedias ?? {},
          );

          // Processar cada talento
          for (final entry in talentLocalFilePaths.entries) {
            final talent = entry.key;
            final filePathOrUrl = entry.value;

            // Validar caminho do arquivo ou URL
            if (filePathOrUrl.isEmpty) {
              continue; // Pular se estiver vazio
            }

            // Verificar se já existe uma URL para este talento
            final existingUrl = updatedMedias[talent];
            
            // Se o valor passado for uma URL (começa com http/https)
            final isUrl = filePathOrUrl.startsWith('http://') || filePathOrUrl.startsWith('https://');
            
            if (isUrl) {
              // Se for uma URL e for igual à existente, não fazer nada
              if (existingUrl != null && existingUrl == filePathOrUrl) {
                continue; // Pular, não precisa atualizar
              }
              
              // Se for uma URL diferente, atualizar diretamente (assumindo que já está no storage)
              updatedMedias[talent] = filePathOrUrl;
              continue;
            }

            // Se chegou aqui, é um caminho local - fazer upload
            // Se já existe uma URL para este talento, deletar o vídeo antigo
            if (existingUrl != null && existingUrl.isNotEmpty) {
              // Verificar se a URL antiga é diferente (para evitar deletar o mesmo arquivo)
              // Se o arquivo local for o mesmo que já está no storage, não deletar
              // Mas como não temos como comparar arquivo local com URL, sempre deletamos o antigo
              try {
                await storageService.deleteFileFromFirebaseStorage(existingUrl);
              } catch (e) {
                // Não falhar se o vídeo antigo não existir ou houver erro ao deletar
                // Apenas continuar com o upload do novo vídeo
              }
            }

            // Obter referência específica para este talento
            final talentStorageReference = baseStorageReference.child(talent);

            // Fazer upload do novo vídeo e obter URL
            final newVideoUrl = await storageService.uploadFileToFirebaseStorage(
              talentStorageReference,
              filePathOrUrl,
            );

            // Atualizar o map com a nova URL
            updatedMedias[talent] = newVideoUrl;
          }

          // Criar nova entidade com apenas presentationMedias atualizado
          final updatedArtist = currentArtist.copyWith(
            presentationMedias: updatedMedias,
          );

          // Atualizar artista no Firestore
          final updateResult = await updateArtistUseCase(uid, updatedArtist);
          
          return updateResult;
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

