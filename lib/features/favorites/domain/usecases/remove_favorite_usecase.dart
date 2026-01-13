import 'package:app/core/errors/failure.dart';
import 'package:app/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case para remover um artista dos favoritos
/// 
/// Valida os dados antes de remover e atualiza tanto o cache local
/// quanto o Firestore
class RemoveFavoriteUseCase {
  final IFavoriteRepository repository;

  RemoveFavoriteUseCase({required this.repository});

  /// Remove um artista dos favoritos do cliente
  /// 
  /// [clientId] - UID do cliente
  /// [artistId] - UID do artista a ser removido
  /// 
  /// Retorna [Right(void)] em caso de sucesso
  /// Retorna [Left(ValidationFailure)] se dados inválidos
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, void>> call({
    required String clientId,
    required String artistId,
  }) async {
    // Validar clientId
    if (clientId.isEmpty) {
      return const Left(ValidationFailure('ID do cliente não pode ser vazio'));
    }

    // Validar artistId
    if (artistId.isEmpty) {
      return const Left(ValidationFailure('ID do artista não pode ser vazio'));
    }

    // Remover dos favoritos
    return await repository.removeFavorite(
      clientId: clientId,
      artistId: artistId,
    );
  }
}

