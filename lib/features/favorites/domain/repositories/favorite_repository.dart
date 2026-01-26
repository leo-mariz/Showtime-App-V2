
import 'package:app/core/domain/favorites/favorite_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do repositório de favoritos
/// Define as operações de CRUD para gerenciamento de artistas favoritos
abstract class IFavoriteRepository {
  /// Adiciona um artista aos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [favorite] - Entidade do favorito a ser adicionado
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> addFavorite({
    required String clientId,
    required FavoriteEntity favorite,
  });

  /// Remove um artista dos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista a ser removido
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> removeFavorite({
    required String clientId,
    required String artistId,
  });

  /// Busca todos os favoritos de um cliente
  /// 
  /// [clientId] - UID do cliente
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(List<FavoriteEntity>)] com a lista de favoritos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<FavoriteEntity>>> getAllFavorites({
    required String clientId,
    bool forceRefresh = false,
  });
}

