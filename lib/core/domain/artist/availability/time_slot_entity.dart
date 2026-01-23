import 'package:app/core/enums/time_slot_status_enum.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'time_slot_entity.mapper.dart';

/// Representa um slot de tempo específico dentro de um dia
/// 
/// Um slot pode estar disponível, bloqueado ou reservado
@MappableClass()
class TimeSlot with TimeSlotMappable {
  /// ID único do slot
  final String slotId;
  
  /// Horário de início (formato: "HH:mm")
  final String startTime;
  
  /// Horário de fim (formato: "HH:mm")
  final String endTime;
  
  /// Status do slot: available, booked
  final TimeSlotStatusEnum status;
  
  /// Valor por hora (apenas se status = available)
  final double? valorHora;
  
  /// ID da reserva (apenas se status = booked)
  final String? contractId;
  
  /// ID do padrão que gerou este slot (se foi gerado de um padrão)
  final String? sourcePatternId;
  
  const TimeSlot({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.valorHora,
    this.contractId,
    this.sourcePatternId,
  });
  
  /// Duração do slot em minutos
  int get durationInMinutes {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes - startMinutes;
  }
  
  /// Verifica se o slot está disponível para reserva
  bool get isAvailable => status == TimeSlotStatusEnum.available;
  
  /// Verifica se o slot está reservado
  bool get isBooked => status == TimeSlotStatusEnum.booked;
}
