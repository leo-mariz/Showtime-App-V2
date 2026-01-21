import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface do DataSource remoto para Availability
/// 
/// Arquitetura baseada em dias (estilo Airbnb)
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - Focado em operações CRUD no Firestore
abstract class IAvailabilityRemoteDataSource {
  /// Busca todas as disponibilidades de um artista
  /// 
  /// [artistId]: ID do artista
  /// 
  /// Retorna lista de todos os dias com disponibilidade
  /// Lança [ServerException] em caso de erro
  Future<List<AvailabilityDayEntity>> getAvailabilities(String artistId);
  

  /// Busca todas as disponibilidades de um artista
  /// 
  /// [artistId]: ID do artista
  /// [forceRemote]: Se true, força busca no servidor (ignora cache)
  /// 
  /// Retorna lista de todos os dias com disponibilidade
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> getAvailability(String artistId, String dayId);



  /// Cria um novo dia de disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [day]: Dia de disponibilidade a criar
  /// 
  /// Retorna o documento criado
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> createAvailability(
    String artistId,
    AvailabilityDayEntity day,
  );
  
  /// Atualiza um dia de disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [day]: Dia atualizado
  /// 
  /// Retorna o documento atualizado
  /// Lança [ServerException] em caso de erro
  Future<AvailabilityDayEntity> updateAvailability(
    String artistId,
    AvailabilityDayEntity day,
  );
  
  /// Deleta um dia de disponibilidade
  /// 
  /// [artistId]: ID do artista
  /// [dayId]: ID do dia a deletar (formato: YYYY-MM-DD)
  /// 
  /// Lança [ServerException] em caso de erro
  Future<void> deleteAvailability(String artistId, String dayId);
}

/// Implementação do DataSource remoto usando Firestore
class AvailabilityRemoteDataSourceImpl implements IAvailabilityRemoteDataSource {
  final FirebaseFirestore firestore;
  
  AvailabilityRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<List<AvailabilityDayEntity>> getAvailabilities(String artistId) async {
    try {
      _validateArtistId(artistId);
      
      final collection = AvailabilityDayReference.firestoreCollection(
        firestore,
        artistId,
      );
      
      final querySnapshot = await collection.get();
      
      final days = querySnapshot.docs.map((doc) {
        final dayMap = doc.data() as Map<String, dynamic>;
        
        // Converter Timestamps para DateTime antes do mapper
        final cleanedMap = _convertTimestamps(dayMap);
        
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
  Future<AvailabilityDayEntity> getAvailability(String artistId, String dayId) async {
    try {
      _validateArtistId(artistId);
      _validateDayId(dayId);
      
      final docRef = AvailabilityDayReference.firestoreDocument(
        firestore,
        artistId,
        dayId,
      );
      
      final snapshot = await docRef.get();
      
      if (!snapshot.exists) {
        throw NotFoundException('Disponibilidade não encontrada para o dia: $dayId');
      }
      
      final dayMap = snapshot.data() as Map<String, dynamic>;
      final cleanedMap = _convertTimestamps(dayMap);
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
    String artistId,
    AvailabilityDayEntity day,
  ) async {
    try {
      _validateArtistId(artistId);
      
      final dayId = day.documentId;
      final docRef = AvailabilityDayReference.firestoreDocument(
        firestore,
        artistId,
        dayId,
      );
      
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
    String artistId,
    AvailabilityDayEntity day,
  ) async {
    try {
      _validateArtistId(artistId);
      
      final dayId = day.documentId;
      final docRef = AvailabilityDayReference.firestoreDocument(
        firestore,
        artistId,
        dayId,
      );
      
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
  Future<void> deleteAvailability(String artistId, String dayId) async {
    try {
      _validateArtistId(artistId);
      _validateDayId(dayId);
      
      final docRef = AvailabilityDayReference.firestoreDocument(
        firestore,
        artistId,
        dayId,
      );
      
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
  
  void _validateArtistId(String artistId) {
    if (artistId.isEmpty) {
      throw const ValidationException('ID do artista não pode ser vazio');
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
  
  /// Converte recursivamente todos os Timestamps em DateTime
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Timestamp) {
        // Converter Timestamp para DateTime
        result[key] = value.toDate();
      } else if (value is Map) {
        // Recursão para mapas aninhados
        result[key] = _convertTimestamps(value as Map<String, dynamic>);
      } else if (value is List) {
        // Processar listas
        result[key] = value.map((item) {
          if (item is Map) {
            return _convertTimestamps(item as Map<String, dynamic>);
          } else if (item is Timestamp) {
            return item.toDate();
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    
    return result;
  }
}
