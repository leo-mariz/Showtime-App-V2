import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_availability_day_reference.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/utils/firestore_mapper_helper.dart';
import 'package:app/features/explore/domain/entities/artists/artist_with_availabilities_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Interface do DataSource remoto (Firestore) para Explore
/// Responsável APENAS por operações de busca no Firestore para explorar
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações de lógica
/// - Focado em queries otimizadas para explorar artistas
/// - Feature completamente independente (não reutiliza outras features)
abstract class IExploreRemoteDataSource {
  /// Busca todos os artistas aprovados e ativos
  /// Usado para explorar (não para perfil)
  /// Retorna lista vazia se não existir nenhum
  /// Lança [ServerException] em caso de erro
  Future<List<ArtistEntity>> getActiveApprovedArtists();

  /// Busca as informações de um artista pelo ID (documento na coleção de artistas).
  /// Retorna null se o documento não existir. Lança [ServerException] em caso de erro de rede.
  Future<ArtistEntity?> getArtistById(String artistId);

  /// Busca disponibilidade de um dia específico de um artista
  /// Usado para explorar (não para perfil)
  /// Retorna null se não existir disponibilidade para aquele dia
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId estiver vazio
  /// 
  /// [artistId]: ID do artista
  /// [date]: Data específica para buscar (formato: YYYY-MM-DD)
  Future<AvailabilityDayEntity?> getArtistAvailabilityDay(
    String artistId,
    DateTime date,
  );
  
  /// Busca todas as disponibilidades de um artista
  /// Usado para explorar (não para perfil)
  /// Retorna lista vazia se não existir nenhuma disponibilidade
  /// Lança [ServerException] em caso de erro
  /// Lança [ValidationException] se artistId estiver vazio
  /// 
  /// [artistId]: ID do artista
  /// 
  /// Retorna todas as disponibilidades do artista (sem filtros)
  /// O filtro de isActive e slots available será feito no UseCase
  Future<List<AvailabilityDayEntity>> getArtistAllAvailabilities(
    String artistId,
  );

  // ==================== ENSEMBLES (CONJUNTOS) ====================

  /// Busca todos os conjuntos ativos, sem seções incompletas e com todos os membros aprovados.
  Future<List<EnsembleEntity>> getActiveApprovedEnsembles();

  /// Busca disponibilidade de um dia específico de um conjunto.
  Future<AvailabilityDayEntity?> getEnsembleAvailabilityDay(
    String ensembleId,
    DateTime date,
  );

  /// Busca todas as disponibilidades de um conjunto.
  Future<List<AvailabilityDayEntity>> getEnsembleAllAvailabilities(
    String ensembleId,
  );
}

/// Implementação do DataSource remoto usando Firestore
class ExploreRemoteDataSourceImpl implements IExploreRemoteDataSource {
  final FirebaseFirestore firestore;

  // ==================== FIRESTORE FIELD KEYS (Constantes) ====================
  /// Chave do campo 'approved' no documento do artista
  static const String _firestoreFieldApproved = 'approved';
  
  /// Chave do campo 'isActive' no documento do artista
  static const String _firestoreFieldIsActive = 'isActive';

  ExploreRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ArtistEntity>> getActiveApprovedArtists() async {
    try {
      final artistsCollectionRef = ArtistWithAvailabilitiesEntityReference
          .artistsCollectionReference(firestore);

      // Query otimizada para explorar: apenas artistas aprovados e ativos
      final querySnapshot = await artistsCollectionRef
          .where(_firestoreFieldApproved, isEqualTo: true)
          .where(_firestoreFieldIsActive, isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final artistMap = doc.data() as Map<String, dynamic>;
        final cleanedMap = convertFirestoreMapForMapper(artistMap);
        final artist = ArtistEntityMapper.fromMap(cleanedMap);
        return artist.copyWith(uid: doc.id);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar artistas aprovados e ativos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar artistas para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ArtistEntity?> getArtistById(String artistId) async {
    try {
      if (artistId.isEmpty) return null;
      final artistsCollectionRef = ArtistWithAvailabilitiesEntityReference
          .artistsCollectionReference(firestore);
      final docRef = artistsCollectionRef.doc(artistId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return null;
      final artistMap = snapshot.data() as Map<String, dynamic>;
      final cleanedMap = convertFirestoreMapForMapper(artistMap);
      final artist = ArtistEntityMapper.fromMap(cleanedMap);
      return artist.copyWith(uid: snapshot.id);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityDayEntity?> getArtistAvailabilityDay(
    String artistId,
    DateTime date,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      // Gerar o ID do documento no formato YYYY-MM-DD
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final dayId = '$year-$month-$day';

      // Buscar o documento específico do dia
      final docRef = AvailabilityDayReference.firestoreDocument(
        firestore,
        artistId,
        dayId,
      );

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        // Dia não tem disponibilidade, retornar null
        return null;
      }

      final dayMap = snapshot.data() as Map<String, dynamic>;
      
      final cleanedMap = convertFirestoreMapForMapper(dayMap);
      
      final availabilityDay = AvailabilityDayEntityMapper.fromMap(cleanedMap);
      return availabilityDay.copyWith(id: dayId);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidade do dia no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar disponibilidade do dia para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AvailabilityDayEntity>> getArtistAllAvailabilities(
    String artistId,
  ) async {
    try {
      if (artistId.isEmpty) {
        throw const ValidationException(
          'ID do artista não pode ser vazio',
        );
      }

      // Buscar todas as disponibilidades da coleção AvailabilityDays
      final collectionRef = AvailabilityDayReference.firestoreCollection(
        firestore,
        artistId,
      );

      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final availabilities = <AvailabilityDayEntity>[];
      
      for (final doc in querySnapshot.docs) {
        try {
          final dayMap = doc.data() as Map<String, dynamic>;
          
          final cleanedMap = convertFirestoreMapForMapper(dayMap);
          
          final availabilityDay = AvailabilityDayEntityMapper.fromMap(cleanedMap);
          availabilities.add(availabilityDay.copyWith(id: doc.id));
        } catch (e, stackTrace) {
          // Continuar processando outros documentos mesmo se um falhar
          print('🔴 [REMOTE_DS] Erro ao processar documento ${doc.id}: $e $stackTrace');
        }
      } 
      
      return availabilities;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar todas as disponibilidades do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      
      throw ServerException(
        'Erro inesperado ao buscar todas as disponibilidades do artista para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== ENSEMBLES (CONJUNTOS) ====================

  static const String _firestoreFieldEnsembleIsActive = 'isActive';
  static const String _firestoreFieldHasIncompleteSections =
      'hasIncompleteSections';

  /// Conjuntos ativos e sem seções incompletas.
  /// Aprovação do grupo é determinada pelo artista dono (owner) estar aprovado;
  /// não há mais filtro por allMembersApproved.
  @override
  Future<List<EnsembleEntity>> getActiveApprovedEnsembles() async {
    try {
      final ref =
          EnsembleEntityReference.firebaseEnsemblesCollectionReference(
        firestore,
      );
      final querySnapshot = await ref
          .where(_firestoreFieldEnsembleIsActive, isEqualTo: true)
          .where(_firestoreFieldHasIncompleteSections, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final results = <EnsembleEntity>[];
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        try {
          final map = doc.data() as Map<String, dynamic>;
          final cleanedMap = convertFirestoreMapForMapper(map);
          final ensemble = EnsembleEntityMapper.fromMap(cleanedMap);
          results.add(ensemble.copyWith(id: doc.id));
        } catch (e, stackTrace) {
          debugPrint(
            '[ExploreRemote] getActiveApprovedEnsembles: erro ao mapear doc[$i] id=${doc.id}: $e',
          );
          debugPrint(stackTrace.toString());
          throw ServerException(
            'Erro ao mapear conjunto "${doc.id}": $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      }
      return results;
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('[ExploreRemote] getActiveApprovedEnsembles FirebaseException: ${e.message}');
      throw ServerException(
        'Erro ao buscar conjuntos no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      debugPrint('[ExploreRemote] getActiveApprovedEnsembles: $e');
      debugPrint(stackTrace.toString());
      throw ServerException(
        'Erro inesperado ao buscar conjuntos para explorar: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<AvailabilityDayEntity?> getEnsembleAvailabilityDay(
    String ensembleId,
    DateTime date,
  ) async {
    try {
      if (ensembleId.isEmpty) {
        throw const ValidationException(
          'ID do conjunto não pode ser vazio',
        );
      }

      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final dayId = '$year-$month-$day';

      final docRef = EnsembleAvailabilityDayReference.firestoreDocument(
        firestore,
        ensembleId,
        dayId,
      );

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return null;
      }

      final dayMap = snapshot.data() as Map<String, dynamic>;
      final cleanedMap = convertFirestoreMapForMapper(dayMap);
      final availabilityDay =
          AvailabilityDayEntityMapper.fromMap(cleanedMap);
      return availabilityDay.copyWith(id: dayId);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar disponibilidade do dia do conjunto no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        'Erro inesperado ao buscar disponibilidade do dia do conjunto para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<AvailabilityDayEntity>> getEnsembleAllAvailabilities(
    String ensembleId,
  ) async {
    try {
      if (ensembleId.isEmpty) {
        throw const ValidationException(
          'ID do conjunto não pode ser vazio',
        );
      }

      final collectionRef =
          EnsembleAvailabilityDayReference.firestoreCollection(
        firestore,
        ensembleId,
      );

      final querySnapshot = await collectionRef.get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final availabilities = <AvailabilityDayEntity>[];
      for (final doc in querySnapshot.docs) {
        try {
          final dayMap = doc.data() as Map<String, dynamic>;
          final cleanedMap = convertFirestoreMapForMapper(dayMap);
          final availabilityDay =
              AvailabilityDayEntityMapper.fromMap(cleanedMap);
          availabilities.add(availabilityDay.copyWith(id: doc.id));
        } catch (e, stackTrace) {
          print(
            '🔴 [REMOTE_DS] Erro ao processar documento conjunto ${doc.id}: $e $stackTrace',
          );
        }
      }
      return availabilities;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar todas as disponibilidades do conjunto no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        'Erro inesperado ao buscar todas as disponibilidades do conjunto para explorar',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

}

