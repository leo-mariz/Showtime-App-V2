import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAvailabilityUseCase {
  final IAvailabilityRepository repository;

  UpdateAvailabilityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String artistId,
    required AvailabilityEntity updatedAvailability,
  }) async {
    // Valida se tem ID
    if (updatedAvailability.id == null || updatedAvailability.id!.isEmpty) {
      return const Left(ValidationFailure('ID da disponibilidade é obrigatório para atualização'));
    }
    
    // Salva a availability atualizada (com todos os campos)
    return await repository.updateAvailability(artistId, updatedAvailability);
  }
}

