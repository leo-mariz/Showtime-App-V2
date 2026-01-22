import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/availability_entry_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/open_period_result.dart';
import 'package:app/features/profile/artist_availability/domain/entities/slot_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/repositories/availability_repository.dart';

/// Use Case para abrir um período de disponibilidade
/// 
/// Cria disponibilidades para múltiplos dias com patternData (PatternMetadata)
/// permitindo rastrear e editar múltiplos dias de uma vez.
/// 
/// **Fluxo:**
/// 1. Gera datas válidas usando `generateValidDates`
/// 2. Para cada data:
///    - Busca disponibilidade do dia
///    - Se não tiver slots -> Adiciona o slot do dto
///    - Se tiver slots -> Verifica se algum sobrepõe o horário do dto
///      - Se não sobrepõe -> Adiciona o slot ao dia
///      - Se sobrepõe -> Guarda em dicionário e pula sem adicionar
/// 3. Retorna resultado com dias criados e informações de overlaps
/// 
/// **Exemplo:**
/// ```dart
/// final dto = OpenPeriodDto(
///   startDate: DateTime(2026, 1, 1),
///   endDate: DateTime(2026, 1, 31),
///   startTime: TimeOfDay(hour: 14, minute: 0),
///   endTime: TimeOfDay(hour: 22, minute: 0),
///   pricePerHour: 300.0,
///   addressId: 'address-123',
///   raioAtuacao: 50.0,
///   endereco: addressInfo,
///   weekdays: ['MO', 'TU', 'WE', 'TH', 'FR'], // Apenas dias úteis
/// );
/// 
/// final result = await openPeriodUseCase(artistId, dto);
/// ```
class OpenPeriodUseCase {
  final IAvailabilityRepository _repository;

  OpenPeriodUseCase({
    required IAvailabilityRepository repository,
  }) : _repository = repository;

