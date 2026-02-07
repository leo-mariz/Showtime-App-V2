import 'package:app/core/domain/favorites/favorite_entity.dart';
import 'package:app/core/domain/favorites/favorite_ensemble_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do repositório de favoritos
/// Define as operações de CRUD para artistas e conjuntos favoritos
abstract class IFavoriteRepository {
  /// Adiciona um artista aos favoritos do cliente
  Future<Either<Failure, void>> addFavorite({
    required String clientId,
    required FavoriteEntity favorite,
  });

  /// Remove um artista dos favoritos do cliente
  Future<Either<Failure, void>> removeFavorite({
    required String clientId,
    required String artistId,
  });

  /// Busca todos os favoritos (artistas) de um cliente
  Future<Either<Failure, List<FavoriteEntity>>> getAllFavorites({
    required String clientId,
    bool forceRefresh = false,
  });

  /// Adiciona um conjunto aos favoritos do cliente
  Future<Either<Failure, void>> addFavoriteEnsemble({
    required String clientId,
    required FavoriteEnsembleEntity favorite,
  });

  /// Remove um conjunto dos favoritos do cliente
  Future<Either<Failure, void>> removeFavoriteEnsemble({
    required String clientId,
    required String ensembleId,
  });

  /// Busca todos os conjuntos favoritos de um cliente
  Future<Either<Failure, List<FavoriteEnsembleEntity>>> getAllFavoriteEnsembles({
    required String clientId,
    bool forceRefresh = false,
  });
}

