import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto (Firestore) para Availability
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
abstract class IAvailabilityRemoteDataSource {
  /// Busca lista de disponibilidades do artista
  /// Retorna lista vazia se não existir
  /// Lança [ServerException] em caso de erro
  Future<List<AvailabilityEntity>> getAvailabilities(String artistId);
  
  /// Busca uma disponibilidade específica por ID
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se a disponibilidade não existir
  Future<AvailabilityEntity> getAvailability(String artistId, String availabilityId);
  
  /// Adiciona uma nova disponibilidade à subcoleção do artista
  /// Retorna o ID do documento criado
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId não estiver presente
  Future<String> addAvailability(String artistId, AvailabilityEntity availability);
  
  /// Atualiza uma disponibilidade existente na subcoleção
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se a disponibilidade não existir
  Future<void> updateAvailability(String artistId, AvailabilityEntity availability);
  
  /// Remove uma disponibilidade da subcoleção
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se a disponibilidade não existir
  Future<void> deleteAvailability(String artistId, String availabilityId);
  
  /// Substitui todas as disponibilidades do artista (deleta antigas e adiciona novas)
  /// Usa batch operations para garantir atomicidade e eficiência
  /// Lança [ServerException] em caso de erro
  Future<void> replaceAvailabilities(
    String artistId,
    List<AvailabilityEntity> newAvailabilities,
  );
}

/// Implementação do DataSource remoto usando Firestore
class AvailabilityRemoteDataSourceImpl implements IAvailabilityRemoteDataSource {
  final FirebaseFirestore firestore;

  AvailabilityRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AvailabilityEntity>> getAvailabilities(String artistId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );
      
      final querySnapshot = await collectionReference.get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) {
            final availabilityMap = doc.data() as Map<String, dynamic>;
            final availability = AvailabilityEntityMapper.fromMap(availabilityMap);
            return availability.copyWith(id: doc.id);
          })
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidades no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar disponibilidades',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityEntity> getAvailability(String artistId, String availabilityId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      if (availabilityId.isEmpty) {
        throw const ValidationException(
          'ID da disponibilidade não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );
      
      final documentReference = collectionReference.doc(availabilityId);
      final snapshot = await documentReference.get();
      
      if (!snapshot.exists) {
        throw NotFoundException('Disponibilidade não encontrada: $availabilityId');
      }

      final availabilityMap = snapshot.data() as Map<String, dynamic>;
      final availability = AvailabilityEntityMapper.fromMap(availabilityMap);
      return availability.copyWith(id: snapshot.id);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidade no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> addAvailability(String artistId, AvailabilityEntity availability) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );

      // Criar novo documento na subcoleção
      final newDocRef = collectionReference.doc();
      final availabilityMap = availability.toMap();
      
      await newDocRef.set(availabilityMap);

      return newDocRef.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao adicionar disponibilidade no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao adicionar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAvailability(
    String artistId,
    AvailabilityEntity availability,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final availabilityId = availability.id;

      if (availabilityId == null || availabilityId.isEmpty) {
        throw const ValidationException(
          'ID da disponibilidade não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );
      
      final documentReference = collectionReference.doc(availabilityId);

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Disponibilidade não encontrada: $availabilityId');
      }

      // Atualizar documento
      final availabilityMap = availability.toMap();
      await documentReference.set(availabilityMap, SetOptions(merge: true));
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar disponibilidade no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao atualizar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAvailability(String artistId, String availabilityId) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      if (availabilityId.isEmpty) {
        throw const ValidationException(
          'ID da disponibilidade não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );
      
      final documentReference = collectionReference.doc(availabilityId);

      // Verificar se documento existe
      final snapshot = await documentReference.get();
      if (!snapshot.exists) {
        throw NotFoundException('Disponibilidade não encontrada: $availabilityId');
      }

      // Deletar documento
      await documentReference.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar disponibilidade no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao deletar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> replaceAvailabilities(
    String artistId,
    List<AvailabilityEntity> newAvailabilities,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      final collectionReference = ArtistAvailabilityEntityReference.firestoreUidReference(
        firestore,
        artistId,
      );

      // Buscar todas as disponibilidades existentes
      final existingSnapshot = await collectionReference.get();
      
      // Verificar limite do Firestore batch (500 operações)
      final totalOperations = existingSnapshot.docs.length + newAvailabilities.length;
      if (totalOperations > 500) {
        throw ServerException(
          'Número de operações excede o limite de 500 do Firestore batch. '
          'Tente reduzir o número de disponibilidades.',
        );
      }

      // Criar batch para operações atômicas
      final batch = firestore.batch();

      // Deletar todas as disponibilidades existentes
      for (final doc in existingSnapshot.docs) {
        final docRef = collectionReference.doc(doc.id);
        batch.delete(docRef);
      }

      // Adicionar novas disponibilidades
      for (final availability in newAvailabilities) {
        final newDocRef = collectionReference.doc();
        final availabilityMap = availability.toMap();
        batch.set(newDocRef, availabilityMap);
      }

      // Commitar batch (todas as operações são atômicas)
      await batch.commit();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao substituir disponibilidades no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException || e is ServerException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao substituir disponibilidades',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

