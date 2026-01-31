import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Repository para conjuntos (ensembles).
///
/// Interface que define operações CRUD.
/// Implementação orquestra remote e local datasources (cache).
abstract class IEnsembleRepository {
  /// Lista todos os conjuntos do artista.
  /// [artistId] ID do artista.
  /// [forceRemote] Se true, ignora cache e busca no servidor.
  Future<Either<Failure, List<EnsembleEntity>>> getAllByArtist({
    required String artistId,
    bool forceRemote = false,
  });

  /// Busca um conjunto por ID.
  Future<Either<Failure, EnsembleEntity?>> getById({
    required String artistId,
    required String ensembleId,
  });

  /// Cria um conjunto.
  Future<Either<Failure, EnsembleEntity>> create({
    required String artistId,
    required EnsembleEntity ensemble,
  });

  /// Atualiza um conjunto.
  Future<Either<Failure, void>> update({
    required String artistId,
    required EnsembleEntity ensemble,
  });

  /// Remove um conjunto.
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String ensembleId,
  });

  /// Limpa o cache de conjuntos do artista.
  Future<Either<Failure, void>> clearCache({required String artistId});
}
