import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artists/domain/entities/artist_completeness_entity.dart';
import 'package:app/features/artists/artists/domain/repositories/artists_repository.dart';
import 'package:app/features/artists/artists/domain/usecases/get_artist_usecase.dart';
import 'package:dartz/dartz.dart';

/// Atualiza [ArtistEntity.incompleteSections] com base em [ArtistCompletenessEntity].
///
/// Formato igual ao do ensemble: chaves flat por tipo (ex: "documents", "bankAccount",
/// "profilePicture", "professionalInfo", "presentations") para o card de completude
/// exibir Aprovação e Visibilidade.
class UpdateArtistIncompleteSectionsUseCase {
  final GetArtistUseCase getArtistUseCase;
  final IArtistsRepository repository;

  UpdateArtistIncompleteSectionsUseCase({
    required this.getArtistUseCase,
    required this.repository,
  });

  Future<Either<Failure, void>> call(
    String uid,
    ArtistCompletenessEntity completeness,
  ) async {
    try {
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      final getResult = await getArtistUseCase.call(uid);

      return await getResult.fold(
        (failure) => Left(failure),
        (currentArtist) async {
          final incompleteSections = <String, List<String>>{};
          for (final status in completeness.incompleteStatuses) {
            final key = status.type.name;
            incompleteSections[key] = [key];
          }

          final hasIncomplete = incompleteSections.isNotEmpty;
          final updatedArtist = currentArtist.copyWith(
            hasIncompleteSections: hasIncomplete,
            incompleteSections: incompleteSections.isEmpty ? null : incompleteSections,
            isActive: hasIncomplete ? false : true,
          );

          return repository.updateArtist(uid, updatedArtist);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
