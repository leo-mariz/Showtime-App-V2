import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/distance_helper.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/explore/domain/entities/artist_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:app/features/explore/domain/usecases/is_availability_valid_for_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar artistas com disponibilidades filtradas por data e localização
/// 
/// RESPONSABILIDADES:
/// - Buscar todos os artistas aprovados e ativos
/// - Para cada artista, buscar disponibilidades filtradas por data e geohash no Firestore
/// - Filtrar por distância Haversine no cliente (raio de atuação)
/// - Combinar artista + disponibilidades filtradas em ArtistWithAvailabilitiesEntity
/// - Retornar apenas artistas que têm pelo menos uma disponibilidade válida
/// 
/// FILTROS APLICADOS:
/// 1. Data: Busca no Firestore disponibilidades onde dataInicio <= selectedDate <= dataFim
/// 2. Geohash: Busca no Firestore disponibilidades com geohash dentro do range do usuário
/// 3. Distância: Filtra no cliente usando Haversine (distância <= raioAtuacao)
/// 
/// OBSERVAÇÕES:
/// - Usa cache agressivo (artistas: 2h, disponibilidades filtradas: 2h)
/// - Se artista não tiver disponibilidades válidas, não é incluído no resultado
/// - Busca disponibilidades em paralelo para todos os artistas (otimização)
/// - Continua processando mesmo se algum artista falhar
/// 
/// [selectedDate]: Data selecionada para filtrar disponibilidades (opcional)
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca tudo diretamente do Firestore (útil para testes)
class GetArtistsWithAvailabilitiesFilteredUseCase {
  final IExploreRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;
  final IsAvailabilityValidForDateUseCase isAvailabilityValidForDateUseCase;

  GetArtistsWithAvailabilitiesFilteredUseCase({
    required this.repository,
    required this.calculateAddressGeohashUseCase,
    required this.isAvailabilityValidForDateUseCase,
  });

  Future<Either<Failure, List<ArtistWithAvailabilitiesEntity>>> call({
    DateTime? selectedDate,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
  }) async {
    print('🟣 [USECASE] GetArtistsWithAvailabilitiesFiltered - Iniciando busca');
    print('🟣 [USECASE] Parâmetros:');
    print('   - selectedDate: $selectedDate');
    print('   - userAddress: ${userAddress?.title ?? "Nenhum"}');
    print('   - userAddress lat/lon: ${userAddress?.latitude}/${userAddress?.longitude}');
    print('   - forceRefresh: $forceRefresh');
    
    try {
      // 1. Calcular geohash do endereço do usuário (se fornecido)
      String? userGeohash;
      if (userAddress != null &&
          userAddress.latitude != null &&
          userAddress.longitude != null) {
        print('🟣 [USECASE] Calculando geohash para endereço: ${userAddress.title}');
        final geohashResult = await calculateAddressGeohashUseCase.call(userAddress);
        userGeohash = geohashResult.fold(
          (failure) {
            print('🔴 [USECASE] Erro ao calcular geohash: ${failure.message}');
            return null;
          },
          (geohash) {
            print('🟣 [USECASE] Geohash calculado: $geohash');
            return geohash;
          },
        );
      } else {
        print('🟣 [USECASE] Sem endereço ou coordenadas, não calculando geohash');
      }

      // 2. Buscar todos os artistas aprovados e ativos
      print('🟣 [USECASE] Buscando artistas aprovados e ativos...');
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
          
          // 3. Buscar disponibilidades filtradas para todos os artistas em paralelo
          final artistsWithAvailabilities = <ArtistWithAvailabilitiesEntity>[];

          // Criar lista de futures para buscar disponibilidades em paralelo
          final availabilityFutures = <Future<void>>[];
          int artistsProcessed = 0;
          int artistsWithValidAvailabilities = 0;

          for (final artist in artists) {
            // Verificar se artista tem UID válido
            if (artist.uid == null || artist.uid!.isEmpty) {
              print('🟡 [USECASE] Artista sem UID, pulando: ${artist.artistName}');
              continue; // Pular artista sem UID
            }

            final artistId = artist.uid!;
            print('🟣 [USECASE] Processando artista: ${artist.artistName} (ID: $artistId)');

            // Buscar disponibilidades filtradas do artista
            final future = repository
                .getArtistAvailabilitiesFilteredForExplore(
              artistId,
              selectedDate: selectedDate,
              userGeohash: userGeohash,
              forceRefresh: forceRefresh,
            ).then((availabilitiesResult) {
              availabilitiesResult.fold(
                (failure) {
                  print('🔴 [USECASE] Erro ao buscar disponibilidades do artista $artistId: ${failure.message}');
                  // Se falhar, não adicionar artista (silenciosamente)
                },
                (availabilities) {
                  artistsProcessed++;
                  print('🟣 [USECASE] Artista $artistId - Disponibilidades do Firestore: ${availabilities.length}');
                  
                  // Filtrar disponibilidades por validações de data (range, dia da semana, horários bloqueados)
                  final dateFilteredAvailabilities = _filterByDateValidation(
                    availabilities,
                    selectedDate,
                  );
                  print('🟣 [USECASE] Artista $artistId - Após filtro de data: ${dateFilteredAvailabilities.length}');

                  // Filtrar por distância Haversine no cliente (se endereço fornecido)
                  final filteredAvailabilities = _filterByDistance(
                    dateFilteredAvailabilities,
                    userAddress,
                  );
                  print('🟣 [USECASE] Artista $artistId - Após filtro de distância: ${filteredAvailabilities.length}');

                  // Só adicionar artista se tiver pelo menos uma disponibilidade válida
                  if (filteredAvailabilities.isNotEmpty) {
                    artistsWithValidAvailabilities++;
                    print('🟢 [USECASE] Artista $artistId - ADICIONADO com ${filteredAvailabilities.length} disponibilidades válidas');
                    artistsWithAvailabilities.add(
                      ArtistWithAvailabilitiesEntity(
                        artist: artist,
                        availabilities: filteredAvailabilities,
                      ),
                    );
                  } else {
                    print('🟡 [USECASE] Artista $artistId - REMOVIDO (sem disponibilidades válidas)');
                  }
                },
              );
            });

            availabilityFutures.add(future);
          }

          // Aguardar todas as buscas em paralelo
          print('🟣 [USECASE] Aguardando processamento de ${availabilityFutures.length} artistas em paralelo...');
          await Future.wait(availabilityFutures);

          print('🟢 [USECASE] Processamento concluído!');
          print('🟢 [USECASE] Estatísticas:');
          print('   - Artistas processados: $artistsProcessed');
          print('   - Artistas com disponibilidades válidas: $artistsWithValidAvailabilities');
          print('   - Total retornado: ${artistsWithAvailabilities.length}');

          return Right(artistsWithAvailabilities);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
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

