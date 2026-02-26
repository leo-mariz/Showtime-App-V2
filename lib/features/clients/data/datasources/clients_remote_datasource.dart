import 'package:app/core/domain/client/client_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/utils/firestore_mapper_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Interface do DataSource remoto (Firestore) para Clients
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IClientsRemoteDataSource {
  /// Busca dados do cliente por UID
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o cliente não existir
  Future<ClientEntity> getClient(String uid);
  
  /// Adiciona um novo cliente
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se UID não estiver presente
  Future<void> addClient(String uid, ClientEntity client);
  
  /// Atualiza um cliente existente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o cliente não existir
  Future<void> updateClient(String uid, ClientEntity client);
  
  /// Remove um cliente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o cliente não existir
  Future<void> deleteClient(String uid);
}

/// Implementação do DataSource remoto usando Firestore
class ClientsRemoteDataSourceImpl implements IClientsRemoteDataSource {
  final FirebaseFirestore firestore;

  ClientsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ClientEntity> getClient(String uid) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final documentReference = ClientEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      
      final documentSnapshot = await documentReference.get();
      
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Cliente não encontrado',
        );
      }

      final clientMap = documentSnapshot.data() as Map<String, dynamic>;
      final convertedMap = convertFirestoreMapForMapper(clientMap);
      final client = ClientEntityMapper.fromMap(convertedMap);
      return client;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar cliente: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [ClientsRemoteDataSource] Erro inesperado ao buscar cliente');
        debugPrint('🔴 [ClientsRemoteDataSource] Tipo do erro: ${e.runtimeType}');
        debugPrint('🔴 [ClientsRemoteDataSource] Mensagem: $e');
        debugPrint('🔴 [ClientsRemoteDataSource] StackTrace: $stackTrace');
      }
      throw ServerException(
        'Erro inesperado ao buscar cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addClient(String uid, ClientEntity client) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final documentReference = ClientEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Remove o uid do map antes de salvar (já está no documento)
      client.uid = uid;
      final clientMap = client.toMap();
      await documentReference.set(clientMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao adicionar cliente: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao adicionar cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateClient(String uid, ClientEntity client) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final documentReference = ClientEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Verifica se o documento existe
      final documentSnapshot = await documentReference.get();
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Cliente não encontrado',
        );
      }

      // Remove o uid do map antes de atualizar (já está no documento)
      final clientMap = client.toMap();

      await documentReference.update(clientMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar cliente: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteClient(String uid) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do cliente não pode ser vazio',
        );
      }

      final documentReference = ClientEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Verifica se o documento existe
      final documentSnapshot = await documentReference.get();
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Cliente não encontrado',
        );
      }

      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar cliente: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao deletar cliente',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

