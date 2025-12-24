import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artists/data/datasources/artists_local_datasource.dart';
import 'package:app/features/profile/artists/data/datasources/artists_remote_datasource.dart';
import 'package:app/features/profile/artists/domain/repositories/artists_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Autenticação
/// 
/// RESPONSABILIDADES:
/// - Coordenar chamadas entre DataSources (Local e Remote)
/// - Converter exceções em Failures usando ErrorHandler
/// - NÃO faz validações de negócio (isso é responsabilidade dos UseCases)
/// 
/// REGRA: Este repository é SIMPLES e GENÉRICO
class ArtistsRepositoryImpl implements IArtistsRepository {
  final IArtistsRemoteDataSource remoteDataSource;
  final IArtistsLocalDataSource localDataSource;

  ArtistsRepositoryImpl({
    required this.remoteDataSource,
      required this.localDataSource,
    });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, ArtistEntity>> getArtist(String uid) async {
    try {
      final artist = await remoteDataSource.getArtist(uid);
      if (artist != ArtistEntity()) {
          await localDataSource.cacheArtist(artist);
      }
      return Right(artist);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
      }
  }

  // ==================== ADD OPERATIONS ====================

  @override
  Future<Either<Failure, void>> addArtist(
    String uid,
    ArtistEntity artist,
  ) async {
    try {
      await remoteDataSource.addArtist(uid, artist);
      await localDataSource.cacheArtist(artist);
      return const Right(null);
      } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

}
