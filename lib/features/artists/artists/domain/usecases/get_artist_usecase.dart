import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artists/artists/domain/repositories/artists_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// UseCase: Buscar dados do artista
/// 
/// RESPONSABILIDADES:
/// - Validar UID do artista
/// - Buscar artista do repositório
/// - Retornar dados do artista
class GetArtistUseCase {
  final IArtistsRepository repository;

  GetArtistUseCase({
    required this.repository,
  });

  Future<Either<Failure, ArtistEntity>> call(String uid) async {
    try {
      // Validar UID
      if (uid.isEmpty) {
        return const Left(ValidationFailure('UID do artista não pode ser vazio'));
      }

      // Buscar artista
      final result = await repository.getArtist(uid);

      return result.fold(
        (failure) => Left(failure),
        (artist) => Right(artist),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [GetArtistUseCase] Exceção ao buscar artista uid=$uid: $e');
        debugPrint('🔴 [GetArtistUseCase] Tipo: ${e.runtimeType}, stackTrace: $stackTrace');
      }
      return Left(ErrorHandler.handle(e));
    }
  }
}

