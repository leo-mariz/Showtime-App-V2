import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_availability_day_reference.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/utils/firestore_mapper_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para Availability do conjunto
///
/// Arquitetura baseada em dias (estilo Airbnb)
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - Focado em operações CRUD no Firestore (Ensembles/{ensembleId}/AvailabilityDays)
abstract class IEnsembleAvailabilityRemoteDataSource {
  /// Busca todas as disponibilidades de um conjunto
  ///
  /// [ensembleId]: ID do conjunto
  ///
  /// Retorna lista de todos os dias com disponibilidade
  /// Lança [ServerException] em caso de erro
  Future<List<AvailabilityDayEntity>> getAvailabilities(String ensembleId);

  /// Busca uma disponibilidade de um conjunto
  ///
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia (formato YYYY-MM-DD)
  ///
  /// Retorna o dia de disponibilidade
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> getAvailability(String ensembleId, String dayId);

  /// Cria um novo dia de disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [day]: Dia de disponibilidade a criar
  ///
  /// Retorna o documento criado
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> createAvailability(
    String ensembleId,
    AvailabilityDayEntity day,
  );

  /// Atualiza um dia de disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [day]: Dia atualizado
  ///
  /// Retorna o documento atualizado
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> updateAvailability(
    String ensembleId,
    AvailabilityDayEntity day,
  );

  /// Deleta um dia de disponibilidade
  ///
  /// [ensembleId]: ID do conjunto
  /// [dayId]: ID do dia a deletar (formato: YYYY-MM-DD)
  ///
  /// Lança [ServerException] em caso de erro
  Future<void> deleteAvailability(String ensembleId, String dayId);
}

/// Implementação do DataSource remoto usando Firestore (Ensembles/{id}/AvailabilityDays)
class EnsembleAvailabilityRemoteDataSourceImpl
    implements IEnsembleAvailabilityRemoteDataSource {
  final FirebaseFirestore firestore;

  EnsembleAvailabilityRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AvailabilityDayEntity>> getAvailabilities(String ensembleId) async {
    try {
      _validateEnsembleId(ensembleId);

      final collection =
          EnsembleAvailabilityDayReference.firestoreCollection(
              firestore, ensembleId);

      final querySnapshot = await collection.get();

      final days = querySnapshot.docs.map((doc) {
        final dayMap = doc.data() as Map<String, dynamic>;

        final cleanedMap = convertFirestoreMapForMapper(dayMap);

        final day = AvailabilityDayEntityMapper.fromMap(cleanedMap);
        return day.copyWith(id: doc.id);
      }).toList();

      return days;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidades: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar disponibilidades',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityDayEntity> getAvailability(
      String ensembleId, String dayId) async {
    try {
      _validateEnsembleId(ensembleId);
      _validateDayId(dayId);

      final docRef =
          EnsembleAvailabilityDayReference.firestoreDocument(
              firestore, ensembleId, dayId);

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw NotFoundException(
            'Disponibilidade não encontrada para o dia: $dayId');
      }

      final dayMap = snapshot.data() as Map<String, dynamic>;
      final cleanedMap = convertFirestoreMapForMapper(dayMap);
      final day = AvailabilityDayEntityMapper.fromMap(cleanedMap);
      return day.copyWith(id: dayId);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidade: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityDayEntity> createAvailability(
    String ensembleId,
    AvailabilityDayEntity day,
  ) async {
    try {
      _validateEnsembleId(ensembleId);

      final dayId = day.documentId;
      final docRef =
          EnsembleAvailabilityDayReference.firestoreDocument(
              firestore, ensembleId, dayId);

      final dayMap = day.toMap();
      dayMap['createdAt'] = FieldValue.serverTimestamp();
      dayMap['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(dayMap);

      return day.copyWith(id: dayId);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao criar disponibilidade: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao criar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityDayEntity> updateAvailability(
    String ensembleId,
    AvailabilityDayEntity day,
  ) async {
    try {
      _validateEnsembleId(ensembleId);

      final dayId = day.documentId;
      final docRef =
          EnsembleAvailabilityDayReference.firestoreDocument(
              firestore, ensembleId, dayId);

      final dayMap = day.toMap();
      dayMap['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(dayMap, SetOptions(merge: true));

      return day.copyWith(id: dayId);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar disponibilidade: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteAvailability(String ensembleId, String dayId) async {
    try {
      _validateEnsembleId(ensembleId);
      _validateDayId(dayId);

      final docRef =
          EnsembleAvailabilityDayReference.firestoreDocument(
              firestore, ensembleId, dayId);

      await docRef.delete();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao deletar disponibilidade: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao deletar disponibilidade',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== HELPERS ====================

  void _validateEnsembleId(String ensembleId) {
    if (ensembleId.isEmpty) {
      throw const ValidationException('ID do conjunto não pode ser vazio');
    }
  }
  
  void _validateDayId(String dayId) {
    if (dayId.isEmpty) {
      throw const ValidationException('ID do dia não pode ser vazio');
    }
    
    // Validar formato YYYY-MM-DD
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(dayId)) {
      throw ValidationException('Formato de ID inválido. Use YYYY-MM-DD. Recebido: $dayId');
    }
  }
  
}
