import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Repository para integrantes (members) do conjunto.
///
/// Interface que define operações CRUD.
/// Implementação orquestra remote e local datasources (cache).
abstract class IMembersRepository {
  /// Lista todos os integrantes do conjunto.
  /// [artistId] ID do artista.
  /// [ensembleId] ID do conjunto.
  /// [forceRemote] Se true, ignora cache e busca no servidor.
  Future<Either<Failure, List<EnsembleMemberEntity>>> getAllByEnsemble({
    required String artistId,
    required String ensembleId,
    bool forceRemote = false,
  });

  /// Busca um integrante por ID.
  Future<Either<Failure, EnsembleMemberEntity?>> getById({
    required String artistId,
    required String ensembleId,
    required String memberId,
  });

  /// Cria um integrante.
  Future<Either<Failure, EnsembleMemberEntity>> create({
    required String artistId,
    required String ensembleId,
    required EnsembleMemberEntity member,
  });

  /// Atualiza um integrante.
  Future<Either<Failure, void>> update({
    required String artistId,
    required String ensembleId,
    required EnsembleMemberEntity member,
  });

  /// Remove um integrante.
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String ensembleId,
    required String memberId,
  });

  /// Limpa o cache de integrantes do conjunto.
  Future<Either<Failure, void>> clearCache({
    required String artistId,
    required String ensembleId,
  });
}
