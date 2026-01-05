import 'package:app/core/domain/artist/availability_calendar_entitys/blocked_time_slot.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/artist_availability/domain/repositories/availability_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAvailabilityUseCase {
  final IAvailabilityRepository repository;

  UpdateAvailabilityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String artistId,
    required String availabilityId,
    required double raioAtuacao,
    required double valorShow,
    required List<BlockedTimeSlot> blockedSlots,
  }) async {
    // Busca a availability atual
    final getResult = await repository.getAvailability(artistId, availabilityId);
    
    return getResult.fold(
      (failure) => Left(failure),
      (currentAvailability) async {
        // Atualiza apenas os campos permitidos (raio, valor e blockedSlots)
        final updatedAvailability = currentAvailability.copyWith(
          raioAtuacao: raioAtuacao,
          valorShow: valorShow,
          blockedSlots: blockedSlots,
        );
        
        // Salva a availability atualizada
        return await repository.updateAvailability(artistId, updatedAvailability);
      },
    );
  }
}

