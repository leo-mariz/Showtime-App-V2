import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/utils/firestore_mapper_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para Ensembles (conjuntos).
///
/// Operações CRUD no Firestore. Coleção top-level: Ensembles/{ensembleId}.
/// Listar por artista: query onde ownerArtistId == artistId.
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NotFoundException, etc.)
/// - NÃO faz validações de negócio
abstract class IEnsembleRemoteDataSource {
  /// Cria um conjunto. Retorna a entidade com id.
  Future<EnsembleEntity> create(String artistId, EnsembleEntity ensemble);

  /// Busca um conjunto por ID.
  Future<EnsembleEntity?> getById(String artistId, String ensembleId);

  /// Lista todos os conjuntos do artista (query por ownerArtistId).
  Future<List<EnsembleEntity>> getAllByArtist(String artistId);

  /// Atualiza um conjunto.
  Future<void> update(String artistId, EnsembleEntity ensemble);

  /// Remove um conjunto.
  Future<void> delete(String artistId, String ensembleId);
}

/// Implementação usando Firestore.
class EnsembleRemoteDataSourceImpl implements IEnsembleRemoteDataSource {
  final FirebaseFirestore firestore;

  EnsembleRemoteDataSourceImpl({required this.firestore});

  @override
  Future<EnsembleEntity> create(String artistId, EnsembleEntity ensemble) async {
    try {
      _validateArtistId(artistId);
      final ref =
          EnsembleEntityReference.firebaseEnsemblesCollectionReference(
        firestore,
      );
      final data = ensemble.toMap()..remove(EnsembleEntityKeys.id);
      _setTimestamps(data, create: true);
      final docRef = await ref.add(data);
      final snapshot = await docRef.get();
      final raw = snapshot.data();
      if (raw == null) {
        throw const ServerException('Conjunto criado mas dados não encontrados');
      }
      final map = convertFirestoreMapForMapper(Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
      map[EnsembleEntityKeys.id] = docRef.id;
      return EnsembleEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao criar conjunto: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<EnsembleEntity?> getById(String artistId, String ensembleId) async {
    try {
      _validateEnsembleId(ensembleId);
      final docRef =
          EnsembleEntityReference.firebaseEnsembleReference(
        firestore,
        ensembleId,
      );
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final raw = snapshot.data()! as Map<String, dynamic>;
      final map = convertFirestoreMapForMapper(raw);
      map[EnsembleEntityKeys.id] = snapshot.id;
      return EnsembleEntityMapper.fromMap(map);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar conjunto: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<EnsembleEntity>> getAllByArtist(String artistId) async {
    try {
      _validateArtistId(artistId);
      final ref =
          EnsembleEntityReference.firebaseEnsemblesCollectionReference(
        firestore,
      );
      final snapshot = await ref
          .where(EnsembleEntityKeys.ownerArtistId, isEqualTo: artistId)
          .get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final raw = doc.data();
        final map = convertFirestoreMapForMapper(Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
        map[EnsembleEntityKeys.id] = doc.id;
        return EnsembleEntityMapper.fromMap(map);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao listar conjuntos: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> update(String artistId, EnsembleEntity ensemble) async {
    try {
      final id = ensemble.id;
      if (id == null || id.isEmpty) {
        throw const ValidationException('ID do conjunto é obrigatório');
      }
      final docRef =
          EnsembleEntityReference.firebaseEnsembleReference(
        firestore,
        id,
      );
      final map = ensemble.toMap()..remove(EnsembleEntityKeys.id);
      _setTimestamps(map, create: false);
      // Usar update() em vez de set(merge: true) para que campos map (ex.: incompleteSections)
      // sejam substituídos por inteiro. Com merge, chaves antigas do mapa permanecem.
      final updateData = <String, dynamic>{};
      for (final entry in map.entries) {
        if (entry.value == null) {
          updateData[entry.key] = FieldValue.delete();
        } else {
          updateData[entry.key] = entry.value;
        }
      }
      await docRef.update(updateData);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar conjunto: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> delete(String artistId, String ensembleId) async {
    try {
      _validateEnsembleId(ensembleId);
      final ensembleRef =
          EnsembleEntityReference.firebaseEnsembleReference(
        firestore,
        ensembleId,
      );
      await ensembleRef.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao remover conjunto: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
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

  void _validateEnsembleId(String ensembleId) {
    if (ensembleId.isEmpty) {
      throw const ValidationException('ensembleId não pode ser vazio');
    }
  }

  void _setTimestamps(Map<String, dynamic> data, {required bool create}) {
    if (create) {
      data[EnsembleEntityKeys.createdAt] = FieldValue.serverTimestamp();
    }
    data[EnsembleEntityKeys.updatedAt] = FieldValue.serverTimestamp();
  }

}
