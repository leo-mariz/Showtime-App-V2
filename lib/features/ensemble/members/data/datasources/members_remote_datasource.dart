import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para Members (integrantes).
///
/// Operações CRUD no Firestore. Caminho: EnsembleMembers/{artistId}/Members/{memberId}.
/// Listar por conjunto: query onde ensembleId == ensembleId.
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NotFoundException, etc.)
/// - NÃO faz validações de negócio
abstract class IMembersRemoteDataSource {
  /// Cria um integrante. Retorna a entidade com id.
  Future<EnsembleMemberEntity> create(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  );

  /// Busca um integrante por ID.
  Future<EnsembleMemberEntity?> getById(
    String artistId,
    String ensembleId,
    String memberId,
  );

  /// Lista todos os integrantes do conjunto.
  Future<List<EnsembleMemberEntity>> getAllByEnsemble(
    String artistId,
    String ensembleId,
  );

  /// Atualiza um integrante.
  Future<void> update(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  );

  /// Remove um integrante.
  Future<void> delete(
    String artistId,
    String ensembleId,
    String memberId,
  );
}

/// Implementação usando Firestore.
class MembersRemoteDataSourceImpl implements IMembersRemoteDataSource {
  final FirebaseFirestore firestore;

  MembersRemoteDataSourceImpl({required this.firestore});

  @override
  Future<EnsembleMemberEntity> create(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  ) async {
    try {
      _validateIds(artistId, ensembleId);
      final ref = EnsembleMemberEntityReference
          .firebaseMembersCollectionReference(firestore, artistId, ensembleId);
      final data = member.toMap()..remove(EnsembleMemberEntityKeys.id);
      final docRef = await ref.add(data);
      final snapshot = await docRef.get();
      final raw = snapshot.data()! as Map<String, dynamic>;
      final map = _fromFirestoreMap(raw);
      map[EnsembleMemberEntityKeys.id] = docRef.id;
      map[EnsembleMemberEntityKeys.ensembleId] = ensembleId;
      return EnsembleMemberEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao criar integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<EnsembleMemberEntity?> getById(
    String artistId,
    String ensembleId,
    String memberId,
  ) async {
    try {
      _validateIds(artistId, ensembleId);
      if (memberId.isEmpty) return null;
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        ensembleId,
        memberId,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final raw = snapshot.data()! as Map<String, dynamic>;
      final map = _fromFirestoreMap(raw);
      map[EnsembleMemberEntityKeys.id] = snapshot.id;
      map[EnsembleMemberEntityKeys.ensembleId] = ensembleId;
      return EnsembleMemberEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<EnsembleMemberEntity>> getAllByEnsemble(
    String artistId,
    String ensembleId,
  ) async {
    try {
      _validateIds(artistId, ensembleId);
      final ref = EnsembleMemberEntityReference
          .firebaseMembersCollectionReference(firestore, artistId, ensembleId);
      final snapshot = await ref
          .where(EnsembleMemberEntityKeys.ensembleId, isEqualTo: ensembleId)
          .get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final raw = doc.data() as Map<String, dynamic>;
        final map = _fromFirestoreMap(raw);
        map[EnsembleMemberEntityKeys.id] = doc.id;
        map[EnsembleMemberEntityKeys.ensembleId] = ensembleId;
        return EnsembleMemberEntityMapper.fromMap(map);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao listar integrantes: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> update(
    String artistId,
    String ensembleId,
    EnsembleMemberEntity member,
  ) async {
    try {
      _validateIds(artistId, ensembleId);
      final memberId = member.id;
      if (memberId == null || memberId.isEmpty) {
        throw const ValidationException('ID do integrante é obrigatório');
      }
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        ensembleId,
        memberId,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw NotFoundException('Integrante não encontrado: $memberId');
      }
      final map = member.toMap()..remove(EnsembleMemberEntityKeys.id);
      await docRef.set(map, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        'Erro inesperado ao atualizar integrante',
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
  ) async {
    try {
      _validateIds(artistId, ensembleId);
      if (memberId.isEmpty) {
        throw const ValidationException('memberId não pode ser vazio');
      }
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        ensembleId,
        memberId,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw NotFoundException('Integrante não encontrado: $memberId');
      }
      await docRef.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao remover integrante: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is NotFoundException) rethrow;
      throw ServerException(
        'Erro inesperado ao remover integrante',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _validateIds(String artistId, String ensembleId) {
    if (artistId.isEmpty) {
      throw const ValidationException('artistId não pode ser vazio');
    }
    if (ensembleId.isEmpty) {
      throw const ValidationException('ensembleId não pode ser vazio');
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
