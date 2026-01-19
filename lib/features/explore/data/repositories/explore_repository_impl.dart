// import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
// import 'package:app/core/domain/artist/availability/availability_entity.dart';
// import 'package:app/core/errors/error_handler.dart';
// import 'package:app/core/errors/failure.dart';
// import 'package:app/core/utils/geohash_helper.dart';
// import 'package:app/features/explore/data/datasources/explore_local_datasource.dart';
// import 'package:app/features/explore/data/datasources/explore_remote_datasource.dart';
// import 'package:app/features/explore/domain/repositories/explore_repository.dart';
// import 'package:dartz/dartz.dart';

// /// Implementação do Repository de Explore
// /// 
// /// RESPONSABILIDADES:
// /// - Coordenar chamadas entre DataSources (Local e Remote)
// /// - Gerenciar cache agressivo para artistas (1 hora de validade)
// /// - Gerenciar cache agressivo para disponibilidades (30 minutos de validade)
// /// - Converter exceções em Failures usando ErrorHandler
// /// - NÃO faz validações de negócio (isso é responsabilidade dos UseCases)
// /// 
// /// REGRA: Feature completamente independente.
// /// Não reutiliza repositories ou datasources de outras features.
// /// Usa apenas explore remote datasource para buscar dados do Firestore.
// class ExploreRepositoryImpl implements IExploreRepository {
//   final IExploreRemoteDataSource exploreRemoteDataSource;
//   final IExploreLocalDataSource exploreLocalDataSource;

//   ExploreRepositoryImpl({
//     required this.exploreRemoteDataSource,
//     required this.exploreLocalDataSource,
//   });

//   // ==================== GET OPERATIONS ====================

//   @override
//   Future<Either<Failure, List<ArtistEntity>>> getArtistsForExplore({
//     bool forceRefresh = false,
//   }) async {
//     try {
//       // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
//       if (!forceRefresh) {
//         // Verificar se cache é válido
//         if (await exploreLocalDataSource.isArtistsCacheValid()) {
//           final cachedArtists = await exploreLocalDataSource.getCachedArtists();
//           if (cachedArtists != null && cachedArtists.isNotEmpty) {
//             // Cache válido, retornar do cache (0 reads do Firestore)
//             return Right(cachedArtists);
//           }
//         }
//       }

//       // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore
//       final artists = await exploreRemoteDataSource.getActiveApprovedArtists();
      
//       // 3. Salvar no cache com timestamp
//       await exploreLocalDataSource.cacheArtists(artists);
      
//       return Right(artists);
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }

//   @override
//   Future<Either<Failure, List<AvailabilityEntity>>> getArtistAvailabilitiesForExplore(
//     String artistId, {
//     bool forceRefresh = false,
//   }) async {
//     try {
//       if (artistId.isEmpty) {
//         return const Left(
//           ValidationFailure('ID do artista não pode ser vazio'),
//         );
//       }

//       // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
//       if (!forceRefresh) {
//         // Verificar se cache de explore é válido (30 minutos)
//         if (await exploreLocalDataSource.isAvailabilitiesCacheValid(artistId)) {
//           final cachedAvailabilities = await exploreLocalDataSource
//               .getCachedAvailabilities(artistId);
//           if (cachedAvailabilities != null) {
//             // Cache válido, retornar do cache (0 reads do Firestore)
//             return Right(cachedAvailabilities);
//           }
//         }
//       }

//       // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore via explore remote datasource
//       final availabilities = await exploreRemoteDataSource.getArtistAvailabilities(artistId);
      
//       // 3. Salvar no cache de explore com timestamp (30 minutos)
//       await exploreLocalDataSource.cacheAvailabilities(artistId, availabilities);
      
//       return Right(availabilities);
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }

//   @override
//   Future<Either<Failure, List<AvailabilityEntity>>> getArtistAvailabilitiesFilteredForExplore(
//     String artistId, {
//     DateTime? selectedDate,
//     String? userGeohash,
//     bool forceRefresh = false,
//   }) async {
//     try {
//       if (artistId.isEmpty) {
//         return const Left(
//           ValidationFailure('ID do artista não pode ser vazio'),
//         );
//       }

//       // Calcular range de geohash se fornecido
//       String? minGeohash;
//       String? maxGeohash;
//       if (userGeohash != null && userGeohash.isNotEmpty) {
//         print('🔶 [REPOSITORY] Calculando range de geohash para: $userGeohash');
//         final range = GeohashHelper.getRange(userGeohash);
//         minGeohash = range['min'];
//         maxGeohash = range['max'];
//         print('🔶 [REPOSITORY] Range calculado:');
//         print('   - minGeohash: $minGeohash');
//         print('   - maxGeohash: $maxGeohash');
//         print('   - geohash do usuário ($userGeohash) está no range? ${userGeohash.compareTo(minGeohash!) >= 0 && userGeohash.compareTo(maxGeohash!) <= 0}');
//       }

//       // 1. Se forceRefresh for true, ignorar cache e buscar diretamente do Firestore
//       if (!forceRefresh) {
//         // Verificar se cache filtrado é válido (2 horas)
//         if (await exploreLocalDataSource.isFilteredAvailabilitiesCacheValid(
//           artistId,
//           selectedDate: selectedDate,
//           userGeohash: userGeohash,
//         )) {
//           final cachedAvailabilities = await exploreLocalDataSource
//               .getCachedFilteredAvailabilities(
//             artistId,
//             selectedDate: selectedDate,
//             userGeohash: userGeohash,
//           );
//           if (cachedAvailabilities != null) {
//             // Cache válido, retornar do cache (0 reads do Firestore)
//             return Right(cachedAvailabilities);
//           }
//         }
//       }

//       // 2. Cache inválido, não existe ou forceRefresh = true, buscar do Firestore com filtros
//       final availabilities = await exploreRemoteDataSource.getArtistAvailabilitiesFiltered(
//         artistId,
//         selectedDate: selectedDate,
//         minGeohash: minGeohash,
//         maxGeohash: maxGeohash,
//       );
      
//       // 3. Salvar no cache filtrado com timestamp (2 horas)
//       await exploreLocalDataSource.cacheFilteredAvailabilities(
//         artistId,
//         availabilities,
//         selectedDate: selectedDate,
//         userGeohash: userGeohash,
//       );
      
//       return Right(availabilities);
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }
// }

