import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/day_overlap_info.dart';

/// DTO para abrir um período de disponibilidade
/// 
/// Recebe um modelo base de AvailabilityDayEntity e uma lista de DayOverlapInfo
/// para processar cada data do padrão de recorrência.
class OpenPeriodDto {
  /// Modelo base de disponibilidade (será usado para criar dias sem overlap)
  final AvailabilityDayEntity baseAvailabilityDay;

  /// Lista de informações de overlaps para dias específicos
  final List<DayOverlapInfo> dayOverlapInfos;

  /// Lista de dias com slots reservados (não serão modificados)
  final List<AvailabilityDayEntity> daysWithBookedSlot;

  const OpenPeriodDto({
    required this.baseAvailabilityDay,
    required this.dayOverlapInfos,
    this.daysWithBookedSlot = const [],
  });
}
