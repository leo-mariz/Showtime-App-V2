import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para verificar se um artista está nos favoritos
/// 
/// Utiliza getAllFavorites e verifica se o artista está na lista.
/// Aproveita o cache de getAllFavorites para melhor performance.
class IsArtistFavoriteUseCase {
  final IFavoriteRepository repository;

  IsArtistFavoriteUseCase({required this.repository});

  /// Verifica se um artista está nos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(true)] se está nos favoritos
  /// Retorna [Right(false)] se não está nos favoritos
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, bool>> call({
    required String clientId,
    required String artistId,
    bool forceRefresh = false,
  }) async {
    // Validar clientId
    if (clientId.isEmpty) {
      return const Left(ValidationFailure('Usuário não autenticado'));
    }

    // Validar artistId
    if (artistId.isEmpty) {
      return const Left(ValidationFailure('ID do artista não pode ser vazio'));
    }

    // Buscar todos os favoritos
    final favoritesResult = await repository.getAllFavorites(
      clientId: clientId,
      forceRefresh: forceRefresh,
    );

    // Verificar se o artista está na lista
    return favoritesResult.fold(
      (failure) => Left(failure),
      (favorites) {
        final isFavorite = favorites.any(
          (favorite) => favorite.artistId == artistId,
        );
        return Right(isFavorite);
      },
    );
  }
}

