import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_local_datasource.dart';
import 'package:app/features/ensemble/ensemble/data/datasources/ensemble_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble/domain/repositories/ensemble_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do repositório de Ensembles.
///
/// Orquestra remote e local. Estratégia: cache-first em get; create/update/delete
/// atualizam remote e em seguida o cache.
class EnsembleRepositoryImpl implements IEnsembleRepository {
  final IEnsembleRemoteDataSource remoteDataSource;
  final IEnsembleLocalDataSource localDataSource;

  EnsembleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<EnsembleEntity>>> getAllByArtist({
    required String artistId,
    bool forceRemote = false,
  }) async {
    try {
      if (!forceRemote) {
        final cached = await localDataSource.getAllByArtist(artistId);
        if (cached.isNotEmpty) return Right(cached);
      }
      final list = await remoteDataSource.getAllByArtist(artistId);
      for (final e in list) {
        await localDataSource.cacheEnsemble(artistId, e);
      }
      return Right(list);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleEntity?>> getById({
    required String artistId,
    required String ensembleId,
  }) async {
    try {
      final cached = await localDataSource.getById(artistId, ensembleId);
      if (cached != null) return Right(cached);
      final entity = await remoteDataSource.getById(artistId, ensembleId);
      if (entity != null) {
        await localDataSource.cacheEnsemble(artistId, entity);
      }
      return Right(entity);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, EnsembleEntity>> create({
    required String artistId,
    required EnsembleEntity ensemble,
  }) async {
    try {
      final created = await remoteDataSource.create(artistId, ensemble);
      await localDataSource.cacheEnsemble(artistId, created);
      return Right(created);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> update({
    required String artistId,
    required EnsembleEntity ensemble,
  }) async {
    try {
      await remoteDataSource.update(artistId, ensemble);
      await localDataSource.cacheEnsemble(artistId, ensemble);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> delete({
    required String artistId,
    required String ensembleId,
  }) async {
    try {
      await remoteDataSource.delete(artistId, ensembleId);
      await localDataSource.removeEnsemble(artistId, ensembleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({required String artistId}) async {
    try {
      await localDataSource.clearCache(artistId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
