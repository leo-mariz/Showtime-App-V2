import 'package:app/core/domain/ensemble/members/ensemble_member_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para Members (integrantes).
///
/// Operações CRUD no Firestore. Caminho: EnsembleMembers/{artistId}/Members/{memberId}.
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NotFoundException, etc.)
/// - NÃO faz validações de negócio. Toda validação de CPF, duplicidade etc.
///   fica nos usecases/camada superior.
abstract class IMembersRemoteDataSource {
  /// Cria um integrante no pool do artista. Retorna a entidade com ID preenchido.
  Future<EnsembleMemberEntity> create(
    String artistId,
    EnsembleMemberEntity member,
  );

  /// Busca um integrante por ID.
  Future<EnsembleMemberEntity?> getById(
    String artistId,
    String memberId,
  );

  /// Lista todos os integrantes do artista (pool).
  Future<List<EnsembleMemberEntity>> getAll(String artistId);

  /// Atualiza um integrante.
  Future<void> update(
    String artistId,
    EnsembleMemberEntity member,
  );

  /// Remove um integrante.
  Future<void> delete(
    String artistId,
    String memberId,
  );
}

/// Implementação usando Firestore.
class MembersRemoteDataSourceImpl implements IMembersRemoteDataSource {
  final FirebaseFirestore firestore;

  MembersRemoteDataSourceImpl({required this.firestore});

  CollectionReference _membersCollection(String artistId) {
    return EnsembleMemberEntityReference.firebaseMembersCollectionReference(
      firestore,
      artistId,
      '',
    );
  }

  @override
  Future<EnsembleMemberEntity> create(
    String artistId,
    EnsembleMemberEntity member,
  ) async {
    try {
      _validateArtistId(artistId);
      final ref = _membersCollection(artistId);
      final data = member.toMap()
        ..remove(EnsembleMemberEntityKeys.id)
        ..[EnsembleMemberEntityKeys.ensembleId] =
            member.ensembleIds?.isEmpty ?? true ? '' : member.ensembleIds?.join(',') ?? '';
      final docRef = await ref.add(data);
      await docRef.update({EnsembleMemberEntityKeys.id: docRef.id});
      final snapshot = await docRef.get();
      final raw = snapshot.data() ?? {};
      final map = _fromFirestoreMap(raw as Map<dynamic, dynamic>);
      map[EnsembleMemberEntityKeys.id] = docRef.id;
      _ensureEnsembleIdsList(map);
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
    String memberId,
  ) async {
    try {
      _validateArtistId(artistId);
      if (memberId.isEmpty) return null;
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        '',
        memberId,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final raw = snapshot.data()! as Map<String, dynamic>;
      final map = _fromFirestoreMap(raw);
      map[EnsembleMemberEntityKeys.id] = snapshot.id;
      _ensureEnsembleIdsList(map);
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
  Future<List<EnsembleMemberEntity>> getAll(String artistId) async {
    try {
      _validateArtistId(artistId);
      final ref = _membersCollection(artistId);
      final snapshot = await ref.get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final raw = doc.data() as Map<String, dynamic>;
        final map = _fromFirestoreMap(raw);
        map[EnsembleMemberEntityKeys.id] = doc.id;
        _ensureEnsembleIdsList(map);
        return EnsembleMemberEntityMapper.fromMap(map);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao listar integrantes do artista: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> update(
    String artistId,
    EnsembleMemberEntity member,
  ) async {
    try {
      _validateArtistId(artistId);
      final memberId = member.id;
      if (memberId == null || memberId.isEmpty) {
        throw const ValidationException('ID do integrante é obrigatório');
      }
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        '',
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
    String memberId,
  ) async {
    try {
      _validateArtistId(artistId);
      if (memberId.isEmpty) {
        throw const ValidationException('memberId não pode ser vazio');
      }
      final docRef = EnsembleMemberEntityReference.firebaseMemberReference(
        firestore,
        artistId,
        '',
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

  void _validateArtistId(String artistId) {
    if (artistId.isEmpty) {
      throw const ValidationException('artistId não pode ser vazio');
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

  /// Garante que o map tenha 'ensembleIds' como List<String> para o mapper.
  /// No Firestore pode estar gravado como 'ensembleId' (string com vírgulas).
  static void _ensureEnsembleIdsList(Map<String, dynamic> map) {
    if (map['ensembleIds'] != null && map['ensembleIds'] is List) return;
    final raw = map[EnsembleMemberEntityKeys.ensembleId];
    if (raw == null) return;
    final str = raw is String ? raw : raw.toString();
    if (str.isEmpty) return;
    map['ensembleIds'] = str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}
