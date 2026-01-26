import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para buscar todos os artistas favoritos do usuário
/// 
/// OTIMIZADO: Busca IDs de favoritos primeiro, depois os dados dos artistas
/// Reutiliza o repositório do Explore como fonte única de dados em cache
class GetFavoriteArtistsUseCase {
  final IFavoriteRepository favoriteRepository;
  final IExploreRepository exploreRepository;

  GetFavoriteArtistsUseCase({
    required this.favoriteRepository,
    required this.exploreRepository,
  });

  /// Busca todos os artistas favoritos do usuário
  /// 
  /// 1. Obtém o UID do usuário
  /// 2. Busca lista de favoritos do repositório
  /// 3. Se não há favoritos, retorna lista vazia (RÁPIDO!)
  /// 4. Se há favoritos, busca dados completos dos artistas do explore
  /// 5. Filtra e retorna apenas os artistas favoritos
  Future<Either<Failure, List<ArtistEntity>>> call(
    String? clientId,
    {bool forceRefresh = false}
  ) async {
    try {

      if (clientId == null || clientId.isEmpty) {
        return const Left(
          ValidationFailure('Usuário não autenticado'),
        );
      }
  
      final favoritesResult = await favoriteRepository.getAllFavorites(
        clientId: clientId,
        forceRefresh: forceRefresh,
      );

      return await favoritesResult.fold(
        (failure) async {
          return Left(failure);
        },
        (favorites) async {
          
          // Se não há favoritos, retornar lista vazia imediatamente
          if (favorites.isEmpty) {
            return const Right([]);
          }

          final artistsResult = await exploreRepository.getArtistsForExplore(
            forceRefresh: false,
          );

          return artistsResult.fold(
            (failure) {
              return Left(failure);
            },
            (artists) {
              // 4. Filtrar apenas os favoritos
              final favoriteIds = favorites
                  .map((f) => f.artistId)
                  .where((id) => id.isNotEmpty)
                  .cast<String>()
                  .toSet();
              
              final favoriteArtists = artists
                  .where((artist) => favoriteIds.contains(artist.uid))
                  .toList();
              
              return Right(favoriteArtists);
            },
          );        
      });
    } catch (e) {
      return Left(
        ErrorHandler.handle(e),
      );
    }
  }
}
