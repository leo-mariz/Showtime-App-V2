
import 'package:app/core/domain/artist/artist_groups/group_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Groups
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações (use métodos específicos)
abstract class IGroupsRemoteDataSource {
  /// Salva/atualiza dados do grupo
  /// Lança [ServerException] em caso de erro
  Future<void> addGroup(String uid, GroupEntity data);
  
  /// Busca dados do grupo
  /// Retorna GroupEntity vazio se não existir
  /// Lança [ServerException] em caso de erro
  Future<GroupEntity> getGroup(String uid);
  
  /// Busca todos os grupos
  /// Retorna lista vazia se não existir nenhum
  /// Lança [ServerException] em caso de erro
  Future<List<GroupEntity>> getGroups();
  
  /// Atualiza um grupo existente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o grupo não existir
  Future<void> updateGroup(String uid, GroupEntity group);
  
  /// Deleta um grupo
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o grupo não existir
  Future<void> deleteGroup(String uid);
}

/// Implementação do DataSource remoto usando Firestore
class GroupsRemoteDataSourceImpl implements IGroupsRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addGroup(String uid, GroupEntity data) async {
    try {
      final documentReference = GroupEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final groupMap = data.toMap();
      await documentReference.set(groupMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar dados do grupo no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao salvar dados do grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<GroupEntity> getGroup(String uid) async {
    try {
      final documentReference = GroupEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final snapshot = await documentReference.get();
      
      if (snapshot.exists) {
        final groupMap = snapshot.data() as Map<String, dynamic>;
        final group = GroupEntityMapper.fromMap(groupMap);
        return group.copyWith(uid: uid);
      }
      
      return GroupEntity();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar dados do grupo no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar dados do grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<GroupEntity>> getGroups() async {
    try {
      final collectionReference = GroupEntityReference.firebaseCollectionReference(
        firestore,
      );
      final querySnapshot = await collectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      
      return querySnapshot.docs.map((doc) {
        final groupMap = doc.data() as Map<String, dynamic>;
        final group = GroupEntityMapper.fromMap(groupMap);
        return group.copyWith(uid: doc.id);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar grupos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar grupos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateGroup(String uid, GroupEntity group) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do grupo não pode ser vazio',
        );
      }

      final documentReference = GroupEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Verifica se o documento existe
      final documentSnapshot = await documentReference.get();
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Grupo não encontrado',
        );
      }

      // Remove o uid do map antes de atualizar (já está no documento)
      final groupMap = group.toMap();
      groupMap.remove('uid');

      await documentReference.update(groupMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar grupo: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteGroup(String uid) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do grupo não pode ser vazio',
        );
      }

      final documentReference = GroupEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Verifica se o documento existe
      final documentSnapshot = await documentReference.get();
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Grupo não encontrado',
        );
      }

      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar grupo: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao deletar grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

