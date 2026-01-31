import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case: criar o documento do conjunto (vazio, sem integrantes).
/// Usado pelo CreateEnsembleUseCase antes de associar os membros.
class CreateEmptyEnsembleUseCase {
  final IEnsembleRepository repository;

  CreateEmptyEnsembleUseCase({required this.repository});

  Future<Either<Failure, EnsembleEntity>> call(String artistId) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('artistId é obrigatório'));
      }
      final ensemble = EnsembleEntity(
        ownerArtistId: artistId,
        members: null,
      );
      return await repository.create(
        artistId: artistId,
        ensemble: ensemble,
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
