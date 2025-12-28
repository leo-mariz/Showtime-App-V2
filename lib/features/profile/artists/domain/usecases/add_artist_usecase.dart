import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Adicionar novo artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar dados do artista
/// - Adicionar artista no repositório
class AddArtistUseCase {
  final IArtistsRepository repository;

  AddArtistUseCase({
    required this.repository,
  });

  Future<Either<Failure, void>> call(String uid, ArtistEntity artist) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Validar se dateRegistered está presente (obrigatório)
      if (artist.dateRegistered == null) {
        return const Left(ValidationFailure('Data de registro não pode ser vazia'));
      }

      // Adicionar artista
      final result = await repository.addArtist(uid, artist);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

