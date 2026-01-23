import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';

/// Informações sobre overlaps e diferenças de um dia
class DayOverlapInfo {
  /// Data do dia
  final DateTime date;

  /// Indica se há overlap de horários
  final bool hasOverlap;

  /// Indica se o endereço é diferente
  final bool isAddressDifferent;

  /// Indica se o raio é diferente
  final bool isRadiusDifferent;

  /// Novo endereço (se isAddressDifferent = true)
  final AddressInfoEntity? newAddress;

  /// Endereço antigo (se isAddressDifferent = true)
  final AddressInfoEntity? oldAddress;

  /// Novo raio (se isRadiusDifferent = true)
  final double? newRadius;

  /// Raio antigo (se isRadiusDifferent = true)
  final double? oldRadius;

  /// Novos slots (após processamento de overlaps)
  final List<TimeSlot>? newTimeSlots;

  /// Slots antigos (originais do dia)
  final List<TimeSlot>? oldTimeSlots;

  const DayOverlapInfo({
    required this.date,
    required this.hasOverlap,
    required this.isAddressDifferent,
    required this.isRadiusDifferent,
    this.newAddress,
    this.oldAddress,
    this.newRadius,
    this.oldRadius,
    this.newTimeSlots,
    this.oldTimeSlots,
  });
}
