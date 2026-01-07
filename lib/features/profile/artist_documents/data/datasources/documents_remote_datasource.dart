import 'package:app/core/domain/artist/artist_individual/documents/documents_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Documents
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IDocumentsRemoteDataSource {
  /// Busca lista de documentos do artista
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<DocumentsEntity>> getDocuments(String artistId);
  
  /// Busca um documento específico por tipo (documentType)
  /// Retorna null se não existir
  /// Lança [ServerException] em caso de erro
  Future<DocumentsEntity?> getDocument(String artistId, String documentType);
  
  /// Salva/atualiza um documento na subcoleção
  /// O documentType é usado como ID do documento
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId ou documentType não estiverem presentes
  Future<void> setDocument(String artistId, DocumentsEntity document);
  
  /// Remove um documento da subcoleção
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o documento não existir
  Future<void> deleteDocument(String artistId, String documentType);
}

/// Implementação do DataSource remoto usando Firestore
class DocumentsRemoteDataSourceImpl implements IDocumentsRemoteDataSource {
  final FirebaseFirestore firestore;

  DocumentsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DocumentsEntity>> getDocuments(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final documentCollectionReference = DocumentsEntityReference.firebaseCollectionReference(
        firestore,
        artistId,
      );
      
      final querySnapshot = await documentCollectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final documentMap = doc.data() as Map<String, dynamic>;
            final document = DocumentsEntityMapper.fromMap(documentMap);
            return document;
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar documentos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar documentos',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DocumentsEntity?> getDocument(String artistId, String documentType) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      if (documentType.isEmpty) {
        throw const ValidationException(
          'Tipo de documento não pode ser vazio',
        );
      }

      final documentReference = DocumentsEntityReference.firebaseUidReference(
        firestore,
        artistId,
        documentType,
      );
      
      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        return null;
      }

      final documentMap = snapshot.data() as Map<String, dynamic>;
      final document = DocumentsEntityMapper.fromMap(documentMap);
      return document;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar documento no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar documento',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setDocument(String artistId, DocumentsEntity document) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      if (document.documentType.isEmpty) {
        throw const ValidationException(
          'Tipo de documento não pode ser vazio',
        );
      }

      final documentReference = DocumentsEntityReference.firebaseUidReference(
        firestore,
        artistId,
        document.documentType,
      );

      final documentMap = document.toMap();
      await documentReference.set(documentMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar documento no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao salvar documento',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteDocument(String artistId, String documentType) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      if (documentType.isEmpty) {
        throw const ValidationException(
          'Tipo de documento não pode ser vazio',
        );
      }

      final documentReference = DocumentsEntityReference.firebaseUidReference(
        firestore,
        artistId,
        documentType,
      );

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Documento não encontrado: $documentType');
      }

      // Deletar documento
      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar documento no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao deletar documento',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