  /// Abre período de disponibilidade
  /// 
  /// **Retorna:**
  /// - `Right(OpenPeriodResult)` com dias criados e informações de overlaps
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, OpenPeriodResult>> call(
    String artistId,
    OpenPeriodDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Gerar patternId único
      // ════════════════════════════════════════════════════════════════
      const uuid = Uuid();
      final patternId = uuid.v4();
      final now = DateTime.now();

      // ════════════════════════════════════════════════════════════════
      // 2. Criar PatternMetadata
      // ════════════════════════════════════════════════════════════════
      final patternMetadata = PatternMetadata(
        patternId: patternId,
        creationType: dto.weekdays != null ? 'recurring_pattern' : 'date_range',
        recurrence: RecurrenceSettings(
          weekdays: dto.weekdays,
          originalStartDate: dto.startDate,
          originalEndDate: dto.endDate,
          originalStartTime: dto.formattedStartTime,
          originalEndTime: dto.formattedEndTime,
          originalValorHora: dto.pricePerHour,
          originalAddressId: dto.addressId,
        ),
        createdAt: now,
      );

      // ════════════════════════════════════════════════════════════════
      // 3. Gerar datas válidas usando helper
      // ════════════════════════════════════════════════════════════════
      final validDates = AvailabilityHelpers.generateValidDates(
        startDate: dto.startDate,
        endDate: dto.endDate,
        weekdays: dto.weekdays,
      );

      // ════════════════════════════════════════════════════════════════
      // 4. Processar cada data válida
      // ════════════════════════════════════════════════════════════════
      final daysToCreate = <AvailabilityDayEntity>[];
      final daysToUpdate = <AvailabilityDayEntity>[];
      final overlapsByDay = <String, Map<String, SlotOverlapInfo>>{};

      for (final date in validDates) {
        final dayId = _formatDate(date);
        print('[OpenPeriod] 📅 Processando dia: $dayId');

        // ════════════════════════════════════════════════════════════
        // 4.1. Buscar disponibilidade do dia
        // ════════════════════════════════════════════════════════════
        final availabilityResult = await _repository.getAvailability(
          artistId: artistId,
          dayId: dayId,
        );

        await availabilityResult.fold(
          (failure) async {
            // Se o dia não existe, criar novo dia com o slot
            print('[OpenPeriod] ⚠️ Dia $dayId não encontrado. Criando novo dia.');
            final newDay = _createNewDay(
              date: date,
              dto: dto,
              patternId: patternId,
              patternMetadata: patternMetadata,
              now: now,
              uuid: uuid,
            );
            daysToCreate.add(newDay);
          },
          (existingDay) async {
            // ════════════════════════════════════════════════════════
            // 4.2. Verificar se existem slots
            // ════════════════════════════════════════════════════════
            if (existingDay.availabilities.isEmpty) {
              // Não tem slots, adicionar o slot do dto
              print('[OpenPeriod] ✅ Dia $dayId sem slots. Adicionando novo slot.');
              final updatedDay = _addSlotToDay(
                existingDay: existingDay,
                dto: dto,
                patternId: patternId,
                patternMetadata: patternMetadata,
                now: now,
                uuid: uuid,
              );
              daysToUpdate.add(updatedDay);
            } else {
              // Tem slots, verificar se algum sobrepõe
              print('[OpenPeriod] 🔍 Dia $dayId tem slots. Verificando overlaps...');
              
              final dayOverlaps = <String, SlotOverlapInfo>{};
              bool hasOverlap = false;
              
              for (final availability in existingDay.availabilities) {
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

                  if (overlapType != null) {
                    // Há overlap, guardar no dicionário com informações completas
                    hasOverlap = true;
                    dayOverlaps[slot.slotId] = SlotOverlapInfo(
                      slot: slot,
                      overlapType: overlapType,
                    );
                    print('[OpenPeriod] ⚠️ Overlap detectado: slot ${slot.slotId} -> $overlapType');
                  }
                }
              }

              if (hasOverlap) {
                // Há overlaps, não adicionar o slot e guardar no dicionário
                print('[OpenPeriod] ❌ Dia $dayId tem overlaps. Não adicionando slot.');
                overlapsByDay[dayId] = dayOverlaps;
              } else {
                // Não há overlaps, adicionar o slot ao dia
                print('[OpenPeriod] ✅ Dia $dayId sem overlaps. Adicionando novo slot.');
                final updatedDay = _addSlotToDay(
                  existingDay: existingDay,
                  dto: dto,
                  patternId: patternId,
                  patternMetadata: patternMetadata,
                  now: now,
                  uuid: uuid,
                );
                daysToUpdate.add(updatedDay);
              }
            }
          },
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 5. Salvar todos os dias no repositório
      // ════════════════════════════════════════════════════════════════
      final createdDays = <AvailabilityDayEntity>[];

      // Criar novos dias
      for (final day in daysToCreate) {
        final result = await _repository.createAvailability(
          artistId: artistId,
          day: day,
        );

        result.fold(
          (failure) => throw failure,
          (createdDay) => createdDays.add(createdDay),
        );
      }

      // Atualizar dias existentes
      for (final day in daysToUpdate) {
        final result = await _repository.updateAvailability(
          artistId: artistId,
          day: day,
        );

        result.fold(
          (failure) => throw failure,
          (updatedDay) => createdDays.add(updatedDay),
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 6. Retornar resultado com informações de overlaps
      // ════════════════════════════════════════════════════════════════
      if (overlapsByDay.isEmpty) {
        return Right(OpenPeriodResult.noOverlaps(createdDays));
      } else {
        return Right(OpenPeriodResult.withOverlaps(createdDays, overlapsByDay));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Cria um novo dia com o slot do DTO
  AvailabilityDayEntity _createNewDay({
    required DateTime date,
    required OpenPeriodDto dto,
    required String patternId,
    required PatternMetadata patternMetadata,
    required DateTime now,
    required Uuid uuid,
  }) {
    final timeSlot = TimeSlot(
      slotId: uuid.v4(),
      startTime: dto.formattedStartTime,
      endTime: dto.formattedEndTime,
      status: 'available',
      valorHora: dto.pricePerHour,
      sourcePatternId: patternId,
    );

    final availabilityEntry = AvailabilityEntry(
      availabilityId: uuid.v4(),
      generatedFrom: patternMetadata,
      addressId: dto.addressId,
      raioAtuacao: dto.raioAtuacao,
      endereco: dto.endereco,
      slots: [timeSlot],
      isManualOverride: false,
      createdAt: now,
    );

    return AvailabilityDayEntity(
      date: date,
      availabilities: [availabilityEntry],
      createdAt: now,
      isActive: true,
    );
  }

  /// Adiciona o slot do DTO a um dia existente
  AvailabilityDayEntity _addSlotToDay({
    required AvailabilityDayEntity existingDay,
    required OpenPeriodDto dto,
    required String patternId,
    required PatternMetadata patternMetadata,
    required DateTime now,
    required Uuid uuid,
  }) {
    final timeSlot = TimeSlot(
      slotId: uuid.v4(),
      startTime: dto.formattedStartTime,
      endTime: dto.formattedEndTime,
      status: 'available',
      valorHora: dto.pricePerHour,
      sourcePatternId: patternId,
    );

    // Verificar se já existe uma availability com o mesmo patternId
    final existingEntryIndex = existingDay.availabilities.indexWhere(
      (entry) => entry.generatedFrom?.patternId == patternId,
    );

    if (existingEntryIndex != -1) {
      // Adicionar slot à availability existente
      final existingEntry = existingDay.availabilities[existingEntryIndex];
      final updatedSlots = [...existingEntry.slots, timeSlot];
      
      final updatedEntry = existingEntry.copyWith(
        slots: updatedSlots,
        updatedAt: now,
      );

      final updatedAvailabilities = List<AvailabilityEntry>.from(
        existingDay.availabilities,
      );
      updatedAvailabilities[existingEntryIndex] = updatedEntry;

      return existingDay.copyWith(
        availabilities: updatedAvailabilities,
        updatedAt: now,
      );
    } else {
      // Criar nova availability
      final newEntry = AvailabilityEntry(
        availabilityId: uuid.v4(),
        generatedFrom: patternMetadata,
        addressId: dto.addressId,
        raioAtuacao: dto.raioAtuacao,
        endereco: dto.endereco,
        slots: [timeSlot],
        isManualOverride: false,
        createdAt: now,
      );

      return existingDay.copyWith(
        availabilities: [...existingDay.availabilities, newEntry],
        updatedAt: now,
      );
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
