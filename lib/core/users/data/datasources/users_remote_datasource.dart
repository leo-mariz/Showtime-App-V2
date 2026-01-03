import 'package:app/core/users/domain/entities/cnpj/cnpj_user_entity.dart';
import 'package:app/core/users/domain/entities/cpf/cpf_user_entity.dart';
import 'package:app/core/users/domain/entities/user_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore)
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações (use métodos específicos como cpfExists)
abstract class IUsersRemoteDataSource {
  /// Salva/atualiza dados do usuário no Firestore
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se UID não estiver presente
  Future<void> setFirestoreUserData(UserEntity data);
  
  /// Salva/atualiza dados CPF do usuário
  /// Lança [ServerException] em caso de erro
  Future<void> setFirestoreCpfUserInfo(String uid, CpfUserEntity data);
  
  /// Salva/atualiza dados CNPJ do usuário
  /// Lança [ServerException] em caso de erro
  Future<void> setFirestoreCnpjUserInfo(String uid, CnpjUserEntity data);
  
  /// Busca dados do usuário
  /// Retorna UserEntity com email vazio se não existir
  /// Lança [ServerException] em caso de erro
  Future<UserEntity> getFirestoreUserData(String uid);
  
  /// Verifica se CPF já existe no banco
  /// Lança [ServerException] em caso de erro
  Future<bool> cpfExists(String cpf);
  
  /// Verifica se CNPJ já existe no banco
  /// Lança [ServerException] em caso de erro
  Future<bool> cnpjExists(String cnpj);
  
  /// Verifica se email já existe no banco
  /// Lança [ServerException] em caso de erro
  Future<bool> emailExists(String email);

  /// Retorna o UID do usuário via email
  /// Lança [ServerException] em caso de erro
  Future<String?> getOtherUserUidViaEmail(String email);
}

/// Implementação do DataSource remoto usando Firestore
class UsersRemoteDataSourceImpl implements IUsersRemoteDataSource {
  final FirebaseFirestore firestore;

  UsersRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> setFirestoreUserData(UserEntity data) async {
    try {
      final uid = data.uid;
      
      if (uid == null || uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser nulo ou vazio',
        );
      }

      final documentReference = UserEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      
      final userMap = data.toMap();
      
      // Remove campos sensíveis/desnecessários
      userMap.removeWhere(
        (key, value) =>
            key == 'isArtist' ||
            key == 'password' ||
            key == 'isCnpj' ||
            key == 'cpfUser' ||
            key == 'cnpjUser' ||
            key == 'uid',
      );

      await documentReference.set(userMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar dados do usuário no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao salvar dados do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setFirestoreCpfUserInfo(String uid, CpfUserEntity data) async {
    try {
      final documentReference = UserEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final cpfUserMap = data.toMap();
      await documentReference.set(
        {'cpfUser': cpfUserMap},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar dados CPF no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao salvar dados CPF',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setFirestoreCnpjUserInfo(String uid, CnpjUserEntity data) async {
    try {
      final documentReference = UserEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final cnpjUserMap = data.toMap();
      await documentReference.set(
        {'cnpjUser': cnpjUserMap},
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar dados CNPJ no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao salvar dados CNPJ',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }


  @override
  Future<UserEntity> getFirestoreUserData(String uid) async {
    try {
      final documentReference = UserEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final snapshot = await documentReference.get();
      
      if (snapshot.exists) {
        final userMap = snapshot.data() as Map<String, dynamic>;
        return UserEntityMapper.fromMap(userMap);
      }
      
      return UserEntity(email: '');
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar dados do usuário no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar dados do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> cpfExists(String cpf) async {
    try {
      final usersColRef = UserEntityReference.firebaseCollectionReference(
        firestore,
      );
      final querySnapshot = await usersColRef
          .where('cpfUser.cpf', isEqualTo: cpf)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar se CPF existe: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao verificar CPF',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> cnpjExists(String cnpj) async {
    try {
      final usersColRef = UserEntityReference.firebaseCollectionReference(
        firestore,
      );
      final querySnapshot = await usersColRef
          .where('cnpjUser.cnpj', isEqualTo: cnpj)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar se CNPJ existe: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao verificar CNPJ',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      final usersColRef = UserEntityReference.firebaseCollectionReference(
        firestore,
      );
      final querySnapshot = await usersColRef
          .where('email', isEqualTo: email)
          .where('isDeleted', isEqualTo: false)
          .where('isDeletedByAdmin', isEqualTo: false)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar se email existe: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao verificar email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getOtherUserUidViaEmail(String email) async {
    try {
      final usersColRef = UserEntityReference.firebaseCollectionReference(
        firestore,
      );
      final querySnapshot = await usersColRef
          .where('email', isEqualTo: email)
          .where('isDeleted', isEqualTo: false)
          .where('isDeletedByAdmin', isEqualTo: false)
          .get();
      
      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar UID do usuário via email: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar UID do usuário via email',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}


