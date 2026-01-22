import 'package:flutter/material.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/add_time_slot_result.dart';
import 'package:app/features/profile/artist_availability/domain/entities/slot_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

/// Use Case para adicionar slot de horário a um dia
/// 
/// Adiciona um novo slot de horário à disponibilidade de um dia específico.
/// Valida se há overlaps antes de adicionar.
/// 
/// **Fluxo:**
/// 1. Busca os slots do dia (na única availabilityEntry que temos)
/// 2. Verifica se o novo slot está sobrepondo algum
///    - Se sim -> identifica esses slots e retorna informações de overlap
///    - Se não -> Adiciona o novo slot ao availabilityEntry do dia
/// 3. Retorna hasOverlapSlot e, se true, dicionário com {day: {slotId: SlotOverlapInfo, ...}}
class AddTimeSlotUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  AddTimeSlotUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, AddTimeSlotResult>> call(
    String artistId,
    SlotOperationDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      final slot = dto.slot;

      if (slot.startTime == null || slot.endTime == null || slot.valorHora == null) {
        return const Left(
          ValidationFailure('Todos os campos do slot são obrigatórios'),
        );
      }

      if (slot.startTime!.isEmpty || slot.endTime!.isEmpty) {
        return const Left(ValidationFailure('Horários são obrigatórios'));
      }

      if (slot.valorHora! <= 0) {
        return const Left(
          ValidationFailure('Valor/hora deve ser maior que zero'),
        );
      }

      // Validar formato de horário (HH:mm)
      final timeRegex = RegExp(r'^\d{2}:\d{2}$');
      if (!timeRegex.hasMatch(slot.startTime!) || 
          !timeRegex.hasMatch(slot.endTime!)) {
        return const Left(
          ValidationFailure('Formato de horário inválido. Use HH:mm'),
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Buscar disponibilidade do dia
      // ════════════════════════════════════════════════════════════════
      final getDayResult = await getByDate(
        artistId,
        GetAvailabilityByDateDto(date: dto.date, forceRemote: false),
      );

      return getDayResult.fold(
        (failure) => Left(failure),
        (dayEntity) async {
          if (dayEntity == null) {
            return const Left(
              NotFoundFailure('Disponibilidade não encontrada para este dia'),
            );
          }

          if (dayEntity.availabilities.isEmpty) {
            return const Left(ValidationFailure('Dia sem disponibilidades'));
          }

          // ════════════════════════════════════════════════════════════
          // 2. Buscar os slots do dia (na única availabilityEntry)
          // ════════════════════════════════════════════════════════════
          final firstEntry = dayEntity.availabilities.first;
          final dayId = _formatDate(dto.date);

          // Converter horários do novo slot para TimeOfDay
          final newStartTime = _parseTimeString(slot.startTime!);
          final newEndTime = _parseTimeString(slot.endTime!);

          // ════════════════════════════════════════════════════════════
          // 3. Verificar se o novo slot está sobrepondo algum
          // ════════════════════════════════════════════════════════════
          final overlaps = <String, SlotOverlapInfo>{};

          for (final existingSlot in firstEntry.slots) {
            // Converter strings de horário para TimeOfDay
            final existingStartTime = _parseTimeString(existingSlot.startTime);
            final existingEndTime = _parseTimeString(existingSlot.endTime);

            // Verificar se há sobreposição
            final overlapType = AvailabilityHelpers.validateTimeSlotOverlap(
              newStart: newStartTime,
              newEnd: newEndTime,
              existingStart: existingStartTime,
              existingEnd: existingEndTime,
            );

            if (overlapType != null) {
              // Há overlap, guardar informações
              overlaps[existingSlot.slotId] = SlotOverlapInfo(
                slot: existingSlot,
                overlapType: overlapType,
              );
            }
          }

          // ════════════════════════════════════════════════════════════
          // 4. Se há overlaps, retornar informações sem adicionar
          // ════════════════════════════════════════════════════════════
          if (overlaps.isNotEmpty) {
            return Right(AddTimeSlotResult.withOverlaps(dayId, overlaps));
          }

          // ════════════════════════════════════════════════════════════
          // 5. Se não há overlaps, adicionar o novo slot
          // ════════════════════════════════════════════════════════════
          const uuid = Uuid();
          final newSlot = TimeSlot(
            slotId: uuid.v4(),
            startTime: slot.startTime!,
            endTime: slot.endTime!,
            status: 'available',
            valorHora: slot.valorHora!,
            sourcePatternId: null, // Slot manual, sem padrão
          );

          final updatedSlots = [...firstEntry.slots, newSlot];
          
          final updatedEntry = firstEntry.copyWith(
            slots: updatedSlots,
          );

          final updatedAvailabilities = [
            updatedEntry,
            ...dayEntity.availabilities.skip(1),
          ];

          final updatedDay = dayEntity.copyWith(
            availabilities: updatedAvailabilities,
            updatedAt: DateTime.now(),
          );

          // ════════════════════════════════════════════════════════════
          // 6. Atualizar no repositório
          // ════════════════════════════════════════════════════════════
          final updateResult = await repository.updateAvailability(
            artistId: artistId,
            day: updatedDay,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (savedDay) => Right(AddTimeSlotResult.success(savedDay)),
          );
        },
      );
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Formata DateTime para string "YYYY-MM-DD"
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Converte string "HH:mm" para TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
