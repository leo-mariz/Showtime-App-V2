import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

/// Use Case para adicionar slot de horário a um dia
/// 
/// Adiciona um novo slot de horário à disponibilidade de um dia específico.
/// O slot é adicionado à primeira (e única) entry do dia.
class AddTimeSlotUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  AddTimeSlotUseCase({
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

    if (slot.startTime == null || slot.endTime == null || slot.valorHora == null) {
      return Left(ValidationFailure('Todos os campos do slot são obrigatórios'));
    }

    if (slot.startTime!.isEmpty || slot.endTime!.isEmpty) {
      return Left(ValidationFailure('Horários são obrigatórios'));
    }

    if (slot.valorHora! <= 0) {
      return Left(ValidationFailure('Valor/hora deve ser maior que zero'));
    }

    // Validar formato de horário (HH:mm)
    final timeRegex = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(slot.startTime!) || !timeRegex.hasMatch(slot.endTime!)) {
      return Left(ValidationFailure('Formato de horário inválido. Use HH:mm'));
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

        // Criar novo slot
        const uuid = Uuid();
        final newSlot = TimeSlot(
          slotId: uuid.v4(),
          startTime: slot.startTime!,
          endTime: slot.endTime!,
          status: 'available',
          valorHora: slot.valorHora!,
          sourcePatternId: null, // Slot manual, sem padrão
        );

        // Adicionar slot à primeira entry
        final firstEntry = dayEntity.availabilities.first;
        final updatedSlots = [...firstEntry.slots, newSlot];
        
        final updatedEntry = firstEntry.copyWith(
          slots: updatedSlots,
        );

        // Criar lista atualizada
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
