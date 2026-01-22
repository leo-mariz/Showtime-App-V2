import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/availability_entry_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/close_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';

/// Use Case para fechar/bloquear um período de disponibilidade
/// 
/// Percorre os dias do período, identifica slots sobrepostos,
/// ajusta os slots existentes usando helpers de validação e geração de slots,
/// removendo os horários que estão sendo fechados.
/// 
/// **Fluxo:**
/// 1. Recebe o período a ser fechado
/// 2. Verifica as datas válidas usando `generateValidDates`
/// 3. Para cada data:
///    3.1. Para cada slot:
///         - Há overlap?
///           - Sim -> Passa os horários para o `generateNewSlots`. 
///                    Substitui o slot do dia (que é sobreposto) pelos slots novos gerados.
///                    Salva a disponibilidade do dia atualizada
///           - Não -> Não fazer nada, pois não tem horários ali a serem fechados
/// 
/// **Exemplo:**
/// ```dart
/// final dto = ClosePeriodDto(
///   startDate: DateTime(2026, 1, 15),
///   endDate: DateTime(2026, 1, 20),
///   startTime: TimeOfDay(hour: 16, minute: 0),
///   endTime: TimeOfDay(hour: 20, minute: 0),
///   blockReason: 'Férias',
/// );
/// 
/// final result = await closePeriodUseCase(artistId, dto);
/// ```
class ClosePeriodUseCase {
  final IAvailabilityRepository _repository;

  ClosePeriodUseCase({
    required IAvailabilityRepository repository,
  }) : _repository = repository;

  /// Fecha/bloqueia período de disponibilidade
  /// 
  /// **Retorna:**
  /// - `Right(List<AvailabilityDayEntity>)` com todos os dias atualizados
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    ClosePeriodDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Verificar as datas válidas usando generateValidDates
      // ════════════════════════════════════════════════════════════════
      final validDates = AvailabilityHelpers.generateValidDates(
        startDate: dto.startDate,
        endDate: dto.endDate,
        weekdays: dto.weekdays, // ClosePeriod não tem filtro de weekdays, processa todos os dias
      );

      final updatedDays = <AvailabilityDayEntity>[];

      // ════════════════════════════════════════════════════════════════
      // 2. Para cada data válida
      // ════════════════════════════════════════════════════════════════
      for (final date in validDates) {
        final dayId = _formatDate(date);
        print('[ClosePeriod] 📅 Processando dia: $dayId');

        // ════════════════════════════════════════════════════════════
        // 2.1. Buscar disponibilidade do dia
        // ════════════════════════════════════════════════════════════
        print('[ClosePeriod] 🔍 Buscando disponibilidade para dia: $dayId');
        final availabilityResult = await _repository.getAvailability(
          artistId: artistId,
          dayId: dayId,
        );

        await availabilityResult.fold(
          (failure) async {
            // Se o dia não existe, não fazer nada (não tem horários a serem fechados)
            print('[ClosePeriod] ⚠️ Dia $dayId não encontrado. Não há horários a serem fechados.');
          },
          (availabilityDay) async {
            print('[ClosePeriod] ✅ Disponibilidade encontrada. Availabilities: ${availabilityDay.availabilities.length}');
            
            // ════════════════════════════════════════════════════════
            // 2.2. Se dia não tem availabilities, não fazer nada
            // ════════════════════════════════════════════════════════
            if (availabilityDay.availabilities.isEmpty) {
              print('[ClosePeriod] ⚠️ Dia $dayId sem availabilities. Não há horários a serem fechados.');
              return;
            }

            // ════════════════════════════════════════════════════════
            // 3. Para cada availability do dia
            // ════════════════════════════════════════════════════════
            final updatedAvailabilities = <AvailabilityEntry>[];
            bool hasChanges = false;

            for (final availability in availabilityDay.availabilities) {
              print('[ClosePeriod] 🔄 Processando availability: ${availability.availabilityId}');
              
              // ════════════════════════════════════════════════════
              // 3.1. Para cada slot
              // ════════════════════════════════════════════════════
              final adjustedSlots = <TimeSlot>[];

              for (final slot in availability.slots) {
                // Converter strings de horário para TimeOfDay
                final slotStartTime = _parseTimeString(slot.startTime);
                final slotEndTime = _parseTimeString(slot.endTime);

                // Verificar se há sobreposição
                final overlapType = AvailabilityHelpers.validateTimeSlotOverlap(
                  newStart: dto.startTime,
                  newEnd: dto.endTime,
                  existingStart: slotStartTime,
                  existingEnd: slotEndTime,
                );

                if (overlapType == null) {
                  // Não há overlap -> Não fazer nada, pois não tem horários ali a serem fechados
                  adjustedSlots.add(slot);
                } else {
                  // Há overlap -> Passa os horários para o generateNewSlots
                  // Substitui o slot do dia (que é sobreposto) pelos slots novos gerados
                  print('[ClosePeriod] 🔧 Overlap detectado no slot ${slot.slotId} (tipo: $overlapType). Gerando novos slots...');
                  hasChanges = true;
                  
                  final newSlots = AvailabilityHelpers.generateNewSlots(
                    existingSlot: slot,
                    newStart: dto.startTime,
                    newEnd: dto.endTime,
                    overlapType: overlapType,
                  );
                  
                  adjustedSlots.addAll(newSlots);
                  print('[ClosePeriod] ✅ Slot ${slot.slotId} substituído por ${newSlots.length} novo(s) slot(s)');
                }
              }

              // ════════════════════════════════════════════════════
              // Atualizar availability com slots ajustados
              // ════════════════════════════════════════════════════
              // Ordenar slots por horário (caso ainda não estejam ordenados)
              adjustedSlots.sort((a, b) {
                final aTime = _parseTimeString(a.startTime);
                final bTime = _parseTimeString(b.startTime);
                return (aTime.hour * 60 + aTime.minute)
                    .compareTo(bTime.hour * 60 + bTime.minute);
              });

              final updatedAvailability = availability.copyWith(
                slots: adjustedSlots,
                updatedAt: DateTime.now(),
              );

              updatedAvailabilities.add(updatedAvailability);
            }

            // ════════════════════════════════════════════════════════
            // 3.2. Se houve mudanças, salvar a disponibilidade do dia atualizada
            // ════════════════════════════════════════════════════════
            if (hasChanges) {
              final updatedDay = availabilityDay.copyWith(
                availabilities: updatedAvailabilities,
                updatedAt: DateTime.now(),
              );

              final saveResult = await _repository.updateAvailability(
                artistId: artistId,
                day: updatedDay,
              );

              saveResult.fold(
                (failure) {
                  print('[ClosePeriod] ❌ Erro ao salvar dia $dayId: ${failure.message}');
                  throw failure;
                },
                (savedDay) {
                  print('[ClosePeriod] ✅ Dia $dayId salvo com sucesso');
                  updatedDays.add(savedDay);
                },
              );
            } else {
              print('[ClosePeriod] ℹ️ Dia $dayId não teve mudanças. Nenhum slot foi ajustado.');
            }
          },
        );
      }

      return Right(updatedDays);
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
