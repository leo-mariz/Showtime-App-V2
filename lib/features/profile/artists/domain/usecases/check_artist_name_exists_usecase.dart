import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Verificar se nome artístico já existe no banco de dados
/// 
/// RESPONSABILIDADES:
/// - Validar nome do artista
/// - Verificar existência no banco de dados
/// - Excluir o próprio artista da verificação (se excludeUid fornecido)
class CheckArtistNameExistsUseCase {
  final IArtistsRepository repository;

  CheckArtistNameExistsUseCase({
    required this.repository,
  });

  Future<Either<Failure, bool>> call(
    String artistName, {
    String? excludeUid,
  }) async {
    try {
      // Validar nome do artista
      if (artistName.isEmpty) {
        return const Left(ValidationFailure('Nome do artista não pode ser vazio'));
      }

      // Verificar se existe no banco
      final result = await repository.artistNameExists(
        artistName,
        excludeUid: excludeUid,
      );

      return result.fold(
        (failure) => Left(failure),
        (exists) => Right(exists),
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

