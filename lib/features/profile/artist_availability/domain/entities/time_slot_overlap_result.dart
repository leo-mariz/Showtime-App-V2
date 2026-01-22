import 'package:flutter/material.dart';
import 'package:app/features/profile/artist_availability/domain/entities/overlap_type.dart';

/// Resultado da validação de sobreposição de horários
class TimeSlotOverlapResult {
  /// Indica se há sobreposição
  final bool hasOverlap;

  /// Lista de slots conflitantes (se houver)
  final List<ConflictingTimeSlot> conflictingSlots;

  const TimeSlotOverlapResult({
    required this.hasOverlap,
    required this.conflictingSlots,
  });

  /// Factory para quando NÃO há sobreposição
  factory TimeSlotOverlapResult.noOverlap() {
    return const TimeSlotOverlapResult(
      hasOverlap: false,
      conflictingSlots: [],
    );
  }

  /// Factory para quando HÁ sobreposição
  factory TimeSlotOverlapResult.withOverlap(
    List<ConflictingTimeSlot> conflictingSlots,
  ) {
    return TimeSlotOverlapResult(
      hasOverlap: true,
      conflictingSlots: conflictingSlots,
    );
  }

  /// Mensagem de erro formatada
  String get errorMessage {
    if (!hasOverlap) return '';

    if (conflictingSlots.length == 1) {
      final slot = conflictingSlots.first;
      return 'Este horário se sobrepõe ao slot de '
          '${slot.formattedStartTime} - ${slot.formattedEndTime} '
          '(R\$ ${slot.formattedPrice})';
    }

    return 'Este horário se sobrepõe a ${conflictingSlots.length} slots existentes';
  }

  /// Descrição detalhada de todos os conflitos
  String get detailedErrorMessage {
    if (!hasOverlap) return '';

    final buffer = StringBuffer('Sobreposições encontradas:\n\n');
    
    for (var i = 0; i < conflictingSlots.length; i++) {
      final slot = conflictingSlots[i];
      buffer.write('${i + 1}. ${slot.formattedStartTime} - '
          '${slot.formattedEndTime} (R\$ ${slot.formattedPrice})');
      
      if (i < conflictingSlots.length - 1) {
        buffer.write('\n');
      }
    }

    return buffer.toString();
  }
}

/// Representa um slot que está em conflito com o horário sendo validado
class ConflictingTimeSlot {
  /// ID do slot conflitante
  final String slotId;

  /// ID da entry que contém este slot
  final String entryId;

  /// Horário de início
  final TimeOfDay startTime;

  /// Horário de fim
  final TimeOfDay endTime;

  /// Preço por hora
  final double pricePerHour;

  /// Tipo de sobreposição
  final OverlapType overlapType;

  const ConflictingTimeSlot({
    required this.slotId,
    required this.entryId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.overlapType,
  });

  /// Formata horário de início (ex: "14:00")
  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:'
        '${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formata horário de fim (ex: "18:00")
  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formata preço (ex: "250,00")
  String get formattedPrice {
    return pricePerHour.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Retorna o intervalo formatado (ex: "14:00 - 18:00")
  String get formattedInterval => '$formattedStartTime - $formattedEndTime';

  /// Calcula duração em minutos
  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  /// Calcula duração em horas (decimal)
  double get durationInHours => durationInMinutes / 60.0;

  /// Calcula o preço total do slot
  double get totalPrice => pricePerHour * durationInHours;
}
