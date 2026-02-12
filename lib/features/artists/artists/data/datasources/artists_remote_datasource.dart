
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Interface do DataSource remoto (Firestore)
/// Responsável APENAS por operações CRUD no Firestore
/// 
/// REGRAS:
/// - Lança exceções tipadas (ServerException, NetworkException, etc)
/// - NÃO faz validações de negócio
/// - NÃO faz verificações (use métodos específicos como cpfExists)
abstract class IArtistsRemoteDataSource {
  /// Salva/atualiza dados do artista
  /// Lança [ServerException] em caso de erro
  Future<void> addArtist(String uid, ArtistEntity data);
  
  /// Busca dados do artista
  /// Retorna ArtistEntity vazio se não existir
  /// Lança [ServerException] em caso de erro
  Future<ArtistEntity> getArtist(String uid);
  
  /// Atualiza um artista existente
  /// Lança [ServerException] em caso de erro
  /// Lança [NotFoundException] se o artista não existir
  Future<void> updateArtist(String uid, ArtistEntity artist);
  
  /// Verifica se nome artístico já existe
  /// [excludeUid] - UID do artista a ser excluído da verificação (para permitir atualização do próprio nome)
  /// Lança [ServerException] em caso de erro
  Future<bool> artistNameExists(String artistName, {String? excludeUid});
}

/// Implementação do DataSource remoto usando Firestore
class ArtistsRemoteDataSourceImpl implements IArtistsRemoteDataSource {
  final FirebaseFirestore firestore;

  ArtistsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addArtist(String uid, ArtistEntity data) async {
    try {
      final documentReference = ArtistEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final artistWithUid = data.copyWith(uid: uid);
      final artistMap = artistWithUid.toMap();
      await documentReference.set(artistMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao salvar dados do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao salvar dados do artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Normaliza tipos vindos do Firestore para o formato esperado pelo mapper:
  /// - Timestamp -> millisecondsSinceEpoch (DateTime?)
  /// - rating/rateCount num -> double/int
  static Map<String, dynamic> _normalizeArtistMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);
    if (normalized['dateRegistered'] != null && normalized['dateRegistered'] is Timestamp) {
      normalized['dateRegistered'] = (normalized['dateRegistered'] as Timestamp).millisecondsSinceEpoch;
    }
    if (normalized['rating'] != null && normalized['rating'] is num) {
      normalized['rating'] = (normalized['rating'] as num).toDouble();
    }
    if (normalized['rateCount'] != null && normalized['rateCount'] is num) {
      normalized['rateCount'] = (normalized['rateCount'] as num).toInt();
    }
    return normalized;
  }

  @override
  Future<ArtistEntity> getArtist(String uid) async {
    try {
      if (kDebugMode) {
        debugPrint('📥 [ArtistsRemoteDataSource] getArtist(uid: $uid)');
      }
      final documentReference = ArtistEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final snapshot = await documentReference.get();

      if (snapshot.exists) {
        final rawMap = snapshot.data() as Map<String, dynamic>;
        final artistMap = _normalizeArtistMap(rawMap);
        if (kDebugMode) {
          debugPrint('📥 [ArtistsRemoteDataSource] Documento encontrado, campos: ${artistMap.keys.join(", ")}');
        }
        return ArtistEntityMapper.fromMap(artistMap);
      }

      if (kDebugMode) {
        debugPrint('📥 [ArtistsRemoteDataSource] Documento não existe, retornando entidade vazia');
      }
      return ArtistEntity();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [ArtistsRemoteDataSource] FirebaseException: ${e.code} - ${e.message}');
        debugPrint('🔴 [ArtistsRemoteDataSource] stackTrace: $stackTrace');
      }
      throw ServerException(
        'Erro ao buscar dados do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [ArtistsRemoteDataSource] Erro inesperado ao buscar dados do artista: $e');
        debugPrint('🔴 [ArtistsRemoteDataSource] Tipo do erro: ${e.runtimeType}');
        debugPrint('🔴 [ArtistsRemoteDataSource] stackTrace: $stackTrace');
      }
      throw ServerException(
        'Erro inesperado ao buscar dados do artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateArtist(String uid, ArtistEntity artist) async {
    try {
      if (uid.isEmpty) {
        throw const ValidationException(
          'UID do artista não pode ser vazio',
        );
      }

      final documentReference = ArtistEntityReference.firebaseUidReference(
        firestore,
        uid,
      );

      // Verifica se o documento existe
      final documentSnapshot = await documentReference.get();
      if (!documentSnapshot.exists) {
        throw NotFoundException(
          'Artista não encontrado',
        );
      }

      // Remove o uid do map antes de atualizar (já está no documento)
      final artistMap = artist.toMap();
      artistMap.remove('uid');

      await documentReference.update(artistMap);
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao atualizar artista: ${e.message ?? e.code}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao atualizar artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> artistNameExists(String artistName, {String? excludeUid}) async {
    try {
      final artistsColRef = ArtistEntityReference.firebaseCollectionReference(
        firestore,
      );
      
      // Buscar todos os documentos com o nome artístico
      final querySnapshot = await artistsColRef
          .where('artistName', isEqualTo: artistName)
          .get();
      
      // Se há um UID para excluir, filtrar no código
      if (excludeUid != null && excludeUid.isNotEmpty) {
        final filteredDocs = querySnapshot.docs
            .where((doc) => doc.id != excludeUid)
            .toList();
        return filteredDocs.isNotEmpty;
      }
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao verificar se nome artístico existe: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao verificar nome artístico',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}


