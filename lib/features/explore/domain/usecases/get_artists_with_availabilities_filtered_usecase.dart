import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/distance_helper.dart';
import 'package:app/core/utils/geohash_helper.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/usecases/get_artists_with_availabilities_usecase.dart';
import 'package:app/features/explore/domain/usecases/is_availability_valid_for_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar artistas com disponibilidades filtradas por data e localização
/// 
/// RESPONSABILIDADES:
/// - Buscar todos os artistas com todas as disponibilidades usando GetArtistsWithAvailabilitiesUseCase
/// - Aplicar filtros em memória (geohash, data, distância)
/// - Combinar artista + disponibilidades filtradas em ArtistWithAvailabilitiesEntity
/// - Retornar apenas artistas que têm pelo menos uma disponibilidade válida
/// 
/// FILTROS APLICADOS (todos em memória):
/// 1. Geohash: Filtra disponibilidades com geohash dentro do range do usuário
/// 2. Data: Valida range, dia da semana e horários bloqueados
/// 3. Distância: Filtra usando Haversine (distância <= raioAtuacao)
/// 
/// OBSERVAÇÕES:
/// - Usa GetArtistsWithAvailabilitiesUseCase como fonte de dados (cache de 2h)
/// - Filtragem em memória = 0 reads do Firestore ao mudar filtros
/// - Se artista não tiver disponibilidades válidas, não é incluído no resultado
/// - Muito mais eficiente: primeira busca = 100 reads, mudanças de filtro = 0 reads
/// 
/// [selectedDate]: Data selecionada para filtrar disponibilidades (opcional)
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
  final GetArtistsWithAvailabilitiesUseCase getArtistsWithAvailabilitiesUseCase;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;
  final IsAvailabilityValidForDateUseCase isAvailabilityValidForDateUseCase;

  GetArtistsWithAvailabilitiesFilteredUseCase({
    required this.getArtistsWithAvailabilitiesUseCase,
    required this.calculateAddressGeohashUseCase,
    required this.isAvailabilityValidForDateUseCase,
  });

  Future<Either<Failure, PagedArtistsResult>> call({
    DateTime? selectedDate,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
    int startIndex = 0,
    int pageSize = 10,
  }) async {
    print('🟣 [USECASE] GetArtistsWithAvailabilitiesFiltered - Iniciando busca');
    print('🟣 [USECASE] Parâmetros:');
    print('   - selectedDate: $selectedDate');
    print('   - userAddress: ${userAddress?.title ?? "Nenhum"}');
    print('   - userAddress lat/lon: ${userAddress?.latitude}/${userAddress?.longitude}');
    print('   - forceRefresh: $forceRefresh');
    print('   - startIndex: $startIndex');
    print('   - pageSize: $pageSize');
    
    try {
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

      // 2. Buscar todos os artistas com todas as disponibilidades (usa cache)
      print('🟣 [USECASE] Buscando todos os artistas com disponibilidades...');
      final allArtistsResult = await getArtistsWithAvailabilitiesUseCase.call(
        forceRefresh: forceRefresh,
      );

      return allArtistsResult.fold(
        (failure) {
          print('🔴 [USECASE] Erro ao buscar artistas: ${failure.message}');
          return Left(failure);
        },
        (allArtistsWithAvailabilities) {
          print('🟣 [USECASE] Total de artistas encontrados: ${allArtistsWithAvailabilities.length}');
          
          // 3. Aplicar filtros em memória para cada artista
          final filteredArtistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];
          int artistsProcessed = 0;
          int artistsWithValidAvailabilities = 0;

          // Garantir limites válidos
          final safeStartIndex = startIndex.clamp(0, allArtistsWithAvailabilities.length);
          final int maxToCollect = pageSize <= 0 ? 10 : pageSize;

          // Paginação pós-filtro: varrer a partir do startIndex e coletar até pageSize
          int i = safeStartIndex;
          while (i < allArtistsWithAvailabilities.length &&
                 filteredArtistsWithAvailabilities.length < maxToCollect) {
            final artistWithAvailabilities = allArtistsWithAvailabilities[i];
            artistsProcessed++;
            final artist = artistWithAvailabilities.artist;
            final allAvailabilities = artistWithAvailabilities.availabilities;
            
            print('🟣 [USECASE] Processando artista: ${artist.artistName} (ID: ${artist.uid}) [idx=$i]');
            print('🟣 [USECASE] Artista ${artist.uid} - Total de disponibilidades: ${allAvailabilities.length}');
            
            // Aplicar filtros em memória
            List<AvailabilityEntity> filtered = allAvailabilities;
            
            // Filtro 1: Por geohash (range)
            if (minGeohash != null && maxGeohash != null) {
              filtered = _filterByGeohash(filtered, minGeohash!, maxGeohash!);
              print('🟣 [USECASE] Artista ${artist.uid} - Após filtro de geohash: ${filtered.length}');
            }
            
            // Filtro 2: Por data (range, dia da semana, horários bloqueados)
            filtered = _filterByDateValidation(filtered, selectedDate);
            print('🟣 [USECASE] Artista ${artist.uid} - Após filtro de data: ${filtered.length}');

            // Filtro 3: Por distância Haversine (raio de atuação)
            filtered = _filterByDistance(filtered, userAddress);
            print('🟣 [USECASE] Artista ${artist.uid} - Após filtro de distância: ${filtered.length}');

            // Só adicionar artista se tiver pelo menos uma disponibilidade válida
            if (filtered.isNotEmpty) {
              artistsWithValidAvailabilities++;
              print('🟢 [USECASE] Artista ${artist.uid} - ADICIONADO com ${filtered.length} disponibilidades válidas');
              filteredArtistsWithAvailabilities.add(
                ArtistWithAvailabilitiesEntity(
                  artist: artist,
                  availabilities: filtered,
                ),
              );
            } else {
              print('🟡 [USECASE] Artista ${artist.uid} - REMOVIDO (sem disponibilidades válidas)');
            }
            i++;
          }

          final hasMore = i < allArtistsWithAvailabilities.length;
          final nextIndex = i;
          print('🟢 [USECASE] Paginação: retornados=${filteredArtistsWithAvailabilities.length}, nextIndex=$nextIndex, hasMore=$hasMore');

          print('🟢 [USECASE] Processamento concluído!');
          print('🟢 [USECASE] Estatísticas:');
          print('   - Artistas processados: $artistsProcessed');
          print('   - Artistas com disponibilidades válidas: $artistsWithValidAvailabilities');
          print('   - Total retornado: ${filteredArtistsWithAvailabilities.length}');
          print('   - ✅ Filtragem feita em memória (0 reads do Firestore)');

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

  /// Filtra disponibilidades por geohash (range)
  /// 
  /// Aplica filtro de geohash apenas se minGeohash e maxGeohash forem fornecidos.
  /// Retorna apenas disponibilidades onde geohash está dentro do range.
  List<AvailabilityEntity> _filterByGeohash(
    List<AvailabilityEntity> availabilities,
    String minGeohash,
    String maxGeohash,
  ) {
    if (minGeohash.isEmpty || maxGeohash.isEmpty) {
      return availabilities;
    }

    print('🟣 [USECASE] _filterByGeohash - Filtrando ${availabilities.length} disponibilidades por geohash');
    print('🟣 [USECASE] _filterByGeohash - Range: min=$minGeohash, max=$maxGeohash');

    final filtered = availabilities.where((availability) {
      final availabilityGeohash = availability.endereco.geohash;
      
      if (availabilityGeohash == null || availabilityGeohash.isEmpty) {
        print('🟡 [USECASE] _filterByGeohash - Disponibilidade ${availability.id} sem geohash, REJEITADA');
        return false;
      }

      // Truncar ambos os geohashes para a mesma precisão para comparação correta
      // O range é calculado com precisão 4, então truncamos ambos para precisão 4
      final truncatedAvailabilityGeohash = GeohashHelper.truncate(availabilityGeohash, minGeohash.length);
      final truncatedMinGeohash = GeohashHelper.truncate(minGeohash, minGeohash.length);
      final truncatedMaxGeohash = GeohashHelper.truncate(maxGeohash, maxGeohash.length);
      
      final isInRange = truncatedAvailabilityGeohash.compareTo(truncatedMinGeohash) >= 0 &&
                        truncatedAvailabilityGeohash.compareTo(truncatedMaxGeohash) <= 0;
      
      if (!isInRange) {
        print('🟡 [USECASE] _filterByGeohash - Disponibilidade ${availability.id} FORA do range: geohash=$availabilityGeohash');
      }

      return isInRange;
    }).toList();
    
    print('🟣 [USECASE] _filterByGeohash - Resultado: ${filtered.length} disponibilidades dentro do range de ${availabilities.length}');
    
    return filtered;
  }

  /// Filtra disponibilidades por validações de data (range, dia da semana, horários bloqueados)
  /// 
  /// Aplica todas as validações usando IsAvailabilityValidForDateUseCase:
  /// - Verifica se data está dentro do range (dataInicio <= selectedDate <= dataFim)
  /// - Verifica se o dia da semana corresponde aos diasDaSemana
  /// - Verifica se não há horários bloqueados que cubram completamente o horário
  /// 
  /// Retorna apenas disponibilidades válidas para a data selecionada
  List<AvailabilityEntity> _filterByDateValidation(
    List<AvailabilityEntity> availabilities,
    DateTime? selectedDate,
  ) {
    // Se não houver data selecionada, retornar todas as disponibilidades
    if (selectedDate == null) {
      print('🟡 [USECASE] _filterByDateValidation - Sem data selecionada, retornando todas as ${availabilities.length} disponibilidades');
      return availabilities;
    }

    print('🟣 [USECASE] _filterByDateValidation - Filtrando ${availabilities.length} disponibilidades para data: $selectedDate');
    
    final filtered = availabilities.where((availability) {
      final isValid = isAvailabilityValidForDateUseCase.call(availability, selectedDate);
      if (!isValid) {
        print('🟡 [USECASE] _filterByDateValidation - Disponibilidade ${availability.id} REJEITADA para data $selectedDate');
      }
      return isValid;
    }).toList();
    
    print('🟣 [USECASE] _filterByDateValidation - Resultado: ${filtered.length} disponibilidades válidas de ${availabilities.length}');
    
    return filtered;
  }

  /// Filtra disponibilidades por distância Haversine (raio de atuação)
  /// 
  /// Aplica filtro de distância apenas se:
  /// - userAddress for fornecido
  /// - userAddress tiver latitude e longitude
  /// - availability.endereco tiver latitude e longitude
  /// 
  /// Retorna apenas disponibilidades onde distância <= raioAtuacao
  List<AvailabilityEntity> _filterByDistance(
    List<AvailabilityEntity> availabilities,
    AddressInfoEntity? userAddress,
  ) {
    // Se não houver endereço do usuário, retornar todas as disponibilidades
    if (userAddress == null ||
        userAddress.latitude == null ||
        userAddress.longitude == null) {
      print('🟡 [USECASE] _filterByDistance - Sem endereço do usuário, retornando todas as ${availabilities.length} disponibilidades');
      return availabilities;
    }

    final userLat = userAddress.latitude!;
    final userLon = userAddress.longitude!;
    
    print('🟣 [USECASE] _filterByDistance - Filtrando ${availabilities.length} disponibilidades por distância');
    print('🟣 [USECASE] _filterByDistance - Coordenadas do usuário: lat=$userLat, lon=$userLon');

    final filtered = availabilities.where((availability) {
      // Verificar se disponibilidade tem coordenadas
      final availabilityLat = availability.endereco.latitude;
      final availabilityLon = availability.endereco.longitude;

      if (availabilityLat == null || availabilityLon == null) {
        print('🟡 [USECASE] _filterByDistance - Disponibilidade ${availability.id} sem coordenadas, REJEITADA');
        return false; // Sem coordenadas, não pode calcular distância
      }

      // Calcular distância
      final distance = DistanceHelper.calculateHaversineDistance(
        userLat,
        userLon,
        availabilityLat,
        availabilityLon,
      );
      
      final isWithinRadius = distance <= availability.raioAtuacao;
      
      if (!isWithinRadius) {
        print('🟡 [USECASE] _filterByDistance - Disponibilidade ${availability.id} FORA do raio: distância=${distance.toStringAsFixed(2)}km, raio=${availability.raioAtuacao}km');
      } else {
        print('🟢 [USECASE] _filterByDistance - Disponibilidade ${availability.id} DENTRO do raio: distância=${distance.toStringAsFixed(2)}km, raio=${availability.raioAtuacao}km');
      }

      return isWithinRadius;
    }).toList();
    
    print('🟣 [USECASE] _filterByDistance - Resultado: ${filtered.length} disponibilidades dentro do raio de ${availabilities.length}');
    
    return filtered;
  }
}

