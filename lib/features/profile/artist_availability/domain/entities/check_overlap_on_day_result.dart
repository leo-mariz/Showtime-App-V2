import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';

/// Resultado da checagem de overlaps em um único dia
class OrganizedDayAfterVerificationResult {
  /// Indica se há mudanças (overlaps ou diferenças)
  final bool hasChanges;

  /// Indica se há um slot reservado (booked) que impede alterações
  final bool hasBookedSlot;   

  /// Informações de overlaps e diferenças (se hasChanges = true)
  final DayOverlapInfo? overlapInfo;

  /// Entidade do dia atualizada (se hasChanges = false e dia existe)
  final AvailabilityDayEntity? dayEntity;

  const OrganizedDayAfterVerificationResult({
    required this.hasChanges,
    required this.hasBookedSlot,
    this.overlapInfo,
    this.dayEntity,
  });

  /// Factory para quando há mudanças
  factory OrganizedDayAfterVerificationResult.withChanges(DayOverlapInfo overlapInfo) {
    return OrganizedDayAfterVerificationResult(
      hasChanges: true,
      hasBookedSlot: false,
      overlapInfo: overlapInfo,
      dayEntity: null,
    );
  }

  /// Factory para quando não há mudanças
  factory OrganizedDayAfterVerificationResult.withoutChanges(AvailabilityDayEntity dayEntity) {
    return OrganizedDayAfterVerificationResult(
      hasChanges: false,
      hasBookedSlot: false,
      overlapInfo: null,
      dayEntity: dayEntity,
    );
  }

  /// Factory para quando há um slot reservado que impede alterações
  factory OrganizedDayAfterVerificationResult.withBookedSlot(AvailabilityDayEntity dayEntity) {
    return OrganizedDayAfterVerificationResult(
      hasChanges: false,
      hasBookedSlot: true,
      overlapInfo: null,
      dayEntity: dayEntity,
    );
  }

  /// Factory para quando o dia não existe
  factory OrganizedDayAfterVerificationResult.dayNotFound() {
    return const OrganizedDayAfterVerificationResult(
      hasChanges: false,
      hasBookedSlot: false,
      overlapInfo: null,
      dayEntity: null,
    );
  }
}
