import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artists/domain/usecases/sync_artist_completeness_if_changed_usecase.dart';
import 'package:dartz/dartz.dart';

class DeleteAvailabilityUseCase {
  final IAvailabilityRepository repository;
  final SyncArtistCompletenessIfChangedUseCase syncArtistCompletenessIfChangedUseCase;

  DeleteAvailabilityUseCase({
    required this.repository,
    required this.syncArtistCompletenessIfChangedUseCase,
  });

  Future<Either<Failure, void>> call({
    required String artistId,
    required String availabilityId,
  }) async {
    final result = await repository.deleteAvailability(artistId, availabilityId);

    // Sincronizar completude apenas se mudou
    await syncArtistCompletenessIfChangedUseCase.call();

    return result;
  }
}

