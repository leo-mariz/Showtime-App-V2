import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/overlap_type.dart';

/// Informações sobre um slot que está em overlap
class SlotOverlapInfo {
  /// O slot que está em overlap
  final TimeSlot slot;

  /// O tipo de overlap
  final OverlapType overlapType;

  const SlotOverlapInfo({
    required this.slot,
    required this.overlapType,
  });
}
