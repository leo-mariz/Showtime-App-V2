import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_local_datasource.dart';
import 'package:app/features/profile/artist_availability/data/datasources/availability_remote_datasource.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Availability
/// 
/// REGRA: Este repository combina lógica de cache e remoto
/// - Primeiro busca do cache
/// - Se não encontrado, busca do remoto
/// - Em seguida salva no remoto e no cache
class AvailabilityRepositoryImpl implements IAvailabilityRepository {
  final IAvailabilityRemoteDataSource remoteDataSource;
  final IAvailabilityLocalDataSource localDataSource;

  AvailabilityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, List<AvailabilityEntity>>> getAvailabilities(
    String artistId,
  ) async {
    try {
      // Primeiro tenta buscar do cache
      try {
        final cachedAvailabilities = await localDataSource.getCachedAvailabilities(artistId);
        if (cachedAvailabilities.isNotEmpty) {
          return Right(cachedAvailabilities);
        }
      } catch (e) {
        // Se cache falhar, continua para buscar do remoto
        // Não retorna erro aqui, apenas loga se necessário
      }

      // Se não encontrou no cache, busca do remoto
      final availabilities = await remoteDataSource.getAvailabilities(artistId);
      
      // Salva no cache após buscar do remoto
      if (availabilities.isNotEmpty) {
        await localDataSource.cacheAvailabilities(artistId, availabilities);
      }
      
      return Right(availabilities);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AvailabilityEntity>> getAvailability(
    String artistId,
    String availabilityId,
  ) async {
    try {
      // Busca diretamente do remoto para garantir que temos a disponibilidade mais atualizada
      final availability = await remoteDataSource.getAvailability(artistId, availabilityId);
      
      return Right(availability);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== CREATE OPERATIONS ====================

  @override
  Future<Either<Failure, String>> addAvailability(
    String artistId,
    AvailabilityEntity availability,
  ) async {
    try {
      // Adiciona no remoto e obtém o ID criado
      final availabilityId = await remoteDataSource.addAvailability(artistId, availability);
      
      // Cria disponibilidade atualizada com o ID
      final updatedAvailability = availability.copyWith(id: availabilityId);
      
      // Atualiza cache com disponibilidade atualizada
      await localDataSource.cacheSingleAvailability(artistId, updatedAvailability);
      
      return Right(availabilityId);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> updateAvailability(
    String artistId,
    AvailabilityEntity availability,
  ) async {
    try {
      // Atualiza no remoto
      await remoteDataSource.updateAvailability(artistId, availability);
      
      // Busca lista atualizada do remoto
      final updatedAvailabilities = await remoteDataSource.getAvailabilities(artistId);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAvailabilities(artistId, updatedAvailabilities);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== DELETE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> deleteAvailability(
    String artistId,
    String availabilityId,
  ) async {
    try {
      // Remove do remoto
      await remoteDataSource.deleteAvailability(artistId, availabilityId);
      
      // Busca lista atualizada do remoto
      final updatedAvailabilities = await remoteDataSource.getAvailabilities(artistId);
      
      // Atualiza cache com lista atualizada
      await localDataSource.cacheAvailabilities(artistId, updatedAvailabilities);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  // ==================== REPLACE OPERATIONS ====================

  @override
  Future<Either<Failure, void>> replaceAvailabilities(
    String artistId,
    List<AvailabilityEntity> newAvailabilities,
  ) async {
    try {
      // Substitui todas as disponibilidades usando batch operations
      await remoteDataSource.replaceAvailabilities(artistId, newAvailabilities);
      
      // Atualiza cache com a nova lista
      await localDataSource.cacheAvailabilities(artistId, newAvailabilities);
      
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

