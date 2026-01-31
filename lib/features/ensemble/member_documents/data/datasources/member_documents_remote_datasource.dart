import 'package:app/core/domain/ensemble/member_documents/member_document_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para MemberDocuments (documentos do integrante).
///
/// Documentos ficam na subcoleção: EnsembleMembers/{artistId}/Members/{memberId}/Documents/{documentType}.
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NotFoundException, etc.)
/// - NÃO faz validações de negócio
abstract class IMemberDocumentsRemoteDataSource {
  /// Busca um documento do integrante por tipo (identity ou antecedents).
  Future<MemberDocumentEntity?> get(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  );

  /// Lista os dois documentos (identity e antecedents) do integrante, se existirem.
  Future<List<MemberDocumentEntity>> getAllByMember(
    String artistId,
    String ensembleId,
    String memberId,
  );

  /// Salva/atualiza o documento na subcoleção Documents.
  Future<void> save(String artistId, MemberDocumentEntity document);

  /// Remove o documento da subcoleção.
  Future<void> delete(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  );
}

/// Implementação: CRUD na subcoleção Documents do member.
class MemberDocumentsRemoteDataSourceImpl
    implements IMemberDocumentsRemoteDataSource {
  final FirebaseFirestore firestore;

  MemberDocumentsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<MemberDocumentEntity?> get(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) async {
    try {
      _validateIds(artistId, ensembleId, memberId);
      _validateDocumentType(documentType);
      final docRef = MemberDocumentEntityReference.firebaseMemberDocumentReference(
        firestore,
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final raw = snapshot.data()! as Map<String, dynamic>;
      final map = _fromFirestoreMap(raw);
      map[MemberDocumentEntityKeys.artistId] = artistId;
      map[MemberDocumentEntityKeys.ensembleId] = ensembleId;
      map[MemberDocumentEntityKeys.memberId] = memberId;
      map[MemberDocumentEntityKeys.documentType] = snapshot.id;
      return MemberDocumentEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar documento do integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<MemberDocumentEntity>> getAllByMember(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    final identity =
        await get(artistId, ensembleId, memberId, MemberDocumentType.identity);
    final antecedents = await get(
        artistId, ensembleId, memberId, MemberDocumentType.antecedents);
    final list = <MemberDocumentEntity>[];
    if (identity != null) list.add(identity);
    if (antecedents != null) list.add(antecedents);
    return list;
  }

  @override
  Future<void> save(String artistId, MemberDocumentEntity document) async {
    try {
      _validateIds(
        document.artistId,
        document.ensembleId,
        document.memberId,
      );
      _validateDocumentType(document.documentType);
      final docRef = MemberDocumentEntityReference.firebaseMemberDocumentReference(
        firestore,
        document.artistId,
        document.ensembleId,
        document.memberId,
        document.documentType,
      );
      final data = document.toMap()
        ..remove(MemberDocumentEntityKeys.artistId)
        ..remove(MemberDocumentEntityKeys.ensembleId)
        ..remove(MemberDocumentEntityKeys.memberId);
      await docRef.set(data, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar documento do integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> delete(
    String artistId,
    String ensembleId,
    String memberId,
    String documentType,
  ) async {
    try {
      _validateIds(artistId, ensembleId, memberId);
      _validateDocumentType(documentType);
      final docRef = MemberDocumentEntityReference.firebaseMemberDocumentReference(
        firestore,
        artistId,
        ensembleId,
        memberId,
        documentType,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;
      await docRef.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao remover documento do integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _validateIds(String artistId, String ensembleId, String memberId) {
    if (artistId.isEmpty) {
      throw const ValidationException('artistId não pode ser vazio');
    }
    if (ensembleId.isEmpty) {
      throw const ValidationException('ensembleId não pode ser vazio');
    }
    if (memberId.isEmpty) {
      throw const ValidationException('memberId não pode ser vazio');
    }
  }

  void _validateDocumentType(String documentType) {
    if (documentType != MemberDocumentType.identity &&
        documentType != MemberDocumentType.antecedents) {
      throw ValidationException(
          'documentType deve ser identity ou antecedents: $documentType');
    }
  }

  static Map<String, dynamic> _fromFirestoreMap(Map<dynamic, dynamic>? data) {
    if (data == null) return {};
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is Timestamp) {
        result[entry.key] = value.toDate();
      } else if (value is Map) {
        result[entry.key] = _fromFirestoreMap(value);
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }
}
