import 'package:dart_mappable/dart_mappable.dart';

part 'blocked_time_slot.mapper.dart';

/// Representa um bloqueio de horário específico em uma disponibilidade
/// 
/// Usado quando o artista precisa indisponibilizar um horário específico
/// dentro de uma disponibilidade (ex: show particular, compromisso pessoal)
@MappableClass()
class BlockedTimeSlot with BlockedTimeSlotMappable {
  /// Data específica do bloqueio
  final DateTime date;
  
  /// Horário de início do bloqueio (formato: "HH:mm")
  final String startTime;
  
  /// Horário de fim do bloqueio (formato: "HH:mm")
  final String endTime;
  
  /// Observação opcional sobre o bloqueio
  final String? note;
  
  BlockedTimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.note,
  });
}

