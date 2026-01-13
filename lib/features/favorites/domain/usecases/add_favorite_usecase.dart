import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para adicionar um artista aos favoritos
/// 
/// Valida os dados antes de adicionar e atualiza tanto o cache local
/// quanto o Firestore
class AddFavoriteUseCase {
  final IFavoriteRepository repository;

  AddFavoriteUseCase({required this.repository});

  /// Adiciona um artista aos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [favorite] - Dados do favorito a ser adicionado
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call({
    required String clientId,
    required FavoriteArtistEntity favorite,
  }) async {
    // Validar clientId
    if (clientId.isEmpty) {
      return const Left(ValidationFailure('ID do cliente não pode ser vazio'));
    }

    // Validar artistId
    if (favorite.artistId.isEmpty) {
      return const Left(ValidationFailure('ID do artista não pode ser vazio'));
    }

    // Adicionar aos favoritos
    return await repository.addFavorite(
      clientId: clientId,
      favorite: favorite,
    );
  }
}

