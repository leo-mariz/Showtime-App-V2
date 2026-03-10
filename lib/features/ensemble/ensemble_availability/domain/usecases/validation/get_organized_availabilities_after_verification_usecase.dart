import 'package:app/core/domain/availability/availability_day_entity.dart';
import 'package:app/core/domain/availability/pattern_metadata_entity.dart';
import 'package:app/core/errors/error_handler.dart';
import 'package:app/core/errors/failure.dart';
import 'package:app/core/utils/availability_helpers.dart';
import 'package:app/features/availability/domain/dtos/check_overlaps_dto.dart';
import 'package:app/features/availability/domain/dtos/check_overlap_on_day_dto.dart';
import 'package:app/features/availability/domain/entities/day_overlap_info.dart';
import 'package:app/features/availability/domain/entities/organized_availabilities_after_verification_result_entity.dart';
import 'package:app/features/ensemble/ensemble_availability/domain/usecases/validation/get_organized_day_usecase.dart';
import 'package:dartz/dartz.dart';

/// Use Case para checagem de overlaps
///
/// Verifica overlaps de horários, diferenças de endereço e raio
/// para um padrão de recorrência.
class GetOrganizedEnsembleAvailabilitesAfterVerificationUseCase {
  final GetOrganizedEnsembleDayAfterVerificationUseCase getOrganizedDayAfterVerificationUseCase;

  GetOrganizedEnsembleAvailabilitesAfterVerificationUseCase({
    required this.getOrganizedDayAfterVerificationUseCase,
  });

  /// Verifica overlaps e diferenças
  ///
  /// **Retorna:**
  /// - `Right(CheckOverlapsResult)` com daysWithOverlap e daysWithoutOverlap
  /// - `Left(Failure)` se houver erro
  Future<Either<Failure, OrganizedAvailabilitiesAfterVerificationResult>> call(
    String ensembleId,
    CheckOverlapsDto dto,
    bool isClose,
  ) async {
    try {
      if (ensembleId.isEmpty) {
        return const Left(ValidationFailure('ID do conjunto é obrigatório'));
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

      for (var i = 0; i < validDates.length; i++) {
        final date = validDates[i];

        final result = await getOrganizedDayAfterVerificationUseCase(
          ensembleId,
          date,
          dayDto,
          isClose,
        );

        result.fold(
          (failure) => throw failure,
          (dayResult) {

            if (dayResult.hasChanges) {
              if (dayResult.overlapInfo != null) {
                daysWithOverlap.add(dayResult.overlapInfo!);
              }
            } else if (dayResult.dayEntity != null) {
              // Só adiciona se o dia existe
              if (dayResult.hasBookedSlot) {
                daysWithBookedSlot.add(dayResult.dayEntity!);
              } else {
                daysWithoutOverlap.add(dayResult.dayEntity!);
              }
            }
            // Se dayEntity é null, o dia não existe e não adiciona a nenhuma lista
          },
        );
      }

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
