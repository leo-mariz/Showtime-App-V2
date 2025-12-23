import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Addresses
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IAddressesRemoteDataSource {
  /// Busca lista de endereços do usuário
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<AddressInfoEntity>> getAddresses(String uid);
  
  /// Adiciona um novo endereço à subcoleção do usuário
  /// Retorna o ID do documento criado
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se UID não estiver presente
  Future<String> addAddress(String uid, AddressInfoEntity address);
  
  /// Atualiza um endereço existente na subcoleção
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o endereço não existir
  Future<void> updateAddress(String uid, String addressId, AddressInfoEntity address);
  
  /// Remove um endereço da subcoleção
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o endereço não existir
  Future<void> deleteAddress(String uid, String addressId);
  
  /// Define um endereço como primário (e remove primário dos outros)
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o endereço não existir
  Future<void> setPrimaryAddress(String uid, String addressId);
}

/// Implementação do DataSource remoto usando Firestore
class AddressesRemoteDataSourceImpl implements IAddressesRemoteDataSource {
  final FirebaseFirestore firestore;

  AddressesRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AddressInfoEntity>> getAddresses(String uid) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser vazio',
        );
      }

      final collectionReference = AddressInfoEntityReference.firebaseCollectionReference(
        firestore,
        uid,
      );
      
      final querySnapshot = await collectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final addressMap = doc.data() as Map<String, dynamic>;
            return AddressInfoEntityMapper.fromMap(addressMap);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar endereços no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar endereços',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> addAddress(String uid, AddressInfoEntity address) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser vazio',
        );
      }

      final collectionReference = AddressInfoEntityReference.firebaseCollectionReference(
        firestore,
        uid,
      );

      // Criar novo documento na subcoleção
      final newDocRef = collectionReference.doc();
      final addressMap = address.toMap();
      
      await newDocRef.set(addressMap);

      return newDocRef.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao adicionar endereço no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao adicionar endereço',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAddress(
    String uid,
    String addressId,
    AddressInfoEntity address,
  ) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser vazio',
        );
      }

      if (addressId.isEmpty) {
        throw const ValidationException(
          'ID do endereço não pode ser vazio',
        );
      }

      final documentReference = AddressInfoEntityReference.firebaseDocumentReference(
        firestore,
        uid,
        addressId,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Endereço não encontrado: $addressId');
      }

      // Atualizar documento
      final addressMap = address.toMap();
      await documentReference.set(addressMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar endereço no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao atualizar endereço',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAddress(String uid, String addressId) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser vazio',
        );
      }

      if (addressId.isEmpty) {
        throw const ValidationException(
          'ID do endereço não pode ser vazio',
        );
      }

      final documentReference = AddressInfoEntityReference.firebaseDocumentReference(
        firestore,
        uid,
        addressId,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Endereço não encontrado: $addressId');
      }

      // Deletar documento
      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar endereço no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao deletar endereço',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setPrimaryAddress(String uid, String addressId) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do usuário não pode ser vazio',
        );
      }

      if (addressId.isEmpty) {
        throw const ValidationException(
          'ID do endereço não pode ser vazio',
        );
      }

      final collectionReference = AddressInfoEntityReference.firebaseCollectionReference(
        firestore,
        uid,
      );

      // Buscar todos os endereços
      final querySnapshot = await collectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        throw NotFoundException('Nenhum endereço encontrado para o usuário');
      }

      // Verificar se o endereço especificado existe
      final addressExists = querySnapshot.docs.any((doc) => doc.id == addressId);
      if (!addressExists) {
        throw NotFoundException('Endereço não encontrado: $addressId');
      }

      // Atualizar todos os endereços: remover primário de todos
      final batch = firestore.batch();
      for (final doc in querySnapshot.docs) {
        final docRef = collectionReference.doc(doc.id);
        batch.update(docRef, {'isPrimary': false});
      }
      
      // Definir o endereço especificado como primário
      final targetDocRef = collectionReference.doc(addressId);
      batch.update(targetDocRef, {'isPrimary': true});

      // Executar batch
      await batch.commit();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao definir endereço primário no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao definir endereço primário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

}
