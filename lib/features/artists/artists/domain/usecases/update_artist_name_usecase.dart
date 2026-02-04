import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/update_artist_usecase.dart';
import 'package:app/features/artists/artists/domain/usecases/check_artist_name_exists_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar nome do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar nome do artista
/// - Verificar se o nome já está em uso por outro artista
/// - Buscar artista atual (do cache se disponível)
/// - Atualizar apenas o campo artistName
/// - Salvar atualização
class UpdateArtistNameUseCase {
  final GetArtistUseCase getArtistUseCase;
  final UpdateArtistUseCase updateArtistUseCase;
  final CheckArtistNameExistsUseCase checkArtistNameExistsUseCase;

  UpdateArtistNameUseCase({
    required this.getArtistUseCase,
    required this.updateArtistUseCase,
    required this.checkArtistNameExistsUseCase,
  });

  Future<Either<Failure, void>> call(String uid, String artistName) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Validar nome do artista
      if (artistName.isEmpty) {
        return const Left(ValidationFailure('Nome do artista não pode ser vazio'));
      }

      // Verificar se o nome já está em uso por outro artista
      final checkResult = await checkArtistNameExistsUseCase(
        artistName,
        excludeUid: uid,
      );

      return await checkResult.fold(
        (failure) => Left(failure),
        (nameExists) async {
          if (nameExists) {
            return const Left(
              ValidationFailure('Este nome artístico já está em uso'),
            );
          }

          // Buscar artista atual (cache-first)
          final getResult = await getArtistUseCase(uid);
          
          return getResult.fold(
            (failure) => Left(failure),
            (currentArtist) async {
              // Criar nova entidade com apenas artistName atualizado
              final updatedArtist = currentArtist.copyWith(
                artistName: artistName,
              );

              // Atualizar artista
              return await updateArtistUseCase(uid, updatedArtist);
            },
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

