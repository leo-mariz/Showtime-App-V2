import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/explore/data/datasources/explore_local_datasource.dart';
import 'package:app/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementação do Repository de Explore
/// 
/// RESPONSABILIDADES:
/// - Coordenar chamadas entre DataSources (Local e Remote)
/// - Gerenciar cache agressivo para artistas (2 horas de validade)
/// - Gerenciar cache agressivo para disponibilidades por dia (2 horas de validade)
/// - Converter exceções em Failures usando ErrorHandler
/// - NÃO faz validações de negócio (isso é responsabilidade dos UseCases)
/// 
/// REGRA: Feature completamente independente.
/// Não reutiliza repositories ou datasources de outras features.
/// Usa apenas explore remote datasource para buscar dados do Firestore.
class ExploreRepositoryImpl implements IExploreRepository {
  final IExploreRemoteDataSource exploreRemoteDataSource;
  final IExploreLocalDataSource exploreLocalDataSource;

  ExploreRepositoryImpl({
    required this.exploreRemoteDataSource,
    required this.exploreLocalDataSource,
  });

  // ==================== GET OPERATIONS ====================

  @override
  Future<Either<Failure, List<ArtistEntity>>> getArtistsForExplore({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
      if (!forceRefresh) {
        // Verificar se cache é válido
        if (await exploreLocalDataSource.isArtistsCacheValid()) {
          final cachedArtists = await exploreLocalDataSource.getCachedArtists();
          if (cachedArtists != null && cachedArtists.isNotEmpty) {
            // Cache válido, retornar do cache (0 reads do Firestore)
            return Right(cachedArtists);
          }
        }
      }

      // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore
      final artists = await exploreRemoteDataSource.getActiveApprovedArtists();
      
      // 3. Salvar no cache com timestamp
      await exploreLocalDataSource.cacheArtists(artists);
      
      return Right(artists);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, AvailabilityDayEntity?>> getArtistAvailabilityDayForExplore(
    String artistId,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(
          ValidationFailure('ID do artista não pode ser vazio'),
        );
      }

      // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
      if (!forceRefresh) {
        // Verificar se cache de explore é válido (2 horas)
        if (await exploreLocalDataSource.isAvailabilityDayCacheValid(artistId, date)) {
          final cachedAvailabilityDay = await exploreLocalDataSource
              .getCachedAvailabilityDay(artistId, date);
          // Retornar do cache (pode ser null se não houver disponibilidade)
          // null no cache significa que já verificamos e não há disponibilidade
          return Right(cachedAvailabilityDay);
        }
      }

      // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore
      final availabilityDay = await exploreRemoteDataSource.getArtistAvailabilityDay(
        artistId,
        date,
      );
      
      // 3. Salvar no cache de explore com timestamp (2 horas)
      // Salvar null também para indicar que não há disponibilidade
      await exploreLocalDataSource.cacheAvailabilityDay(
        artistId,
        date,
        availabilityDay,
      );
      
      return Right(availabilityDay);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<AvailabilityDayEntity>>> getArtistAllAvailabilitiesForExplore(
    String artistId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(
          ValidationFailure('ID do artista não pode ser vazio'),
        );
      }

      // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
      if (!forceRefresh) {
        // Verificar se índice de disponibilidades é válido
        if (await exploreLocalDataSource.isAllAvailabilitiesCacheValid(artistId)) {
          // Índice válido, tentar buscar do cache por dia
          final cachedDays = await exploreLocalDataSource.getCachedAllAvailabilities(artistId);
          
          if (cachedDays != null && cachedDays.isNotEmpty) {
            // Buscar cada dia do cache individual
            final availabilities = <AvailabilityDayEntity>[];
            final missingDays = <DateTime>[];
            
            for (final day in cachedDays) {
              // Verificar se cache do dia específico é válido
              if (await exploreLocalDataSource.isAvailabilityDayCacheValid(artistId, day)) {
                final cachedDay = await exploreLocalDataSource.getCachedAvailabilityDay(
                  artistId,
                  day,
                );
                
                // Se encontrou no cache e não é null, adicionar
                if (cachedDay != null) {
                  availabilities.add(cachedDay);
                }
                // Se cachedDay é null, significa que não há disponibilidade para aquele dia
                // Não adicionamos à lista, mas também não precisamos buscar do remote
              } else {
                // Cache do dia expirado ou não existe, precisa buscar
                missingDays.add(day);
              }
            }
            
            // Se todos os dias estavam no cache, retornar
            if (missingDays.isEmpty) {
              // Ordenar por data antes de retornar
              availabilities.sort((a, b) => a.date.compareTo(b.date));
              return Right(availabilities);
            }
            
            // Se há dias faltantes, buscar apenas eles do remote
            // Porém, como o remote não tem método para buscar dias específicos,
            // vamos buscar tudo do remote e atualizar o cache completo
            // (Isso garante que temos dados atualizados)
          } else if (cachedDays != null && cachedDays.isEmpty) {
            // Índice existe mas está vazio (artista sem disponibilidades)
            return const Right([]);
          }
          // Se cachedDays é null, índice não existe, continuar para buscar do remote
        }
      }

      // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore
      final availabilities = await exploreRemoteDataSource.getArtistAllAvailabilities(
        artistId,
      );
      
      // 3. Popular cache por dia para cada disponibilidade retornada
      final daysList = <DateTime>[];
      for (final availability in availabilities) {
        // Salvar no cache por dia
        await exploreLocalDataSource.cacheAvailabilityDay(
          artistId,
          availability.date,
          availability,
        );
        // Adicionar à lista de dias
        daysList.add(availability.date);
      }
      
      // 4. Atualizar índice com lista de dias
      await exploreLocalDataSource.cacheAllAvailabilities(artistId, daysList);
      
      // 5. Ordenar por data antes de retornar
      availabilities.sort((a, b) => a.date.compareTo(b.date));
      
      return Right(availabilities);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

