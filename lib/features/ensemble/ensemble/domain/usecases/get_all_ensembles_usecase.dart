import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: listar todos os conjuntos do artista.
class GetAllEnsemblesUseCase {
  final IEnsembleRepository repository;

  GetAllEnsemblesUseCase({required this.repository});

  Future<Either<Failure, List<EnsembleEntity>>> call(
    String artistId, {
    bool forceRemote = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      return await repository.getAllByArtist(
        artistId: artistId,
        forceRemote: forceRemote,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
