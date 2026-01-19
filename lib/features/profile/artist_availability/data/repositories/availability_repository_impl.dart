import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_local_datasource.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_remote_datasource.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Availability
/// 
/// Orquestra remote e local datasources
/// Aplica estratégia: remote-first com cache local
class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  final IAvailabilityRemoteDataSource remoteDataSource;
  final IAvailabilityLocalDataSource localDataSource;
  
  AvailabilityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, List<AvailabilityDayEntity>>> getAvailability({
    required String artistId,
    bool forceRemote = false,
  }) async {
    try {
      // Se não forçar remote, tenta buscar do cache primeiro
      if (!forceRemote) {
        final cachedDays = await localDataSource.getAvailability(artistId);
        if (cachedDays.isNotEmpty) {
          return Right(cachedDays);
        }
      }
      
      // Buscar do remote
      final remoteDays = await remoteDataSource.getAvailability(artistId);
      
      // Cachear todos os dias
      for (final day in remoteDays) {
        await localDataSource.cacheAvailability(artistId, day);
      }
      
      return Right(remoteDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
  
  @override
  Future<Either<Failure, AvailabilityDayEntity>> createAvailability({
    required String artistId,
    required AvailabilityDayEntity day,
  }) async {
    try {
      // Criar no remote
      final createdDay = await remoteDataSource.createAvailability(artistId, day);
      
      // Cachear
      await localDataSource.cacheAvailability(artistId, createdDay);
      
      return Right(createdDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
  
  @override
  Future<Either<Failure, AvailabilityDayEntity>> updateAvailability({
    required String artistId,
    required AvailabilityDayEntity day,
  }) async {
    try {
      // Atualizar no remote
      final updatedDay = await remoteDataSource.updateAvailability(artistId, day);
      
      // Atualizar cache
      await localDataSource.cacheAvailability(artistId, updatedDay);
      
      return Right(updatedDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteAvailability({
    required String artistId,
    required String dayId,
  }) async {
    try {
      // Deletar do remote
      await remoteDataSource.deleteAvailability(artistId, dayId);
      
      // Remover do cache
      await localDataSource.removeAvailability(artistId, dayId);
      
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
