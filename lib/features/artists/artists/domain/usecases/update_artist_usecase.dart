import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artists/domain/repositories/artists_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Atualizar artista existente
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Validar dados do artista
/// - Atualizar artista no repositório
class UpdateArtistUseCase {
  final IArtistsRepository repository;

  UpdateArtistUseCase({
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

      // Atualizar artista
      final result = await repository.updateArtist(uid, artist);

      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

