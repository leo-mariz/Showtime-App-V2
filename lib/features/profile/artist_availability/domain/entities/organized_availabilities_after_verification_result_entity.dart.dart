import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';

/// Resultado da checagem de overlaps
class OrganizedAvailabilitiesAfterVerificationResult {
  /// Dias com overlaps ou diferenças (endereço/raio)
  final List<DayOverlapInfo> daysWithOverlap;

  /// Dias sem overlaps nem diferenças
  final List<AvailabilityDayEntity> daysWithoutOverlap;

  /// Dias com slots reservados
  final List<AvailabilityDayEntity> daysWithBookedSlot;

  const OrganizedAvailabilitiesAfterVerificationResult({
    required this.daysWithOverlap,
    required this.daysWithoutOverlap,
    required this.daysWithBookedSlot,
  });

  /// Total de dias processados
  int get totalDays => daysWithOverlap.length + daysWithoutOverlap.length;

  /// Quantidade de dias com overlaps
  int get daysWithOverlapCount => daysWithOverlap.length;

  /// Quantidade de dias sem overlaps
  int get daysWithoutOverlapCount => daysWithoutOverlap.length;
}
