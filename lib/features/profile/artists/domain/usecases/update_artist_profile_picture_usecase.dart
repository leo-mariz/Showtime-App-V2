import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/profile/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/profile/artists/domain/usecases/update_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar foto de perfil do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar caminho local do arquivo
/// - Buscar artista atual (do cache se disponível)
/// - Deletar imagem antiga do Firebase Storage (se existir)
/// - Fazer upload da nova imagem e obter URL
/// - Atualizar apenas o campo profilePicture no Firestore
/// - Salvar atualização
class UpdateArtistProfilePictureUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final IStorageService storageService;

  UpdateArtistProfilePictureUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.storageService,
  });

  Future<Either<Failure, void>> call(String uid, String localFilePath) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Validar caminho do arquivo
      if (localFilePath.isEmpty) {
        return const Left(ValidationFailure('Caminho do arquivo não pode ser vazio'));
      }

      // Buscar artista atual (cache-first)
      final getResult = await getArtistUseCase(uid);
      
      return await getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          // Deletar imagem antiga se existir
          if (currentArtist.profilePicture != null && 
              currentArtist.profilePicture!.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(
                currentArtist.profilePicture!,
              );
            } catch (e) {
              // Não falhar se a imagem antiga não existir ou houver erro ao deletar
              // Apenas logar o erro e continuar
            }
          }

          // Obter referência do Firebase Storage para a foto de perfil
          final storageReference = ArtistEntityReference.firestorageProfilePictureReference(uid);

          // Fazer upload da nova imagem e obter URL
          final newProfilePictureUrl = await storageService.uploadFileToFirebaseStorage(
            storageReference,
            localFilePath,
          );

          // Criar nova entidade com apenas profilePicture atualizado
          final updatedArtist = currentArtist.copyWith(
            profilePicture: newProfilePictureUrl,
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

