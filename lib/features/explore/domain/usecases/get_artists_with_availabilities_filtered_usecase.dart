import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/distance_helper.dart';
import 'package:app/core/utils/geohash_helper.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/favorites/domain/usecases/is_artist_favorite_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar artistas com disponibilidades filtradas por data e localização
/// 
/// RESPONSABILIDADES:
/// - Buscar todos os artistas aprovados e ativos
/// - Para cada artista, buscar apenas a disponibilidade do dia específico (se fornecido)
/// - Aplicar filtros em memória (geohash, distância, busca)
/// - Combinar artista + disponibilidade do dia em ArtistWithAvailabilitiesEntity
/// - Retornar apenas artistas que têm disponibilidade válida para o dia
/// 
/// FILTROS APLICADOS (todos em memória):
/// 1. Data: Busca apenas a disponibilidade do dia específico (otimizado no Firestore)
/// 2. Geohash: Filtra disponibilidades com geohash dentro do range do usuário
/// 3. Distância: Filtra usando Haversine (distância <= raioAtuacao)
/// 4. Busca: Filtra por nome, talentos (specialty) e bio (quando searchQuery fornecida)
/// 
/// OBSERVAÇÕES:
/// - Busca apenas o dia específico do Firestore (1 read por artista)
/// - Cache de 2 horas para artistas e disponibilidades
/// - Filtragem em memória = 0 reads do Firestore ao mudar filtros
/// - Se artista não tiver disponibilidade válida, não é incluído no resultado
/// 
/// [selectedDate]: Data selecionada para filtrar disponibilidades (obrigatório para buscar disponibilidade)
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
class PagedArtistsResult {
  final List<ArtistWithAvailabilitiesEntity> items;
  final int nextIndex;
  final bool hasMore;

  PagedArtistsResult({
    required this.items,
    required this.nextIndex,
    required this.hasMore,
  });
}

class GetArtistsWithAvailabilitiesFilteredUseCase {
  final IExploreRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;
  final IsArtistFavoriteUseCase isArtistFavoriteUseCase;

  GetArtistsWithAvailabilitiesFilteredUseCase({
    required this.repository,
    required this.calculateAddressGeohashUseCase,
    required this.isArtistFavoriteUseCase,
  });

