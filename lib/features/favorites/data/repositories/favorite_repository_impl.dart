import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/data/datasources/favorite_local_datasource.dart';
import 'package:app/features/favorites/data/datasources/favorite_remote_datasource.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de favoritos
/// 
/// Coordena operações entre datasource remoto (Firestore) e local (cache)
class FavoriteRepositoryImpl implements IFavoriteRepository {
  final IFavoriteRemoteDataSource remoteDataSource;
  final IFavoriteLocalDataSource localDataSource;

  FavoriteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> addFavorite({
    required String clientId,
    required FavoriteArtistEntity favorite,
  }) async {
    try {
      // Adicionar no Firestore
      await remoteDataSource.addFavorite(
        clientId: clientId,
        favorite: favorite,
      );

      // Limpar cache para forçar atualização na próxima busca
      await localDataSource.clearCache(clientId: clientId);
      
      // Atualizar cache de verificação
      await localDataSource.cacheIsFavorite(
        clientId: clientId,
        artistId: favorite.artistId,
        isFavorite: true,
      );

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String clientId,
    required String artistId,
  }) async {
    try {
      // Remover do Firestore
      await remoteDataSource.removeFavorite(
        clientId: clientId,
        artistId: artistId,
      );

      // Limpar cache para forçar atualização na próxima busca
      await localDataSource.clearCache(clientId: clientId);
      
      // Atualizar cache de verificação
      await localDataSource.cacheIsFavorite(
        clientId: clientId,
        artistId: artistId,
        isFavorite: false,
      );

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteArtistEntity>>> getFavorites({
    required String clientId,
    bool forceRefresh = false,
  }) async {
    try {
      // Se não forçar refresh, tentar buscar do cache
      if (!forceRefresh) {
        final cachedFavorites = await localDataSource.getCachedFavorites(
          clientId: clientId,
        );

        if (cachedFavorites != null) {
          return Right(cachedFavorites);
        }
      }

      // Buscar do Firestore
      final favorites = await remoteDataSource.getFavorites(
        clientId: clientId,
      );

      // Armazenar em cache
      await localDataSource.cacheFavorites(
        clientId: clientId,
        favorites: favorites,
      );

      return Right(favorites);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String clientId,
    required String artistId,
    bool forceRefresh = false,
  }) async {
    try {
      // Se não forçar refresh, tentar buscar do cache
      if (!forceRefresh) {
        final cachedIsFavorite = await localDataSource.getCachedIsFavorite(
          clientId: clientId,
          artistId: artistId,
        );

        if (cachedIsFavorite != null) {
          return Right(cachedIsFavorite);
        }
      }

      // Verificar no Firestore
      final isFav = await remoteDataSource.isFavorite(
        clientId: clientId,
        artistId: artistId,
      );

      // Armazenar em cache
      await localDataSource.cacheIsFavorite(
        clientId: clientId,
        artistId: artistId,
        isFavorite: isFav,
      );

      return Right(isFav);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, FavoriteArtistEntity>> getFavorite({
    required String clientId,
    required String artistId,
  }) async {
    try {
      // Buscar do Firestore
      final favorite = await remoteDataSource.getFavorite(
        clientId: clientId,
        artistId: artistId,
      );

      if (favorite == null) {
        return const Left(NotFoundFailure('Favorito não encontrado'));
      }

      return Right(favorite);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

