import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Repository para documentos do integrante (member documents).
///
/// Interface que define operações CRUD sobre documentos (identity/antecedents).
/// Implementação orquestra remote e local datasources (cache).
abstract class IMemberDocumentsRepository {
  /// Lista os documentos do integrante (identity e antecedents, se existirem).
  /// [forceRemote] Se true, ignora cache e busca no servidor.
  Future<Either<Failure, List<MemberDocumentEntity>>> getAllByMember({
    required String artistId,
    required String ensembleId,
    required String memberId,
    bool forceRemote = false,
  });

  /// Busca um documento por tipo (identity ou antecedents).
  Future<Either<Failure, MemberDocumentEntity?>> get({
    required String artistId,
    required String ensembleId,
    required String memberId,
    required String documentType,
  });

  /// Salva/atualiza um documento.
  Future<Either<Failure, void>> save({
    required String artistId,
    required MemberDocumentEntity document,
  });

  /// Remove um documento.
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String ensembleId,
    required String memberId,
    required String documentType,
  });

  /// Limpa o cache de documentos do integrante.
  Future<Either<Failure, void>> clearCache({
    required String artistId,
    required String ensembleId,
    required String memberId,
  });
}
