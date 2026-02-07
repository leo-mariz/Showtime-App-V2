import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para buscar todos os conjuntos favoritos do usuário.
/// Obtém IDs dos favoritos, depois dados dos conjuntos e do dono no explore.
class GetFavoriteEnsemblesUseCase {
  final IFavoriteRepository favoriteRepository;
  final IExploreRepository exploreRepository;

  GetFavoriteEnsemblesUseCase({
    required this.favoriteRepository,
    required this.exploreRepository,
  });

  Future<Either<Failure, List<EnsembleWithAvailabilitiesEntity>>> call(
    String? clientId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (clientId == null || clientId.isEmpty) {
        return const Left(ValidationFailure('Usuário não autenticado'));
      }

      final favoritesResult = await favoriteRepository.getAllFavoriteEnsembles(
        clientId: clientId,
        forceRefresh: forceRefresh,
      );

      return await favoritesResult.fold(
        (failure) async => Left(failure),
        (favorites) async {
          if (favorites.isEmpty) return const Right([]);

          final favoriteIds = favorites
              .map((f) => f.ensembleId)
              .where((id) => id.isNotEmpty)
              .toSet();

          final ensemblesResult =
              await exploreRepository.getEnsemblesForExplore(
            forceRefresh: false,
          );

          return await ensemblesResult.fold(
            (failure) => Left(failure),
            (ensembles) async {
              final filtered = ensembles
                  .where((e) => e.id != null && favoriteIds.contains(e.id))
                  .toList();

              final result = <EnsembleWithAvailabilitiesEntity>[];
              for (final ensemble in filtered) {
                ArtistEntity? owner;
                final ownerResult = await exploreRepository.getArtistForExplore(
                  ensemble.ownerArtistId,
                  forceRefresh: false,
                );
                ownerResult.fold((_) {}, (a) => owner = a);
                result.add(EnsembleWithAvailabilitiesEntity(
                  ensemble: ensemble,
                  availabilities: [],
                  ownerArtist: owner,
                ));
              }
              return Right(result);
            },
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
