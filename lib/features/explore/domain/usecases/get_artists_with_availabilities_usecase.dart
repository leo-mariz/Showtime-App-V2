import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar todos os artistas com suas disponibilidades para explorar
/// 
/// RESPONSABILIDADES:
/// - Buscar todos os artistas aprovados e ativos do repositório
/// - Para cada artista, buscar suas disponibilidades
/// - Combinar artista + disponibilidades em ArtistWithAvailabilitiesEntity
/// - Retornar lista de artistas com disponibilidades
/// 
/// OBSERVAÇÕES:
/// - Usa cache agressivo (artistas: 1h, disponibilidades: 30min)
/// - Se artista não tiver disponibilidades, retorna lista vazia
/// - Continua processando mesmo se algum artista falhar ao buscar disponibilidades
/// 
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
class GetArtistsWithAvailabilitiesUseCase {
  final IExploreRepository repository;

  GetArtistsWithAvailabilitiesUseCase({
    required this.repository,
  });

  Future<Either<Failure, List<ArtistWithAvailabilitiesEntity>>> call({
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Buscar todos os artistas aprovados e ativos
      final artistsResult = await repository.getArtistsForExplore(
        forceRefresh: forceRefresh,
      );

      return await artistsResult.fold(
        (failure) => Left(failure),
        (artists) async {
          // 2. Para cada artista, buscar disponibilidades
          final artistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];

          for (final artist in artists) {
            // Verificar se artista tem UID válido
            if (artist.uid == null || artist.uid!.isEmpty) {
              // Artista sem UID, criar com disponibilidades vazias
              artistsWithAvailabilities.add(
                ArtistWithAvailabilitiesEntity.empty(artist),
              );
              continue;
            }

            // Buscar disponibilidades do artista
            final availabilitiesResult = await repository
                .getArtistAvailabilitiesForExplore(
              artist.uid!,
              forceRefresh: forceRefresh,
            );

            availabilitiesResult.fold(
              (failure) {
                // Se falhar ao buscar disponibilidades, adicionar artista sem disponibilidades
                // Não interrompe o processo para outros artistas
                artistsWithAvailabilities.add(
                  ArtistWithAvailabilitiesEntity.empty(artist),
                );
              },
              (availabilities) {
                // Sucesso ao buscar disponibilidades
                artistsWithAvailabilities.add(
                  ArtistWithAvailabilitiesEntity(
                    artist: artist,
                    availabilities: availabilities,
                  ),
                );
              },
            );
          }

          return Right(artistsWithAvailabilities);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}

