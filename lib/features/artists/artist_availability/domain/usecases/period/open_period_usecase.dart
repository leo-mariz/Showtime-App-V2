import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/availability/pattern_metadata_entity.dart';
import 'package:app/core/domain/availability/time_slot_entity.dart';
import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/create_availability_day_usecase.dart';
import 'package:app/features/artists/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Use Case para abrir um período de disponibilidade
/// 
/// Gera todas as datas do patternMetadata e para cada data:
/// - Se não existe em dayOverlapInfos: cria usando baseAvailabilityDay
/// - Se existe em dayOverlapInfos: atualiza usando informações do DayOverlapInfo
class OpenPeriodUseCase {
  final CreateAvailabilityDayUseCase createAvailabilityDayUseCase;
  final UpdateAvailabilityDayUseCase updateAvailabilityDayUseCase;

  OpenPeriodUseCase({
    required this.createAvailabilityDayUseCase,
    required this.updateAvailabilityDayUseCase,
  });

  /// Abre o período de disponibilidade
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `dto`: DTO com modelo base e informações de overlaps
  /// 
  /// **Retorna:**
  /// - `Right(List<AvailabilityDayEntity>)` com os dias criados/atualizados
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    OpenPeriodDto dto,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Gerar datas válidas do patternMetadata
      // ════════════════════════════════════════════════════════════════
      final patternMetadata = dto.baseAvailabilityDay.patternMetadata;
      if (patternMetadata == null || patternMetadata.isEmpty) {
        return const Left(
          ValidationFailure('patternMetadata é obrigatório no baseAvailabilityDay'),
        );
      }

      // Usar o primeiro patternMetadata para gerar as datas
      final firstPattern = patternMetadata.first;
      if (firstPattern.recurrence == null) {
        return const Left(
          ValidationFailure('recurrence é obrigatório no patternMetadata'),
        );
      }

      final validDates = _generateValidDatesFromPattern(firstPattern);

      debugPrint('🟢 [OPEN_PERIOD] Iniciando abertura de período');
      debugPrint('🟢 [OPEN_PERIOD] ArtistId: $artistId');
      debugPrint('🟢 [OPEN_PERIOD] StartDate: ${firstPattern.recurrence?.originalStartDate}');
      debugPrint('🟢 [OPEN_PERIOD] EndDate: ${firstPattern.recurrence?.originalEndDate}');
      debugPrint('🟢 [OPEN_PERIOD] Weekdays: ${firstPattern.recurrence?.weekdays}');
      debugPrint('🟢 [OPEN_PERIOD] ValidDates geradas: ${validDates.length}');
      for (var i = 0; i < validDates.length; i++) {
        debugPrint('🟢 [OPEN_PERIOD] ValidDate[$i]: ${validDates[i].toString().split(' ')[0]}');
      }

