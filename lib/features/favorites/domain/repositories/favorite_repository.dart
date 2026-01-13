import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do repositório de favoritos
/// Define as operações de CRUD para gerenciamento de artistas favoritos
abstract class IFavoriteRepository {
  /// Adiciona um artista aos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [favorite] - Dados do favorito a ser adicionado
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> addFavorite({
    required String clientId,
    required FavoriteArtistEntity favorite,
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
  /// Retorna [Right(List<FavoriteArtistEntity>)] com a lista de favoritos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<FavoriteArtistEntity>>> getFavorites({
    required String clientId,
    bool forceRefresh = false,
  });

  /// Verifica se um artista está nos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(true)] se está nos favoritos
  /// Retorna [Right(false)] se não está nos favoritos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, bool>> isFavorite({
    required String clientId,
    required String artistId,
    bool forceRefresh = false,
  });
  
  /// Busca um favorito específico
  /// 
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista
  /// 
  /// Retorna [Right(FavoriteArtistEntity)] se encontrado
  /// Retorna [Left(NotFoundFailure)] se não encontrado
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, FavoriteArtistEntity>> getFavorite({
    required String clientId,
    required String artistId,
  });
}

