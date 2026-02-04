import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_local_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/data/datasources/ensemble_availability_remote_datasource.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/repositories/ensemble_availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Availability do conjunto
///
/// Orquestra remote e local datasources
/// Aplica estratégia: remote-first com cache local
class EnsembleAvailabilityRepositoryImpl
    implements IEnsembleAvailabilityRepository {
  final IEnsembleAvailabilityRemoteDataSource remoteDataSource;
  final IEnsembleAvailabilityLocalDataSource localDataSource;

  EnsembleAvailabilityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AvailabilityDayEntity>>> getAvailabilities({
    required String ensembleId,
    bool forceRemote = false,
  }) async {
    try {
      // Se não forçar remote, tenta buscar do cache primeiro
      if (!forceRemote) {
        final cachedDays =
            await localDataSource.getAvailabilities(ensembleId);
        if (cachedDays.isNotEmpty) {
          return Right(cachedDays);
        }
      }

      // Buscar do remote
      final remoteDays =
          await remoteDataSource.getAvailabilities(ensembleId);
      for (final day in remoteDays) {
        await localDataSource.cacheAvailability(ensembleId, day);
      }

      return Right(remoteDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AvailabilityDayEntity>> getAvailability({
    required String ensembleId,
    required String dayId,
  }) async {
    try {
      final day = await localDataSource.getAvailability(ensembleId, dayId);
      if (day.documentId == dayId) {
        return Right(day);
      }
      final remoteDay =
          await remoteDataSource.getAvailability(ensembleId, dayId);
      await localDataSource.cacheAvailability(ensembleId, remoteDay);
      return Right(remoteDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AvailabilityDayEntity>> createAvailability({
    required String ensembleId,
    required AvailabilityDayEntity day,
  }) async {
    try {
      final createdDay =
          await remoteDataSource.createAvailability(ensembleId, day);
      await localDataSource.cacheAvailability(ensembleId, createdDay);
      return Right(createdDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AvailabilityDayEntity>> updateAvailability({
    required String ensembleId,
    required AvailabilityDayEntity day,
  }) async {
    try {
      final updatedDay =
          await remoteDataSource.updateAvailability(ensembleId, day);
      await localDataSource.cacheAvailability(ensembleId, updatedDay);
      return Right(updatedDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvailability({
    required String ensembleId,
    required String dayId,
  }) async {
    try {
      await remoteDataSource.deleteAvailability(ensembleId, dayId);
      await localDataSource.removeAvailability(ensembleId, dayId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({required String ensembleId}) async {
    try {
      await localDataSource.clearCache(ensembleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
