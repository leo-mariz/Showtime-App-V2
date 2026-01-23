import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/day/update_availability_day_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Use Case para fechar um período de disponibilidade
/// 
/// Recebe um OpenPeriodDto e atualiza cada dia usando as informações
/// de DayOverlapInfo. Dias com slots reservados são ignorados.
class ClosePeriodUseCase {
  final UpdateAvailabilityDayUseCase updateAvailabilityDayUseCase;

  ClosePeriodUseCase({
    required this.updateAvailabilityDayUseCase,
  });

  /// Fecha o período de disponibilidade
  /// 
  /// **Parâmetros:**
  /// - `artistId`: ID do artista
  /// - `dto`: DTO com informações de overlaps para cada dia
  /// 
  /// **Retorna:**
  /// - `Right(List<AvailabilityDayEntity>)` com os dias atualizados
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, List<AvailabilityDayEntity>>> call(
    String artistId,
    OpenPeriodDto dto,
  ) async {
    try {
      debugPrint('⚫ [CLOSE_PERIOD] Iniciando fechamento de período');
      debugPrint('⚫ [CLOSE_PERIOD] ArtistId: $artistId');
      debugPrint('⚫ [CLOSE_PERIOD] dayOverlapInfos: ${dto.dayOverlapInfos.length}');
      debugPrint('⚫ [CLOSE_PERIOD] daysWithBookedSlot: ${dto.daysWithBookedSlot.length}');
      
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Criar mapa de dias com slots reservados para busca rápida
      // ════════════════════════════════════════════════════════════════
      final bookedSlotMap = <DateTime, AvailabilityDayEntity>{};
      for (final dayEntity in dto.daysWithBookedSlot) {
        // Normalizar a data (remover hora) para comparação
        final normalizedDate = DateTime(
          dayEntity.date.year,
          dayEntity.date.month,
          dayEntity.date.day,
        );
        bookedSlotMap[normalizedDate] = dayEntity;
        debugPrint('⚫ [CLOSE_PERIOD] Dia com booked slot: ${normalizedDate.toString().split(' ')[0]}');
      }

      // ════════════════════════════════════════════════════════════════
      // 2. Processar cada DayOverlapInfo e atualizar o dia
      // ════════════════════════════════════════════════════════════════
      final updatedDays = <AvailabilityDayEntity>[];

      for (var i = 0; i < dto.dayOverlapInfos.length; i++) {
        final overlapInfo = dto.dayOverlapInfos[i];
        // Normalizar a data para comparação
        final normalizedDate = DateTime(
          overlapInfo.date.year,
          overlapInfo.date.month,
          overlapInfo.date.day,
        );

        debugPrint('⚫ [CLOSE_PERIOD] Processando overlap[$i] - Date: ${normalizedDate.toString().split(' ')[0]}');
        debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - hasOverlap: ${overlapInfo.hasOverlap}');
        debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - OldSlots: ${overlapInfo.oldTimeSlots?.length ?? 0}');
        debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - NewSlots: ${overlapInfo.newTimeSlots?.length ?? 0}');

        // ════════════════════════════════════════════════════════════
        // 2.1. Verificar se o dia tem slot reservado - se sim, pular
        // ════════════════════════════════════════════════════════════
        if (bookedSlotMap.containsKey(normalizedDate)) {
          debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - PULANDO (tem booked slot)');
          // Dia tem slot reservado, não modificar
          continue;
        }

        // ════════════════════════════════════════════════════════════
        // 2.2. Criar AvailabilityDayEntity a partir do DayOverlapInfo
        // ════════════════════════════════════════════════════════════
        final updatedDay = _createDayFromOverlapInfo(
          baseDay: dto.baseAvailabilityDay,
          overlapInfo: overlapInfo,
          date: normalizedDate,
        );

        debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - Dia criado com ${updatedDay.slots?.length ?? 0} slots');
        for (var j = 0; j < updatedDay.slots!.length; j++) {
          final slot = updatedDay.slots![j];
          debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - Slot[$j]: ${slot.startTime}-${slot.endTime}, status: ${slot.status}, valorHora: ${slot.valorHora}');
        }

        // ════════════════════════════════════════════════════════════
        // 2.3. Atualizar o dia usando o usecase
        // ════════════════════════════════════════════════════════════
        debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - Chamando updateAvailabilityDayUseCase');
        final updateResult = await updateAvailabilityDayUseCase(
          artistId,
          updatedDay,
        );

        updateResult.fold(
          (failure) {
            debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - ERRO ao atualizar: ${failure.message}');
            throw failure;
          },
          (updatedDayEntity) {
            debugPrint('⚫ [CLOSE_PERIOD] Overlap[$i] - Sucesso! Dia atualizado com ${updatedDayEntity.slots?.length ?? 0} slots');
            updatedDays.add(updatedDayEntity);
          },
        );
      }

      // ════════════════════════════════════════════════════════════════
      // 3. Retornar lista de dias atualizados
      // ════════════════════════════════════════════════════════════════
      debugPrint('⚫ [CLOSE_PERIOD] Finalizado - Total de dias atualizados: ${updatedDays.length}');
      return Right(updatedDays);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Cria um AvailabilityDayEntity a partir das informações de overlap
  AvailabilityDayEntity _createDayFromOverlapInfo({
    required AvailabilityDayEntity baseDay,
    required DayOverlapInfo overlapInfo,
    required DateTime date,
  }) {
    // Usar novos slots se disponíveis, senão usar slots antigos
    final slots = overlapInfo.newTimeSlots ?? overlapInfo.oldTimeSlots ?? [];

    debugPrint('⚫ [CLOSE_PERIOD] _createDayFromOverlapInfo - Date: ${date.toString().split(' ')[0]}');
    debugPrint('⚫ [CLOSE_PERIOD] _createDayFromOverlapInfo - Usando newTimeSlots: ${overlapInfo.newTimeSlots != null}');
    debugPrint('⚫ [CLOSE_PERIOD] _createDayFromOverlapInfo - Total de slots: ${slots.length}');

    // ════════════════════════════════════════════════════════════════
    // REGRA: Se não houver slots, o dia DEVE estar inativo
    // ════════════════════════════════════════════════════════════════
    final isActive = slots.isNotEmpty ? baseDay.isActive : false;
    
    if (slots.isEmpty) {
      debugPrint('⚫ [CLOSE_PERIOD] _createDayFromOverlapInfo - Sem slots, forçando isActive = false');
    }

    // Usar novo endereço se disponível, senão usar endereço antigo ou base
    final endereco = overlapInfo.newAddress ??
        overlapInfo.oldAddress ??
        baseDay.endereco;

    // Usar novo raio se disponível, senão usar raio antigo ou base
    final raioAtuacao = overlapInfo.newRadius ??
        overlapInfo.oldRadius ??
        baseDay.raioAtuacao;

    final createdDay = baseDay.copyWith(
      date: date,
      slots: slots,
      endereco: endereco,
      raioAtuacao: raioAtuacao,
      updatedAt: DateTime.now(),
      isActive: isActive,
    );
    
    debugPrint('⚫ [CLOSE_PERIOD] _createDayFromOverlapInfo - Dia criado com ${createdDay.slots?.length ?? 0} slots');
    
    return createdDay;
  }
}
