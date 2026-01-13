import 'package:app/core/domain/favorites/favorite_artist_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para buscar todos os favoritos de um cliente
/// 
/// Utiliza cache local quando disponível para melhor performance
class GetFavoritesUseCase {
  final IFavoriteRepository repository;

  GetFavoritesUseCase({required this.repository});

  /// Busca todos os favoritos de um cliente
  /// 
  /// [clientId] - UID do cliente
  /// [forceRefresh] - Se true, ignora cache e busca do servidor
  /// 
  /// Retorna [Right(List<FavoriteArtistEntity>)] com a lista de favoritos
  /// Retorna [Left(ValidationFailure)] se clientId inválido
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<FavoriteArtistEntity>>> call({
    required String clientId,
    bool forceRefresh = false,
  }) async {
    // Validar clientId
    if (clientId.isEmpty) {
      return const Left(ValidationFailure('ID do cliente não pode ser vazio'));
    }

    // Buscar favoritos
    return await repository.getFavorites(
      clientId: clientId,
      forceRefresh: forceRefresh,
    );
  }
}

