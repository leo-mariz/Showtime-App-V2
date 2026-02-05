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

/// UseCase: Buscar todas as disponibilidades ativas de um conjunto.
/// Espelho de [GetArtistActiveAvailabilitiesUseCase] para conjuntos.
class GetEnsembleActiveAvailabilitiesUseCase {
  final IExploreRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;

  GetEnsembleActiveAvailabilitiesUseCase({
    required this.repository,
    required this.calculateAddressGeohashUseCase,
  });

  Future<Either<Failure, List<AvailabilityDayEntity>>> call({
    required String ensembleId,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
  }) async {
    try {
      if (ensembleId.isEmpty) {
        return const Left(
          ValidationFailure('ID do conjunto é obrigatório'),
        );
      }

      String? minGeohash;
      String? maxGeohash;

      if (userAddress != null &&
          userAddress.latitude != null &&
          userAddress.longitude != null) {
        final geohashResult =
            await calculateAddressGeohashUseCase.call(userAddress);
        geohashResult.fold(
          (failure) {},
          (geohash) {
            final range = GeohashHelper.getRange(geohash);
            minGeohash = range['min'];
            maxGeohash = range['max'];
          },
        );
      }

      final result = await repository.getEnsembleAllAvailabilitiesForExplore(
        ensembleId,
        forceRefresh: forceRefresh,
      );

      return result.fold(
        (failure) => Left(failure),
        (allAvailabilities) {
          final activeAvailabilities = allAvailabilities.where((availability) {
            if (!availability.isActive) return false;
            final hasAvailableSlot = availability.slots?.any(
                  (slot) => slot.status == TimeSlotStatusEnum.available,
                ) ??
                false;
            if (!hasAvailableSlot) return false;

            if (minGeohash != null &&
                maxGeohash != null &&
                availability.endereco != null) {
              final availabilityGeohash = availability.endereco!.geohash;
              if (availabilityGeohash == null ||
                  availabilityGeohash.isEmpty) {
                return false;
              }
              final truncatedAvailability = GeohashHelper.truncate(
                availabilityGeohash,
                minGeohash!.length,
              );
              final truncatedMin =
                  GeohashHelper.truncate(minGeohash!, minGeohash!.length);
              final truncatedMax =
                  GeohashHelper.truncate(maxGeohash!, maxGeohash!.length);
              final isInRange = truncatedAvailability.compareTo(truncatedMin) >= 0 &&
                  truncatedAvailability.compareTo(truncatedMax) <= 0;
              if (!isInRange) return false;
            }

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
              if (distance > availability.raioAtuacao!) return false;
            }

            return true;
          }).toList();

          activeAvailabilities.sort((a, b) => a.date.compareTo(b.date));
          return Right(activeAvailabilities);
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
