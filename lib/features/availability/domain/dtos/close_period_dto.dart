import 'package:flutter/material.dart';

/// DTO para fechar/bloquear um período de disponibilidade
class ClosePeriodDto {
  /// Data de início do período a ser bloqueado
  final DateTime startDate;

  /// Data de fim do período a ser bloqueado
  final DateTime endDate;

  /// Horário de início do bloqueio (ex: 16:00)
  final TimeOfDay startTime;

  /// Horário de fim do bloqueio (ex: 20:00)
  final TimeOfDay endTime;

  /// Dias da semana específicos (opcional)
  /// Se null, processa todos os dias
  /// Ex: ['MO', 'TU', 'WE'] para segunda, terça e quarta
  final List<String>? weekdays;

  /// Motivo do bloqueio (ex: "Férias", "Compromisso pessoal")
  final String blockReason;

  const ClosePeriodDto({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    this.weekdays,
    required this.blockReason,
  });

  /// Formata horário para string "HH:mm"
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formata horário para string "HH:mm"
  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';
  }
}
