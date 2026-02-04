import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/distance_helper.dart';
import 'package:app/core/utils/geohash_helper.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:dartz/dartz.dart';

/// UseCase: Buscar todas as disponibilidades ativas de um artista
/// 
/// RESPONSABILIDADES:
/// - Buscar todas as disponibilidades do artista via repositório (com cache)
/// - Filtrar apenas disponibilidades ativas (isActive == true)
/// - Filtrar apenas disponibilidades que tenham pelo menos um slot com status available
/// - Filtrar por endereço (geohash e distância) se fornecido
/// - Ordenar por data (mais antigas primeiro)
/// - Retornar lista filtrada e ordenada
/// 
/// FILTROS APLICADOS:
/// 1. isActive == true: Apenas disponibilidades ativas
/// 2. Tem pelo menos um slot com status == available: Slots booked não contam
/// 3. Geohash: Filtra disponibilidades com geohash dentro do range do endereço (se fornecido)
/// 4. Distância: Filtra usando Haversine (distância <= raioAtuacao) (se fornecido)
/// 
/// OBSERVAÇÕES:
/// - Usa cache agressivo (2 horas de validade)
/// - Se cache válido, retorna do cache (0 reads do Firestore)
/// - Filtragem é feita em memória após buscar do repositório
/// 
/// [artistId]: ID do artista
/// [userAddress]: Endereço do usuário para filtro geográfico (opcional)
/// [forceRefresh]: Se true, ignora o cache e busca diretamente do Firestore (útil para testes)
class GetArtistActiveAvailabilitiesUseCase {
  final IExploreRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;

  GetArtistActiveAvailabilitiesUseCase({
    required this.repository,
    required this.calculateAddressGeohashUseCase,
  });

  Future<Either<Failure, List<AvailabilityDayEntity>>> call({
    required String artistId,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
  }) async {
    try {
      if (artistId.isEmpty) {
        return const Left(
          ValidationFailure('ID do artista é obrigatório'),
        );
      }

      // 1. Calcular range de geohash do endereço do usuário (se fornecido)
      String? minGeohash;
      String? maxGeohash;
      
      if (userAddress != null &&
          userAddress.latitude != null &&
          userAddress.longitude != null) {
        final geohashResult = await calculateAddressGeohashUseCase.call(userAddress);
        geohashResult.fold(
          (failure) {
            // Se falhar ao calcular geohash, continuar sem filtro geográfico
          },
          (geohash) {
            // Calcular range de geohash para filtro
            final range = GeohashHelper.getRange(geohash);
            minGeohash = range['min'];
            maxGeohash = range['max'];
          },
        );
      }

      // 2. Buscar todas as disponibilidades do repositório (com cache)
      final result = await repository.getArtistAllAvailabilitiesForExplore(
        artistId,
        forceRefresh: forceRefresh,
      );

      return result.fold(
        (failure) => Left(failure),
        (allAvailabilities) {
          // Filtrar apenas disponibilidades ativas com slots available
          final activeAvailabilities = allAvailabilities
              .where((availability) {
                // Filtro 1: Deve estar ativa
                if (!availability.isActive) {
                  return false;
                }

                // Filtro 2: Deve ter pelo menos um slot com status available
                final hasAvailableSlot = availability.slots?.any(
                  (slot) => slot.status == TimeSlotStatusEnum.available,
                ) ?? false;

                if (!hasAvailableSlot) {
                  return false;
                }

                // Filtro 3: Por geohash (range) - se endereço fornecido
                if (minGeohash != null && maxGeohash != null && availability.endereco != null) {
                  final availabilityGeohash = availability.endereco!.geohash;
                  
                  if (availabilityGeohash == null || availabilityGeohash.isEmpty) {
                    return false;
                  } else {
                    // Truncar ambos os geohashes para a mesma precisão para comparação correta
                    final truncatedAvailabilityGeohash = GeohashHelper.truncate(availabilityGeohash, minGeohash!.length);
                    final truncatedMinGeohash = GeohashHelper.truncate(minGeohash!, minGeohash!.length);
                    final truncatedMaxGeohash = GeohashHelper.truncate(maxGeohash!, maxGeohash!.length);
                    
                    final isInRange = truncatedAvailabilityGeohash.compareTo(truncatedMinGeohash) >= 0 &&
                                      truncatedAvailabilityGeohash.compareTo(truncatedMaxGeohash) <= 0;
                    
                    if (!isInRange) {
                      return false;
                    }
                  }
                }

                // Filtro 4: Por distância Haversine (raio de atuação) - se endereço fornecido
                if (userAddress != null &&
                    userAddress.latitude != null &&
                    userAddress.longitude != null &&
                    availability.endereco != null &&
                    availability.endereco!.latitude != null &&
                    availability.endereco!.longitude != null &&
                    availability.raioAtuacao != null) {
                  
                  final distance = DistanceHelper.calculateHaversineDistance(
                    userAddress.latitude!,
                    userAddress.longitude!,
                    availability.endereco!.latitude!,
                    availability.endereco!.longitude!,
                  );
                  
                  final isWithinRadius = distance <= availability.raioAtuacao!;
                  
                  if (!isWithinRadius) {
                    return false;
                  }
                }

                return true;
              })
              .toList();

          // Ordenar por data (mais antigas primeiro)
          activeAvailabilities.sort((a, b) => a.date.compareTo(b.date));

          return Right(activeAvailabilities);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
