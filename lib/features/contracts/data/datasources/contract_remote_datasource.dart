import 'package:app/core/domain/contract/contract_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Contracts
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IContractRemoteDataSource {
  /// Busca um contrato específico por UID
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<ContractEntity> getContract(String contractUid);
  
  /// Busca lista de contratos por cliente
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByClient(String clientUid);
  
  /// Busca lista de contratos por artista
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByArtist(String artistUid);
  
  /// Busca lista de contratos por grupo
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<ContractEntity>> getContractsByGroup(String groupUid);
  
  /// Adiciona um novo contrato
  /// Retorna o UID do contrato criado
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se UID não estiver presente
  Future<String> addContract(ContractEntity contract);
  
  /// Atualiza um contrato existente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<void> updateContract(ContractEntity contract);
  
  /// Remove um contrato
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o contrato não existir
  Future<void> deleteContract(String contractUid);
}

/// Implementação do DataSource remoto usando Firestore
class ContractRemoteDataSourceImpl implements IContractRemoteDataSource {
  final FirebaseFirestore firestore;

  ContractRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ContractEntity> getContract(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      final contractMap = snapshot.data() as Map<String, dynamic>;
      final contract = ContractEntityMapper.fromMap(contractMap);
      return contract.copyWith(uid: snapshot.id);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByClient(String clientUid) async {
    try {
      if (clientUid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refClient', isEqualTo: clientUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final contractMap = doc.data() as Map<String, dynamic>;
            final contract = ContractEntityMapper.fromMap(contractMap);
            return contract.copyWith(uid: doc.id);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do cliente no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByArtist(String artistUid) async {
    try {
      if (artistUid.isEmpty) {
        throw const ValidationException(
          'UID do artista não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refArtist', isEqualTo: artistUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final contractMap = doc.data() as Map<String, dynamic>;
            final contract = ContractEntityMapper.fromMap(contractMap);
            return contract.copyWith(uid: doc.id);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ContractEntity>> getContractsByGroup(String groupUid) async {
    try {
      if (groupUid.isEmpty) {
        throw const ValidationException(
          'UID do grupo não pode ser vazio',
        );
      }

      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      final querySnapshot = await collectionReference
          .where('refGroup', isEqualTo: groupUid)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final contractMap = doc.data() as Map<String, dynamic>;
            final contract = ContractEntityMapper.fromMap(contractMap);
            return contract.copyWith(uid: doc.id);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar contratos do grupo no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar contratos do grupo',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> addContract(ContractEntity contract) async {
    try {
      final collectionReference = ContractEntityReference.firebaseCollectionReference(
        firestore,
      );

      // Criar novo documento na coleção
      final newDocRef = collectionReference.doc();
      final contractMap = contract.toMap();
      
      await newDocRef.set(contractMap);

      return newDocRef.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao adicionar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao adicionar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateContract(ContractEntity contract) async {
    try {
      final contractUid = contract.uid;

      if (contractUid == null || contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      // Atualizar documento
      final contractMap = contract.toMap();
      await documentReference.set(contractMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao atualizar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteContract(String contractUid) async {
    try {
      if (contractUid.isEmpty) {
        throw const ValidationException(
          'UID do contrato não pode ser vazio',
        );
      }

      final documentReference = ContractEntityReference.firebaseUidReference(
        firestore,
        contractUid,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Contrato não encontrado: $contractUid');
      }

      // Deletar documento
      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar contrato no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao deletar contrato',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

