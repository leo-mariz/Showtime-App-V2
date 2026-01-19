// import 'package:app/core/errors/error_handler.dart';
// import 'package:app/core/errors/failure.dart';
// import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
// import 'package:app/features/explore/domain/repositories/explore_repository.dart';
// import 'package:app/features/favorites/domain/usecases/is_artist_favorite_usecase.dart';
// import 'package:dartz/dartz.dart';

// /// UseCase: Buscar todos os artistas com suas disponibilidades para explorar
// /// 
// /// RESPONSABILIDADES:
// /// - Buscar todos os artistas aprovados e ativos do repositório
// /// - Para cada artista, buscar suas disponibilidades
// /// - Combinar artista + disponibilidades em ArtistWithAvailabilitiesEntity
// /// - Retornar lista de artistas com disponibilidades
// /// 
// /// OBSERVAÇÕES:
// /// - Usa cache agressivo (artistas: 1h, disponibilidades: 30min)
// /// - Se artista não tiver disponibilidades, retorna lista vazia
// /// - Continua processando mesmo se algum artista falhar ao buscar disponibilidades
// /// 
// /// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
// class GetArtistsWithAvailabilitiesUseCase {
//   final IExploreRepository repository;
//   final IsArtistFavoriteUseCase isArtistFavoriteUseCase;
  

//   GetArtistsWithAvailabilitiesUseCase({
//     required this.repository,
//     required this.isArtistFavoriteUseCase,
//   });

//   Future<Either<Failure, List<ArtistWithAvailabilitiesEntity>>> call({
//     bool forceRefresh = false,
//     String? userId,
//   }) async {
//     try {
//       // 1. Buscar todos os artistas aprovados e ativos
//       final artistsResult = await repository.getArtistsForExplore(
//         forceRefresh: forceRefresh,
//       );

//       return await artistsResult.fold(
//         (failure) => Left(failure),
//         (artists) async {
//           // 2. Para cada artista, buscar disponibilidades
//           final artistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];

//           // Paralelização com concorrência limitada (batching)
//           const int concurrency = 12; // ajustar conforme necessário/observabilidade
//           for (int i = 0; i < artists.length; i += concurrency) {
//             final batch = artists.skip(i).take(concurrency).toList();

//             final futures = batch.map((artist) async {
//               // Verificar se artista tem UID válido
//               if (artist.uid == null || artist.uid!.isEmpty) {
//                 return ArtistWithAvailabilitiesEntity.empty(artist);
//               }

//               // Buscar disponibilidades do artista
//               final availabilitiesResult = await repository
//                   .getArtistAvailabilitiesForExplore(
//                 artist.uid!,
//                 forceRefresh: forceRefresh,
//               );

//               bool isFavorite = false;
//               if (userId != null && userId.isNotEmpty) {
//                 final isFavoriteResult = await isArtistFavoriteUseCase.call(
//                   clientId: userId,
//                   artistId: artist.uid!,
//                   forceRefresh: forceRefresh,
//                 );
//                 isFavorite = isFavoriteResult.fold(
//                   (_) => false, // Em caso de erro, considerar como não favorito
//                   (fav) => fav,
//                 );
//               }

//               return availabilitiesResult.fold(
//                 (_) => ArtistWithAvailabilitiesEntity.empty(artist),
//                 (availabilities) => ArtistWithAvailabilitiesEntity(
//                   artist: artist,
//                   availabilities: availabilities,
//                   isFavorite: isFavorite,
//                 ),
//               );
//             }).toList();

//             final batchResults = await Future.wait(futures);
//             artistsWithAvailabilities.addAll(batchResults);
//           }

//           return Right(artistsWithAvailabilities);
//         },
//       );
//     } catch (e) {
//       return Left(ErrorHandler.handle(e));
//     }
//   }
// }

