import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/clients/domain/usecases/get_client_usecase.dart';
import 'package:app/features/clients/domain/usecases/update_client_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar foto de perfil do cliente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do cliente
/// - Validar caminho local do arquivo
/// - Buscar cliente atual (do cache se disponível)
/// - Deletar imagem antiga do Firebase Storage (se existir)
/// - Fazer upload da nova imagem e obter URL
/// - Atualizar apenas o campo profileImageUrl no Firestore
/// - Salvar atualização
class UpdateClientProfilePictureUseCase {
  final GetClientUseCase getClientUseCase;
  final UpdateClientUseCase updateClientUseCase;
  final IStorageService storageService;

  UpdateClientProfilePictureUseCase({
    required this.getClientUseCase,
    required this.updateClientUseCase,
    required this.storageService,
  });

  Future<Either<Failure, void>> call(String uid, String localFilePath) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do cliente não pode ser vazio'));
      }

      // Validar caminho do arquivo
      if (localFilePath.isEmpty) {
        return const Left(ValidationFailure('Caminho do arquivo não pode ser vazio'));
      }

      // Buscar cliente atual (cache-first)
      final getResult = await getClientUseCase(uid);
      
      return await getResult.fold(
        (failure) => Left(failure),
        (currentClient) async {
          // Deletar imagem antiga se existir
          if (currentClient.profilePicture != null && 
              currentClient.profilePicture!.isNotEmpty) {
            try {
              await storageService.deleteFileFromFirebaseStorage(
                currentClient.profilePicture!,
              );
            } catch (e) {
              // Não falhar se a imagem antiga não existir ou houver erro ao deletar
              // Apenas logar o erro e continuar
            }
          }

          // Obter referência do Firebase Storage para a foto de perfil
          final storageReference = ClientEntityReference.firestorageProfilePictureReference(uid);

          // Fazer upload da nova imagem e obter URL
          final newProfilePictureUrl = await storageService.uploadFileToFirebaseStorage(
            storageReference,
            localFilePath,
          );

          // Criar nova entidade com apenas profilePicture atualizado
          final updatedClient = currentClient.copyWith(
            profilePicture: newProfilePictureUrl,
          );

          // Atualizar cliente no Firestore
          final updateResult = await updateClientUseCase(uid, updatedClient);
          
          return updateResult;
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

