import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/slot_overlap_info.dart';

/// Resultado da operação de abrir período
/// 
/// Contém os dias criados e informações sobre slots que tiveram overlap
class OpenPeriodResult {
  /// Lista de dias criados com sucesso
  final List<AvailabilityDayEntity> createdDays;

  /// Indica se há slots com overlap que não foram adicionados
  final bool hasOverlapSlots;

  /// Dicionário de overlaps por dia
  /// 
  /// Formato: { "YYYY-MM-DD": { "slotId": SlotOverlapInfo, ... } }
  /// 
  /// Exemplo:
  /// ```dart
  /// {
  ///   "2026-01-15": {
  ///     "slot-123": SlotOverlapInfo(slot: TimeSlot(...), overlapType: OverlapType.partialBefore),
  ///     "slot-456": SlotOverlapInfo(slot: TimeSlot(...), overlapType: OverlapType.contains),
  ///   },
  ///   "2026-01-16": {
  ///     "slot-789": SlotOverlapInfo(slot: TimeSlot(...), overlapType: OverlapType.exact),
  ///   },
  /// }
  /// ```
  final Map<String, Map<String, SlotOverlapInfo>> overlapsByDay;

  const OpenPeriodResult({
    required this.createdDays,
    required this.hasOverlapSlots,
    required this.overlapsByDay,
  });

  /// Factory para quando não há overlaps
  factory OpenPeriodResult.noOverlaps(
    List<AvailabilityDayEntity> createdDays,
  ) {
    return OpenPeriodResult(
      createdDays: createdDays,
      hasOverlapSlots: false,
      overlapsByDay: {},
    );
  }

  /// Factory para quando há overlaps
  factory OpenPeriodResult.withOverlaps(
    List<AvailabilityDayEntity> createdDays,
    Map<String, Map<String, SlotOverlapInfo>> overlapsByDay,
  ) {
    return OpenPeriodResult(
      createdDays: createdDays,
      hasOverlapSlots: true,
      overlapsByDay: overlapsByDay,
    );
  }

  /// Quantidade de dias criados
  int get daysCreatedCount => createdDays.length;

  /// Quantidade de dias com overlaps
  int get daysWithOverlapsCount => overlapsByDay.length;

  /// Total de slots com overlaps
  int get totalOverlapsCount {
    return overlapsByDay.values.fold<int>(
      0,
      (sum, slots) => sum + slots.length,
    );
  }
}
