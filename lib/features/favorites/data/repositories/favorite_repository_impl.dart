import 'package:app/core/domain/favorites/favorite_entity.dart';
import 'package:app/core/domain/favorites/favorite_ensemble_entity.dart';
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
    required FavoriteEntity favorite,
  }) async {
    try {
      // Adicionar no Firestore
      await remoteDataSource.addFavorite(
        clientId: clientId,
        favorite: favorite,
      );

      // Limpar cache para forçar atualização na próxima busca
      await localDataSource.addFavorite(favorite: favorite);

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
      await localDataSource.removeFavorite(artistId: artistId);

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getAllFavorites({
    required String clientId,
    bool forceRefresh = false,
  }) async {
    try {
      // Se não forçar refresh, tentar buscar do cache
      if (!forceRefresh) {
        final cachedFavorites = await localDataSource.getCachedFavorites();

        if (cachedFavorites != null) {
          return Right(cachedFavorites);
        }
      }

      // Buscar do Firestore
      final favorites = await remoteDataSource.getAllFavorites(
        clientId: clientId,
      );

      // Armazenar em cache
      await localDataSource.cacheFavorites(
        favorites: favorites,
      );

      return Right(favorites);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> addFavoriteEnsemble({
    required String clientId,
    required FavoriteEnsembleEntity favorite,
  }) async {
    try {
      await remoteDataSource.addFavoriteEnsemble(
        clientId: clientId,
        favorite: favorite,
      );
      await localDataSource.addFavoriteEnsemble(favorite: favorite);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavoriteEnsemble({
    required String clientId,
    required String ensembleId,
  }) async {
    try {
      await remoteDataSource.removeFavoriteEnsemble(
        clientId: clientId,
        ensembleId: ensembleId,
      );
      await localDataSource.removeFavoriteEnsemble(ensembleId: ensembleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteEnsembleEntity>>> getAllFavoriteEnsembles({
    required String clientId,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached =
            await localDataSource.getCachedFavoriteEnsembles();
        if (cached != null) return Right(cached);
      }
      final list = await remoteDataSource.getAllFavoriteEnsembles(
        clientId: clientId,
      );
      await localDataSource.cacheFavoriteEnsembles(favorites: list);
      return Right(list);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

