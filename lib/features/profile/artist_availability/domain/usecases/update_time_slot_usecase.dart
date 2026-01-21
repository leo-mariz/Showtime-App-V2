import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar slot de horário
/// 
/// Atualiza um slot de horário existente (horário e/ou valor).
/// Encontra o slot pelo ID e atualiza suas propriedades.
class UpdateTimeSlotUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateTimeSlotUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, AvailabilityDayEntity>> call(
    String artistId,
    SlotOperationDto dto,
  ) async {
    if (artistId.isEmpty) {
      return Left(ValidationFailure('ID do artista é obrigatório'));
    }

    final slot = dto.slot;

    if (slot.slotId == null || slot.slotId!.isEmpty) {
      return Left(ValidationFailure('ID do slot é obrigatório'));
    }

    // Validar que pelo menos um campo foi fornecido
    if (slot.startTime == null && slot.endTime == null && slot.valorHora == null) {
      return Left(ValidationFailure('Pelo menos um campo deve ser atualizado'));
    }

    // Validar formato de horário se fornecido
    final timeRegex = RegExp(r'^\d{2}:\d{2}$');
    if (slot.startTime != null && !timeRegex.hasMatch(slot.startTime!)) {
      return Left(ValidationFailure('Formato de horário inicial inválido. Use HH:mm'));
    }
    if (slot.endTime != null && !timeRegex.hasMatch(slot.endTime!)) {
      return Left(ValidationFailure('Formato de horário final inválido. Use HH:mm'));
    }

    // Validar valor se fornecido
    if (slot.valorHora != null && slot.valorHora! <= 0) {
      return Left(ValidationFailure('Valor/hora deve ser maior que zero'));
    }

    // Buscar disponibilidade do dia
    final getDayResult = await getByDate(
      artistId,
      GetAvailabilityByDateDto(date: dto.date, forceRemote: true),
    );

    return getDayResult.fold(
      (failure) => Left(failure),
      (dayEntity) {
        if (dayEntity == null) {
          return Left(NotFoundFailure('Disponibilidade não encontrada para este dia'));
        }

        if (dayEntity.availabilities.isEmpty) {
          return Left(ValidationFailure('Dia sem disponibilidades'));
        }

        // Procurar e atualizar slot na primeira entry
        final firstEntry = dayEntity.availabilities.first;
        final slotIndex = firstEntry.slots.indexWhere((s) => s.slotId == slot.slotId);

        if (slotIndex == -1) {
          return Left(NotFoundFailure('Slot não encontrado'));
        }

        final oldSlot = firstEntry.slots[slotIndex];
        final updatedSlot = oldSlot.copyWith(
          startTime: slot.startTime ?? oldSlot.startTime,
          endTime: slot.endTime ?? oldSlot.endTime,
          valorHora: slot.valorHora ?? oldSlot.valorHora,
        );

        // Criar lista atualizada de slots
        final updatedSlots = List.of(firstEntry.slots);
        updatedSlots[slotIndex] = updatedSlot;

        final updatedEntry = firstEntry.copyWith(
          slots: updatedSlots,
        );

        // Criar lista atualizada de availabilities
        final updatedAvailabilities = [
          updatedEntry,
          ...dayEntity.availabilities.skip(1),
        ];

        final updatedDay = dayEntity.copyWith(
          availabilities: updatedAvailabilities,
          updatedAt: DateTime.now(),
        );

        // Atualizar no repositório
        return repository.updateAvailability(
          artistId: artistId,
          day: updatedDay,
        );
      },
    );
  }
}
