import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Repository para integrantes (members) do conjunto.
///
/// Interface que define operações CRUD.
/// Implementação orquestra remote e local datasources (cache).
abstract class IMembersRepository {
  /// Lista todos os integrantes cadastrados pelo artista (pool).
  /// [forceRemote] permite forçar atualização ignorando cache local.
  Future<Either<Failure, List<EnsembleMemberEntity>>> getAll({
    required String artistId,
    bool forceRemote = false,
  });

  /// Busca um integrante por ID.
  /// [forceRemote] quando true ignora cache (ex.: antes de deletar, para obter ensembleIds atualizados).
  Future<Either<Failure, EnsembleMemberEntity?>> getById({
    required String artistId,
    required String memberId,
    bool forceRemote = false,
  });

  /// Cria um integrante para o artista.
  Future<Either<Failure, EnsembleMemberEntity>> create({
    required String artistId,
    required EnsembleMemberEntity member,
  });

  /// Atualiza um integrante.
  Future<Either<Failure, void>> update({
    required String artistId,
    required EnsembleMemberEntity member,
  });

  /// Remove um integrante.
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String memberId,
  });

  /// Limpa o cache local dos integrantes do artista.
  Future<Either<Failure, void>> clearCache({
    required String artistId,
  });
}
