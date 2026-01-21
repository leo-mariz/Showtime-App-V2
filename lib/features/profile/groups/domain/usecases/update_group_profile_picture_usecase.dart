// import 'package:app/core/errors/error_handler.dart';
// import 'package:app/core/errors/failure.dart';
// import 'package:app/features/profile/artists/groups/domain/repositories/groups_repository.dart';
// import 'package:dartz/dartz.dart';

// /// UseCase: Atualizar foto de perfil do grupo
// /// 
// /// RESPONSABILIDADES:
// /// - Validar UID do grupo
// /// - Validar caminho do arquivo de imagem
// /// - Fazer upload da imagem
// /// - Atualizar URL da imagem no grupo
// /// 
// /// NOTA: Requer implementação do método updateGroupProfilePicture no IGroupsRepository
// class UpdateGroupProfilePictureUseCase {
//   final IGroupsRepository repository;

//   UpdateGroupProfilePictureUseCase({
//     required this.repository,
//   });

//   Future<Either<Failure, String>> call(
//     String groupUid,
//     String localFilePath,
//   ) async {
//     try {
//       // Validar UID do grupo
//       if (groupUid.isEmpty) {
//         return const Left(ValidationFailure('UID do grupo não pode ser vazio'));
//       }

//       // Validar caminho do arquivo
//       if (localFilePath.isEmpty) {
//         return const Left(ValidationFailure('Caminho do arquivo não pode ser vazio'));
//       }

//       // Fazer upload da imagem e atualizar grupo


//       return result.fold(
//         (failure) => Left(failure),
//         (imageUrl) => Right(imageUrl),
//       );
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }
// }

