import 'package:flutter/material.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/update_time_slot_result.dart';
import 'package:app/features/profile/artist_availability/domain/entities/slot_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/get_availability_by_date_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para atualizar slot de horário
/// 
/// Atualiza um slot de horário existente (horário e/ou valor).
/// Valida se há overlaps antes de atualizar.
/// 
/// **Fluxo:**
/// 1. Busca os slots do dia (na única availabilityEntry que temos)
/// 2. Verifica se o slot atualizado está sobrepondo algum outro slot
///    (excluindo o próprio slot que está sendo editado)
///    - Se sim -> identifica esses slots e retorna informações de overlap
///    - Se não -> Atualiza o slot no availabilityEntry do dia
/// 3. Retorna hasOverlapSlot e, se true, dicionário com {day: {slotId: SlotOverlapInfo, ...}}
class UpdateTimeSlotUseCase {
  final IAvailabilityRepository repository;
  final GetAvailabilityByDateUseCase getByDate;

  UpdateTimeSlotUseCase({
    required this.repository,
    required this.getByDate,
  });

  Future<Either<Failure, UpdateTimeSlotResult>> call(
    String artistId,
    SlotOperationDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      final slot = dto.slot;

      if (slot.slotId == null || slot.slotId!.isEmpty) {
        return const Left(ValidationFailure('ID do slot é obrigatório'));
      }

      // Validar que pelo menos um campo foi fornecido
      if (slot.startTime == null && 
          slot.endTime == null && 
          slot.valorHora == null) {
        return const Left(
          ValidationFailure('Pelo menos um campo deve ser atualizado'),
        );
      }

      // Validar formato de horário se fornecido
      final timeRegex = RegExp(r'^\d{2}:\d{2}$');
      if (slot.startTime != null && !timeRegex.hasMatch(slot.startTime!)) {
        return const Left(
          ValidationFailure('Formato de horário inicial inválido. Use HH:mm'),
        );
      }
      if (slot.endTime != null && !timeRegex.hasMatch(slot.endTime!)) {
        return const Left(
          ValidationFailure('Formato de horário final inválido. Use HH:mm'),
        );
      }

      // Validar valor se fornecido
      if (slot.valorHora != null && slot.valorHora! <= 0) {
        return const Left(
          ValidationFailure('Valor/hora deve ser maior que zero'),
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
          final slotIndex = firstEntry.slots.indexWhere(
            (s) => s.slotId == slot.slotId,
          );

          if (slotIndex == -1) {
            return const Left(NotFoundFailure('Slot não encontrado'));
          }

          final oldSlot = firstEntry.slots[slotIndex];
          final dayId = _formatDate(dto.date);

          // ════════════════════════════════════════════════════════════
          // 3. Calcular os horários atualizados do slot
          // ════════════════════════════════════════════════════════════
          final updatedStartTime = slot.startTime ?? oldSlot.startTime;
          final updatedEndTime = slot.endTime ?? oldSlot.endTime;

          // Converter horários atualizados para TimeOfDay
          final newStartTime = _parseTimeString(updatedStartTime);
          final newEndTime = _parseTimeString(updatedEndTime);

          // ════════════════════════════════════════════════════════════
          // 4. Verificar se o slot atualizado está sobrepondo algum outro
          // (excluindo o próprio slot que está sendo editado)
          // ════════════════════════════════════════════════════════════
          final overlaps = <String, SlotOverlapInfo>{};

          for (final existingSlot in firstEntry.slots) {
            // Ignorar o próprio slot que está sendo editado
            if (existingSlot.slotId == slot.slotId) {
              continue;
            }

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
          // 5. Se há overlaps, retornar informações sem atualizar
          // ════════════════════════════════════════════════════════════
          if (overlaps.isNotEmpty) {
            return Right(UpdateTimeSlotResult.withOverlaps(dayId, overlaps));
          }

          // ════════════════════════════════════════════════════════════
          // 6. Se não há overlaps, atualizar o slot
          // ════════════════════════════════════════════════════════════
          final updatedSlot = oldSlot.copyWith(
            startTime: updatedStartTime,
            endTime: updatedEndTime,
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

          // ════════════════════════════════════════════════════════════
          // 7. Atualizar no repositório
          // ════════════════════════════════════════════════════════════
          final updateResult = await repository.updateAvailability(
            artistId: artistId,
            day: updatedDay,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (savedDay) => Right(UpdateTimeSlotResult.success(savedDay)),
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
