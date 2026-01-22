import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/slot_overlap_info.dart';

/// Resultado da operação de adicionar slot
/// 
/// Contém o dia atualizado e informações sobre slots que tiveram overlap
class AddTimeSlotResult {
  /// Dia atualizado (com o novo slot adicionado, se não houver overlap)
  final AvailabilityDayEntity? updatedDay;

  /// Indica se há slots com overlap que impediram a adição
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
  /// }
  /// ```
  final Map<String, Map<String, SlotOverlapInfo>> overlapsByDay;

  const AddTimeSlotResult({
    this.updatedDay,
    required this.hasOverlapSlots,
    required this.overlapsByDay,
  });

  /// Factory para quando não há overlaps (slot adicionado com sucesso)
  factory AddTimeSlotResult.success(
    AvailabilityDayEntity updatedDay,
  ) {
    return AddTimeSlotResult(
      updatedDay: updatedDay,
      hasOverlapSlots: false,
      overlapsByDay: {},
    );
  }

  /// Factory para quando há overlaps (slot não foi adicionado)
  factory AddTimeSlotResult.withOverlaps(
    String dayId,
    Map<String, SlotOverlapInfo> overlaps,
  ) {
    return AddTimeSlotResult(
      updatedDay: null,
      hasOverlapSlots: true,
      overlapsByDay: {dayId: overlaps},
    );
  }

  /// Total de slots com overlaps
  int get totalOverlapsCount {
    return overlapsByDay.values.fold<int>(
      0,
      (sum, slots) => sum + slots.length,
    );
  }
}
