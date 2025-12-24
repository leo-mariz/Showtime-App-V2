
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
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
abstract class IArtistsRemoteDataSource {

  /// Salva/atualiza dados do artista
  /// Lança [ServerException] em caso de erro
  Future<void> addArtist(String uid, ArtistEntity data);
  
  /// Busca dados do artista
  /// Retorna ArtistEntity vazio se não existir
  /// Lança [ServerException] em caso de erro
  Future<ArtistEntity> getArtist(String uid);

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
      final artistMap = data.toMap();
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

  @override
  Future<ArtistEntity> getArtist(String uid) async {
    try {
      final documentReference = ArtistEntityReference.firebaseUidReference(
        firestore,
        uid,
      );
      final snapshot = await documentReference.get();
      
      if (snapshot.exists) {
        final artistMap = snapshot.data() as Map<String, dynamic>;
        return ArtistEntityMapper.fromMap(artistMap);
      }
      
      return ArtistEntity();
    } on FirebaseException catch (e, stackTrace) {
      throw ServerException(
        'Erro ao buscar dados do artista no Firestore: ${e.message}',
        statusCode: ErrorHandler.getStatusCode(e),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServerException(
        'Erro inesperado ao buscar dados do artista',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}


