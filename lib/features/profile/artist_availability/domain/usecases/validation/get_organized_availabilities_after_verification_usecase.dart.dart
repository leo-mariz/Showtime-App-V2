import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlaps_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlap_on_day_dto.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/profile/artist_availability/domain/entities/organized_availabilities_after_verification_result_entity.dart.dart';
import 'package:app/features/profile/artist_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Use Case para checagem de overlaps
/// 
/// Verifica overlaps de horários, diferenças de endereço e raio
/// para um padrão de recorrência.
class GetOrganizedAvailabilitesAfterVerificationUseCase {
  final GetOrganizedDayAfterVerificationUseCase getOrganizedDayAfterVerificationUseCase;

  GetOrganizedAvailabilitesAfterVerificationUseCase({
    required this.getOrganizedDayAfterVerificationUseCase,
  });

  /// Verifica overlaps e diferenças
  /// 
  /// **Retorna:**
  /// - `Right(CheckOverlapsResult)` com daysWithOverlap e daysWithoutOverlap
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, OrganizedAvailabilitiesAfterVerificationResult>> call(
    String artistId,
    CheckOverlapsDto dto,
    bool isClose,
  ) async {
    try {
      if (artistId.isEmpty) {
        return const Left(ValidationFailure('ID do artista é obrigatório'));
      }

      // ════════════════════════════════════════════════════════════════
      // 1. Gerar datas válidas do pattern
      // ════════════════════════════════════════════════════════════════
      final validDates = _generateValidDatesFromPattern(dto.patternMetadata!);

      // ════════════════════════════════════════════════════════════════
      // 2. Processar cada dia usando CheckOverlapOnDayUseCase
      // ════════════════════════════════════════════════════════════════
      final daysWithOverlap = <DayOverlapInfo>[];
      final daysWithoutOverlap = <AvailabilityDayEntity>[];
      final daysWithBookedSlot = <AvailabilityDayEntity>[];

      // Criar DTO para o usecase do dia
      final dayDto = CheckOverlapOnDayDto(
        endereco: dto.endereco,
        raioAtuacao: dto.raioAtuacao,
        valorHora: dto.valorHora,
        startTime: dto.startTime,
        endTime: dto.endTime,
        patternId: dto.patternMetadata?.patternId,
      );

      debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Processando ${validDates.length} datas - isClose: $isClose');
      debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] StartTime: ${dto.startTime}, EndTime: ${dto.endTime}');
      debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] ValorHora: ${dto.valorHora}');

      for (var i = 0; i < validDates.length; i++) {
        final date = validDates[i];
        debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Processando data[$i]: ${date.toString().split(' ')[0]}');
        
        final result = await getOrganizedDayAfterVerificationUseCase(
          artistId,
          date,
          dayDto,
          isClose,
        );

        result.fold(
          (failure) => throw failure,
          (dayResult) {
            debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Resultado[$i] - hasChanges: ${dayResult.hasChanges}, hasBookedSlot: ${dayResult.hasBookedSlot}');
            
            if (dayResult.hasChanges) {
              if (dayResult.overlapInfo != null) {
                debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Resultado[$i] - Adicionando a daysWithOverlap');
                debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Resultado[$i] - NewSlots: ${dayResult.overlapInfo!.newTimeSlots?.length ?? 0}');
                daysWithOverlap.add(dayResult.overlapInfo!);
              }
            } else if (dayResult.dayEntity != null) {
              // Só adiciona se o dia existe
              if (dayResult.hasBookedSlot) {
                debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Resultado[$i] - Adicionando a daysWithBookedSlot');
                daysWithBookedSlot.add(dayResult.dayEntity!);
              } else {
                debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Resultado[$i] - Adicionando a daysWithoutOverlap');
                daysWithoutOverlap.add(dayResult.dayEntity!);
              }
            } 
            // Se dayEntity é null, o dia não existe e não adiciona a nenhuma lista
          },
        );
      }
      
      debugPrint('🟣 [GET_ORGANIZED_AVAILABILITIES] Final - daysWithOverlap: ${daysWithOverlap.length}, daysWithBookedSlot: ${daysWithBookedSlot.length}, daysWithoutOverlap: ${daysWithoutOverlap.length}');

      // ════════════════════════════════════════════════════════════════
      // 3. Retornar resultado
      // ════════════════════════════════════════════════════════════════
      return Right(OrganizedAvailabilitiesAfterVerificationResult(
        daysWithOverlap: daysWithOverlap,
        daysWithoutOverlap: daysWithoutOverlap,
        daysWithBookedSlot: daysWithBookedSlot,
      ));
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  /// Gera datas válidas a partir do patternMetadata
  List<DateTime> _generateValidDatesFromPattern(PatternMetadata patternMetadata) {
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
}
