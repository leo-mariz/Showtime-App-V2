import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Interface do Repository de Autenticação
/// 
/// Define operações básicas de dados sem lógica de negócio.
/// A lógica de negócio fica nos UseCases.
/// 
/// ORGANIZAÇÃO:
/// - Get: Buscar dados
/// - Set: Salvar dados
/// - Verification: Verificar existência
/// - Cache: Operações de cache
abstract class IArtistsRepository {
  // ==================== GET OPERATIONS ====================

  /// Busca dados do artista no Firestore e salva no cache
  Future<Either<Failure, ArtistEntity>> getArtist(String uid);
  
  // ==================== ADD OPERATIONS ====================
  
  /// Salva dados do artista no Firestore e cache
  Future<Either<Failure, void>> addArtist(String uid, ArtistEntity artist);

  // ==================== UPDATE OPERATIONS ====================
  
  /// Atualiza um artista existente
  Future<Either<Failure, void>> updateArtist(String uid, ArtistEntity artist);

  // ==================== VERIFICATION OPERATIONS ====================
  
  /// Verifica se nome artístico já existe
  /// [excludeUid] - UID do artista a ser excluído da verificação
  Future<Either<Failure, bool>> artistNameExists(String artistName, {String? excludeUid});
}