      if (validDates.isEmpty) {
        debugPrint('🔴 [OPEN_PERIOD] ERRO: Nenhuma data válida encontrada no padrão');
        return const Left(
          ValidationFailure('Nenhuma data válida encontrada no padrão'),
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 2. Criar mapa de overlaps por data para busca rápida
      // ════════════════════════════════════════════════════════════════
      final overlapMap = <DateTime, DayOverlapInfo>{};
      debugPrint('🟢 [OPEN_PERIOD] dayOverlapInfos recebidos: ${dto.dayOverlapInfos.length}');
      for (final overlapInfo in dto.dayOverlapInfos) {
        // Normalizar a data (remover hora) para comparação
        final normalizedDate = DateTime(
          overlapInfo.date.year,
          overlapInfo.date.month,
          overlapInfo.date.day,
        );
        overlapMap[normalizedDate] = overlapInfo;
        debugPrint('🟢 [OPEN_PERIOD] OverlapInfo adicionado ao mapa: ${normalizedDate.toString().split(' ')[0]}');
      }

      // ════════════════════════════════════════════════════════════════
      // 2.1. Criar mapa de dias com slots reservados para busca rápida
      // ════════════════════════════════════════════════════════════════
      final bookedSlotMap = <DateTime, AvailabilityDayEntity>{};
      debugPrint('🟢 [OPEN_PERIOD] daysWithBookedSlot recebidos: ${dto.daysWithBookedSlot.length}');
      for (final dayEntity in dto.daysWithBookedSlot) {
        // Normalizar a data (remover hora) para comparação
        final normalizedDate = DateTime(
          dayEntity.date.year,
          dayEntity.date.month,
          dayEntity.date.day,
        );
        bookedSlotMap[normalizedDate] = dayEntity;
        debugPrint('🟢 [OPEN_PERIOD] BookedSlot adicionado ao mapa: ${normalizedDate.toString().split(' ')[0]}');
      }

      // ════════════════════════════════════════════════════════════════
      // 3. Processar cada data
      // ════════════════════════════════════════════════════════════════
      final createdDays = <AvailabilityDayEntity>[];

      debugPrint('🟢 [OPEN_PERIOD] Iniciando processamento de ${validDates.length} datas');

      for (var i = 0; i < validDates.length; i++) {
        final date = validDates[i];
        // Normalizar a data para comparação
        final normalizedDate = DateTime(
          date.year,
          date.month,
          date.day,
        );

        debugPrint('🟢 [OPEN_PERIOD] Processando data[$i]: ${normalizedDate.toString().split(' ')[0]}');

        // ════════════════════════════════════════════════════════════
        // 3.0. Verificar se o dia tem slot reservado - se sim, pular
        // ════════════════════════════════════════════════════════════
        if (bookedSlotMap.containsKey(normalizedDate)) {
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - PULANDO (tem booked slot)');
          // Dia tem slot reservado, não modificar
          continue;
        }

        final overlapInfo = overlapMap[normalizedDate];

        if (overlapInfo == null) {
          // ════════════════════════════════════════════════════════════
          // 3.1. Data não tem overlap - criar usando modelo base
          // ════════════════════════════════════════════════════════════
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - SEM OVERLAP - Criando dia usando modelo base');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - BaseDay slots: ${dto.baseAvailabilityDay.slots?.length ?? 0}');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - BaseDay endereco: ${dto.baseAvailabilityDay.endereco?.title ?? 'Não definido'}');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - BaseDay raio: ${dto.baseAvailabilityDay.raioAtuacao}');
          
          // Gerar slots a partir do patternMetadata
          final slots = _generateSlotsFromPattern(firstPattern);
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Slots gerados do pattern: ${slots.length}');
          
          final newDay = dto.baseAvailabilityDay.copyWith(
            date: normalizedDate,
            slots: slots,
            updatedAt: DateTime.now(),
            isActive: true,
          );

          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Chamando createAvailabilityDayUseCase');
          final createResult = await createAvailabilityDayUseCase(
            artistId,
            newDay,
          );

          createResult.fold(
            (failure) {
              debugPrint('🔴 [OPEN_PERIOD] Data[$i] - ERRO ao criar: ${failure.message}');
              throw failure;
            },
            (createdDay) {
              debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Sucesso! Dia criado com ${createdDay.slots?.length ?? 0} slots');
              createdDays.add(createdDay);
            },
          );
        } else {
          // ════════════════════════════════════════════════════════════
          // 3.2. Data tem overlap - criar usando informações do overlap
          // ════════════════════════════════════════════════════════════
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - COM OVERLAP - Criando dia usando informações do overlap');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Overlap hasOverlap: ${overlapInfo.hasOverlap}');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Overlap oldSlots: ${overlapInfo.oldTimeSlots?.length ?? 0}');
          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Overlap newSlots: ${overlapInfo.newTimeSlots?.length ?? 0}');
          
          final updatedDay = _createDayFromOverlapInfo(
            baseDay: dto.baseAvailabilityDay,
            overlapInfo: overlapInfo,
            date: normalizedDate,
          );

          debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Chamando updateAvailabilityDayUseCase');
          final updateResult = await updateAvailabilityDayUseCase(
            artistId,
            updatedDay,
          );

          updateResult.fold(
            (failure) {
              debugPrint('🔴 [OPEN_PERIOD] Data[$i] - ERRO ao atualizar: ${failure.message}');
              throw failure;
            },
            (updatedDayEntity) {
              debugPrint('🟢 [OPEN_PERIOD] Data[$i] - Sucesso! Dia atualizado com ${updatedDayEntity.slots?.length ?? 0} slots');
              createdDays.add(updatedDayEntity);
            },
          );
        }
      }

      // ════════════════════════════════════════════════════════════════
      // 4. Retornar lista de dias criados/atualizados
      // ════════════════════════════════════════════════════════════════
      debugPrint('🟢 [OPEN_PERIOD] Finalizado - Total de dias criados/atualizados: ${createdDays.length}');
      return Right(createdDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Gera datas válidas a partir do patternMetadata
  List<DateTime> _generateValidDatesFromPattern(
    PatternMetadata patternMetadata,
  ) {
    if (patternMetadata.recurrence == null) {
      return [];
    }

    final recurrence = patternMetadata.recurrence!;
    return AvailabilityHelpers.generateValidDates(
      startDate: recurrence.originalStartDate,
      endDate: recurrence.originalEndDate,
      weekdays: recurrence.weekdays,
    );
  }

  /// Cria um AvailabilityDayEntity a partir das informações de overlap
  AvailabilityDayEntity _createDayFromOverlapInfo({
    required AvailabilityDayEntity baseDay,
    required DayOverlapInfo overlapInfo,
    required DateTime date,
  }) {
    // Usar novos slots se disponíveis, senão usar slots antigos
    final slots = overlapInfo.newTimeSlots ?? overlapInfo.oldTimeSlots ?? [];

    // Usar novo endereço se disponível, senão usar endereço antigo ou base
    final endereco = overlapInfo.newAddress ??
        overlapInfo.oldAddress ??
        baseDay.endereco;

    // Usar novo raio se disponível, senão usar raio antigo ou base
    final raioAtuacao = overlapInfo.newRadius ??
        overlapInfo.oldRadius ??
        baseDay.raioAtuacao;

    return baseDay.copyWith(
      date: date,
      slots: slots,
      endereco: endereco,
      raioAtuacao: raioAtuacao,
      updatedAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Gera slots a partir do patternMetadata
  /// 
  /// Cria um slot baseado nas informações de horário e valor do patternMetadata
  List<TimeSlot> _generateSlotsFromPattern(PatternMetadata patternMetadata) {
    if (patternMetadata.recurrence == null) {
      debugPrint('🟢 [OPEN_PERIOD] _generateSlotsFromPattern - Recurrence é null');
      return [];
    }

    final recurrence = patternMetadata.recurrence!;
    
    // Usar horários do recurrence (sempre preenchidos, mesmo quando "Todos os horários" = 00:00-23:59)
    final startTime = recurrence.originalStartTime;
    final endTime = recurrence.originalEndTime;
    final valorHora = recurrence.originalValorHora;

    debugPrint('🟢 [OPEN_PERIOD] _generateSlotsFromPattern - StartTime: $startTime, EndTime: $endTime, ValorHora: $valorHora');

    // Se startTime e endTime são iguais ou inválidos, não criar slot
    if (startTime.isEmpty || endTime.isEmpty || startTime == endTime) {
      debugPrint('🟢 [OPEN_PERIOD] _generateSlotsFromPattern - Horários inválidos, não criando slot');
      return [];
    }

    const uuid = Uuid();
    final slot = TimeSlot(
      slotId: uuid.v4(),
      startTime: startTime,
      endTime: endTime,
      status: TimeSlotStatusEnum.available,
      valorHora: valorHora,
      sourcePatternId: patternMetadata.patternId,
    );

    debugPrint('🟢 [OPEN_PERIOD] _generateSlotsFromPattern - Slot criado: ${slot.startTime}-${slot.endTime}, R\$ ${slot.valorHora}');
    return [slot];
  }
}