  Future<Either<Failure, PagedArtistsResult>> call({
    DateTime? selectedDate,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
    int startIndex = 0,
    int pageSize = 10,
    String? userId,
    String? searchQuery,
  }) async {
    print('🟣 [USECASE] GetArtistsWithAvailabilitiesFiltered - Iniciando busca');
    print('🟣 [USECASE] Parâmetros:');
    print('   - selectedDate: $selectedDate');
    print('   - userAddress: ${userAddress?.title ?? "Nenhum"}');
    print('   - userAddress lat/lon: ${userAddress?.latitude}/${userAddress?.longitude}');
    print('   - forceRefresh: $forceRefresh');
    print('   - startIndex: $startIndex');
    print('   - pageSize: $pageSize');
    print('   - searchQuery: ${searchQuery ?? "Nenhuma"}');
    
    try {
      // Validar que selectedDate foi fornecido
      if (selectedDate == null) {
        return const Left(
          ValidationFailure('Data selecionada é obrigatória para buscar disponibilidades'),
        );
      }

      // 1. Calcular range de geohash do endereço do usuário (se fornecido)
      String? minGeohash;
      String? maxGeohash;
      
      if (userAddress != null &&
          userAddress.latitude != null &&
          userAddress.longitude != null) {
        print('🟣 [USECASE] Calculando geohash para endereço: ${userAddress.title}');
        final geohashResult = await calculateAddressGeohashUseCase.call(userAddress);
        geohashResult.fold(
          (failure) {
            print('🔴 [USECASE] Erro ao calcular geohash: ${failure.message}');
          },
          (geohash) {
            print('🟣 [USECASE] Geohash calculado: $geohash');
            // Calcular range de geohash para filtro
            final range = GeohashHelper.getRange(geohash);
            minGeohash = range['min'];
            maxGeohash = range['max'];
            print('🟣 [USECASE] Range de geohash: min=$minGeohash, max=$maxGeohash');
          },
        );
      } else {
        print('🟣 [USECASE] Sem endereço ou coordenadas, não calculando geohash');
      }

      // 2. Buscar todos os artistas aprovados e ativos (usa cache)
      print('🟣 [USECASE] Buscando todos os artistas aprovados e ativos...');
      final artistsResult = await repository.getArtistsForExplore(
        forceRefresh: forceRefresh,
      );

      return await artistsResult.fold(
        (failure) {
          print('🔴 [USECASE] Erro ao buscar artistas: ${failure.message}');
          return Left(failure);
        },
        (artists) async {
          print('🟣 [USECASE] Total de artistas encontrados: ${artists.length}');
          
          // 3. Para cada artista, buscar disponibilidade do dia específico e aplicar filtros
          // Usando paralelização com batching controlado para otimizar performance
          final filteredArtistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];
          int artistsProcessed = 0;
          int artistsWithValidAvailabilities = 0;

          // Garantir limites válidos
          final safeStartIndex = startIndex.clamp(0, artists.length);
          final int maxToCollect = pageSize <= 0 ? 10 : pageSize;

          // Paralelização com concorrência limitada (batching)
          // Processa em lotes para não sobrecarregar o Firestore
          const int concurrency = 10; // Ajustar conforme necessário/observabilidade
          int i = safeStartIndex;
          
          while (i < artists.length &&
                 filteredArtistsWithAvailabilities.length < maxToCollect) {
            // Processar um lote de artistas em paralelo
            final batchSize = (maxToCollect - filteredArtistsWithAvailabilities.length).clamp(1, concurrency);
            final remainingArtists = artists.length - i;
            final currentBatchSize = batchSize < remainingArtists ? batchSize : remainingArtists;
            
            final batch = artists.skip(i).take(currentBatchSize).toList();
            
            print('🟣 [USECASE] Processando lote de ${batch.length} artistas (índice $i a ${i + batch.length - 1})');
            
            // Processar lote em paralelo
            final futures = batch.map((artist) async {
              artistsProcessed++;
              
              print('🟣 [USECASE] Processando artista: ${artist.artistName} (ID: ${artist.uid})');
              
              // Verificar se artista tem UID válido
              if (artist.uid == null || artist.uid!.isEmpty) {
                print('🟡 [USECASE] Artista ${artist.artistName} sem UID válido, pulando...');
                return null;
              }

              // Buscar disponibilidade do dia específico (paralelizado)
              final availabilityDayResult = await repository.getArtistAvailabilityDayForExplore(
                artist.uid!,
                selectedDate,
                forceRefresh: forceRefresh,
              );

              final availabilityDay = availabilityDayResult.fold(
                (_) => null,
                (day) => day,
              );

              // Se não houver disponibilidade para o dia, retornar null
              if (availabilityDay == null || !availabilityDay.hasAvailability) {
                print('🟡 [USECASE] Artista ${artist.uid} - SEM disponibilidade para o dia $selectedDate');
                return null;
              }

              // Verificar se a disponibilidade está ativa
              if (!availabilityDay.isActive) {
                print('🟡 [USECASE] Artista ${artist.uid} - Disponibilidade INATIVA para o dia $selectedDate');
                return null;
              }

              // Verificar se há pelo menos um slot com status available
              // Slots com status booked não devem ser considerados
              final hasAvailableSlot = availabilityDay.slots?.any(
                (slot) => slot.status == TimeSlotStatusEnum.available,
              ) ?? false;

              if (!hasAvailableSlot) {
                print('🟡 [USECASE] Artista ${artist.uid} - Nenhum slot DISPONÍVEL (todos estão booked) para o dia $selectedDate');
                return null;
              }

              print('🟣 [USECASE] Artista ${artist.uid} - Tem disponibilidade ATIVA com slots DISPONÍVEIS para o dia');

              // Aplicar filtros em memória
              bool isValid = true;

              // Filtro 1: Por geohash (range)
              if (minGeohash != null && maxGeohash != null && availabilityDay.endereco != null) {
                final availabilityGeohash = availabilityDay.endereco!.geohash;
                
                if (availabilityGeohash == null || availabilityGeohash.isEmpty) {
                  print('🟡 [USECASE] Artista ${artist.uid} - Disponibilidade sem geohash, REJEITADO');
                  isValid = false;
                } else {
                  // Truncar ambos os geohashes para a mesma precisão para comparação correta
                  final truncatedAvailabilityGeohash = GeohashHelper.truncate(availabilityGeohash, minGeohash!.length);
                  final truncatedMinGeohash = GeohashHelper.truncate(minGeohash!, minGeohash!.length);
                  final truncatedMaxGeohash = GeohashHelper.truncate(maxGeohash!, maxGeohash!.length);
                  
                  final isInRange = truncatedAvailabilityGeohash.compareTo(truncatedMinGeohash) >= 0 &&
                                    truncatedAvailabilityGeohash.compareTo(truncatedMaxGeohash) <= 0;
                  
                  if (!isInRange) {
                    print('🟡 [USECASE] Artista ${artist.uid} - Geohash FORA do range');
                    isValid = false;
                  }
                }
              }

              // Filtro 2: Por distância Haversine (raio de atuação)
              if (isValid && userAddress != null &&
                  userAddress.latitude != null &&
                  userAddress.longitude != null &&
                  availabilityDay.endereco != null &&
                  availabilityDay.endereco!.latitude != null &&
                  availabilityDay.endereco!.longitude != null &&
                  availabilityDay.raioAtuacao != null) {
                
                final distance = DistanceHelper.calculateHaversineDistance(
                  userAddress.latitude!,
                  userAddress.longitude!,
                  availabilityDay.endereco!.latitude!,
                  availabilityDay.endereco!.longitude!,
                );
                
                final isWithinRadius = distance <= availabilityDay.raioAtuacao!;
                
                if (!isWithinRadius) {
                  print('🟡 [USECASE] Artista ${artist.uid} - FORA do raio: distância=${distance.toStringAsFixed(2)}km, raio=${availabilityDay.raioAtuacao}km');
                  isValid = false;
                }
              }

              // Filtro 3: Por busca (nome, talentos, bio)
              if (isValid && searchQuery != null && searchQuery.isNotEmpty) {
                if (!_matchesSearch(artist, searchQuery)) {
                  print('🟡 [USECASE] Artista ${artist.uid} - REMOVIDO (não corresponde à busca)');
                  isValid = false;
                }
              }

              // Se passou em todos os filtros, retornar o artista com disponibilidade
              if (isValid) {
                // Verificar se é favorito (paralelizado)
                bool isFavorite = false;
                if (userId != null && userId.isNotEmpty) {
                  final isFavoriteResult = await isArtistFavoriteUseCase.call(
                    clientId: userId,
                    artistId: artist.uid!,
                    forceRefresh: forceRefresh,
                  );
                  isFavorite = isFavoriteResult.fold(
                    (_) => false,
                    (fav) => fav,
                  );
                }

                final artistWithAvailability = ArtistWithAvailabilitiesEntity(
                  artist: artist,
                  availabilities: [availabilityDay],
                  isFavorite: isFavorite,
                );
                
                artistsWithValidAvailabilities++;
                print('🟢 [USECASE] Artista ${artist.uid} - ADICIONADO com disponibilidade válida');
                return artistWithAvailability;
              }
              
              return null;
            }).toList();

            // Aguardar todos os resultados do lote
            final batchResults = await Future.wait(futures);
            
            // Adicionar apenas os resultados válidos (não null)
            for (final result in batchResults) {
              if (result != null) {
                filteredArtistsWithAvailabilities.add(result);
                
                // Se já coletamos o suficiente, parar
                if (filteredArtistsWithAvailabilities.length >= maxToCollect) {
                  break;
                }
              }
            }
            
            // Avançar para o próximo lote
            i += batch.length;
            
            // Se já coletamos o suficiente, parar
            if (filteredArtistsWithAvailabilities.length >= maxToCollect) {
              break;
            }
          }

          final hasMore = i < artists.length;
          final nextIndex = i;
          print('🟢 [USECASE] Paginação: retornados=${filteredArtistsWithAvailabilities.length}, nextIndex=$nextIndex, hasMore=$hasMore');

          print('🟢 [USECASE] Processamento concluído!');
          print('🟢 [USECASE] Estatísticas:');
          print('   - Artistas processados: $artistsProcessed');
          print('   - Artistas com disponibilidades válidas: $artistsWithValidAvailabilities');
          print('   - Total retornado: ${filteredArtistsWithAvailabilities.length}');
          print('   - ✅ Busca otimizada: apenas 1 read por artista (dia específico)');

          return Right(PagedArtistsResult(
            items: filteredArtistsWithAvailabilities,
            nextIndex: nextIndex,
            hasMore: hasMore,
          ));
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Verifica se um artista corresponde à query de busca
  /// 
  /// Busca case-insensitive em:
  /// - Nome do artista (artistName)
  /// - Talentos (professionalInfo.specialty)
  /// - Bio (professionalInfo.bio)
  /// 
  /// Retorna true se o artista corresponde à busca, false caso contrário
  bool _matchesSearch(ArtistEntity artist, String searchQuery) {
    if (searchQuery.isEmpty) {
      return true; // Sem busca, aceita todos
    }

    final lowerQuery = searchQuery.trim().toLowerCase();

    // Buscar no nome do artista
    final artistName = (artist.artistName ?? '').toLowerCase();
    if (artistName.contains(lowerQuery)) {
      return true;
    }

    // Buscar nos talentos (specialty)
    final specialty = artist.professionalInfo?.specialty ?? [];
    final hasMatchingSpecialty = specialty.any(
      (talent) => talent.toLowerCase().contains(lowerQuery),
    );
    if (hasMatchingSpecialty) {
      return true;
    }

    // Buscar na bio
    final bio = (artist.professionalInfo?.bio ?? '').toLowerCase();
    if (bio.contains(lowerQuery)) {
      return true;
    }

    return false;
  }
}
