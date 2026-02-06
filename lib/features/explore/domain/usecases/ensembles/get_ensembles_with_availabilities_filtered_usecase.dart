import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/artist_individual/artist_entity.dart';
import 'package:app/core/domain/ensemble/ensemble_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/distance_helper.dart';
import 'package:app/core/utils/geohash_helper.dart';
import 'package:app/core/utils/minimum_earliness_helper.dart';
import 'package:app/features/addresses/domain/usecases/calculate_address_geohash_usecase.dart';
import 'package:app/features/explore/domain/entities/ensembles/ensemble_with_availabilities_entity.dart';
import 'package:app/features/explore/domain/repositories/explore_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// UseCase: Buscar conjuntos com disponibilidades filtradas por data e localização.
/// Espelho de [GetArtistsWithAvailabilitiesFilteredUseCase] para conjuntos.
class PagedEnsemblesResult {
  final List<EnsembleWithAvailabilitiesEntity> items;
  final int nextIndex;
  final bool hasMore;

  PagedEnsemblesResult({
    required this.items,
    required this.nextIndex,
    required this.hasMore,
  });
}

class GetEnsemblesWithAvailabilitiesFilteredUseCase {
  final IExploreRepository repository;
  final CalculateAddressGeohashUseCase calculateAddressGeohashUseCase;

  GetEnsemblesWithAvailabilitiesFilteredUseCase({
    required this.repository,
    required this.calculateAddressGeohashUseCase,
  });

  Future<Either<Failure, PagedEnsemblesResult>> call({
    DateTime? selectedDate,
    AddressInfoEntity? userAddress,
    bool forceRefresh = false,
    int startIndex = 0,
    int pageSize = 10,
    String? userId,
    String? searchQuery,
  }) async {
    try {
      if (selectedDate == null) {
        return const Left(
          ValidationFailure(
            'Data selecionada é obrigatória para buscar disponibilidades',
          ),
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

      debugPrint(
        '[GetEnsemblesFiltered] Chamando getEnsemblesForExplore forceRefresh=$forceRefresh',
      );
      final ensemblesResult = await repository.getEnsemblesForExplore(
        forceRefresh: forceRefresh,
      );

      return await ensemblesResult.fold(
        (failure) {
          debugPrint(
            '[GetEnsemblesFiltered] getEnsemblesForExplore falhou: ${failure.message}',
          );
          return Left(failure);
        },
        (ensembles) async {
          debugPrint(
            '[GetEnsemblesFiltered] getEnsemblesForExplore ok: ${ensembles.length} conjuntos',
          );
          final filtered = <EnsembleWithAvailabilitiesEntity>[];
          final safeStartIndex = startIndex.clamp(0, ensembles.length);
          final maxToCollect = pageSize <= 0 ? 10 : pageSize;
          const int concurrency = 10;
          int i = safeStartIndex;

          while (i < ensembles.length &&
              filtered.length < maxToCollect) {
            final batchSize = (maxToCollect - filtered.length)
                .clamp(1, concurrency);
            final remaining = ensembles.length - i;
            final currentBatchSize =
                batchSize < remaining ? batchSize : remaining;
            final batch = ensembles.skip(i).take(currentBatchSize).toList();

            final futures = batch.map((ensemble) async {
              final ensembleId = ensemble.id;
              if (ensembleId == null || ensembleId.isEmpty) return null;

              final availabilityDayResult =
                  await repository.getEnsembleAvailabilityDayForExplore(
                ensembleId,
                selectedDate,
                forceRefresh: forceRefresh,
              );

              final availabilityDay = availabilityDayResult.fold(
                (_) => null,
                (day) => day,
              );

              if (availabilityDay == null || !availabilityDay.hasAvailability) {
                return null;
              }
              if (!availabilityDay.isActive) return null;

              final hasAvailableSlot = availabilityDay.slots?.any(
                    (slot) => slot.status == TimeSlotStatusEnum.available,
                  ) ??
                  false;
              if (!hasAvailableSlot) return null;

              if (!respectsMinimumEarliness(
                selectedDate,
                ensemble.professionalInfo?.requestMinimumEarliness,
              )) {
                return null;
              }

              bool isValid = true;

              if (minGeohash != null &&
                  maxGeohash != null &&
                  availabilityDay.endereco != null) {
                final availabilityGeohash =
                    availabilityDay.endereco!.geohash;
                if (availabilityGeohash == null ||
                    availabilityGeohash.isEmpty) {
                  isValid = false;
                } else {
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
                  if (!isInRange) isValid = false;
                }
              }

              if (isValid &&
                  userAddress != null &&
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
                if (distance > availabilityDay.raioAtuacao!) isValid = false;
              }

              if (isValid &&
                  searchQuery != null &&
                  searchQuery.isNotEmpty) {
                if (!_matchesSearch(ensemble, searchQuery)) isValid = false;
              }

              if (isValid) {
                ArtistEntity? ownerArtist;
                final ownerSlots =
                    ensemble.members?.where((m) => m.isOwner).toList() ?? [];
                if (ownerSlots.isNotEmpty) {
                  final ownerId = ownerSlots.first.memberId;
                  if (ownerId.isNotEmpty) {
                    final artistResult = await repository.getArtistForExplore(
                      ownerId,
                      forceRefresh: forceRefresh,
                    );
                    ownerArtist = artistResult.fold((_) => null, (a) => a);
                  }
                }
                return EnsembleWithAvailabilitiesEntity(
                  ensemble: ensemble,
                  availabilities: [availabilityDay],
                  ownerArtist: ownerArtist,
                );
              }
              return null;
            }).toList();

            final batchResults = await Future.wait(futures);
            for (final result in batchResults) {
              if (result != null) {
                filtered.add(result);
                if (filtered.length >= maxToCollect) break;
              }
            }
            i += batch.length;
            if (filtered.length >= maxToCollect) break;
          }

          final hasMore = i < ensembles.length;
          final nextIndex = i;
          return Right(PagedEnsemblesResult(
            items: filtered,
            nextIndex: nextIndex,
            hasMore: hasMore,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[GetEnsemblesFiltered] exceção: $e');
      debugPrint(stackTrace.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  bool _matchesSearch(EnsembleEntity ensemble, String searchQuery) {
    if (searchQuery.isEmpty) return true;
    final lowerQuery = searchQuery.trim().toLowerCase();
    final info = ensemble.professionalInfo;
    if (info == null) return false;
    final specialty = info.specialty ?? [];
    final hasSpecialty = specialty.any(
      (talent) => talent.toLowerCase().contains(lowerQuery),
    );
    if (hasSpecialty) return true;
    final bio = (info.bio ?? '').toLowerCase();
    if (bio.contains(lowerQuery)) return true;
    return false;
  }
}
