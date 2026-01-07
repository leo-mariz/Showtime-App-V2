import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteAvailabilityUseCase {
  final IAvailabilityRepository repository;

  DeleteAvailabilityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String artistId,
    required String availabilityId,
  }) async {
    return await repository.deleteAvailability(artistId, availabilityId);
  }
}

