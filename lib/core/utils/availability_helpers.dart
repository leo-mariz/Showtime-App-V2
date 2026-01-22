import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/features/profile/artist_availability/domain/entities/overlap_type.dart';

/// Classe utilitária para operações relacionadas à disponibilidade de artistas
/// 
/// Contém helpers para:
/// - Gerar dias válidos baseados em patterns
/// - Validar sobreposição de intervalos de horário
/// - Gerar novos slots ajustados baseados em overlaps
class AvailabilityHelpers {
  /// Construtor privado para evitar instanciação
  AvailabilityHelpers._();

  /// Gera lista de dias válidos baseado em um pattern
  /// 
  /// Recebe um período (data inicial e final) e opcionalmente uma lista de dias da semana.
  /// Retorna apenas as datas dentro do período que correspondem aos dias da semana especificados.
  /// 
  /// **Exemplo:**
  /// ```dart
  /// // Gerar dias válidos para terças e quintas entre 20/01 e 20/02
  /// final validDays = AvailabilityHelpers.generateValidDates(
  ///   startDate: DateTime(2026, 1, 20),
  ///   endDate: DateTime(2026, 2, 20),
  ///   weekdays: ['TU', 'TH'], // Terças e Quintas
  /// );
  /// 
  /// // Retorna: [2026-01-21 (terça), 2026-01-23 (quinta), 2026-01-28 (terça), ...]
  /// ```
  static List<DateTime> generateValidDates({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? weekdays,
  }) {
    final validDays = <DateTime>[];

    // Normalizar datas (remover hora)
    DateTime currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    // Se não há filtro de dias da semana, retornar todos os dias
    if (weekdays == null || weekdays.isEmpty) {
      while (!currentDate.isAfter(normalizedEndDate)) {
        validDays.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      return validDays;
    }

    // Converter códigos de dias da semana para números do DateTime
    final validWeekdays = weekdays.map((code) => _codeToWeekday(code)).toSet();

    // Iterar sobre o período e filtrar por dias da semana
    while (!currentDate.isAfter(normalizedEndDate)) {
      // Verificar se o dia da semana atual está na lista de válidos
      if (validWeekdays.contains(currentDate.weekday)) {
        validDays.add(currentDate);
      }

      // Avançar para o próximo dia
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return validDays;
  }

  /// Valida sobreposição entre dois intervalos de horário
  /// 
  /// Recebe dois intervalos (novo e antigo) e retorna o tipo de sobreposição,
  /// ou `null` se não houver sobreposição.
  /// 
  /// **Regras de Sobreposição:**
  /// - Dois slots se sobrepõem se: `start1 < end2 && end1 > start2`
  /// - Horários adjacentes (ex: 12:00-16:00 e 16:00-20:00) NÃO se sobrepõem
  /// 
  /// **Exemplos:**
  /// ```dart
  /// // Sobreposição parcial (antes)
  /// AvailabilityHelpers.validateTimeSlotOverlap(
  ///   newStart: TimeOfDay(hour: 13, minute: 0),
  ///   newEnd: TimeOfDay(hour: 19, minute: 0),
  ///   existingStart: TimeOfDay(hour: 16, minute: 0),
  ///   existingEnd: TimeOfDay(hour: 20, minute: 0),
  /// ); // Retorna: OverlapType.partialBefore
  /// 
  /// // Sem sobreposição
  /// AvailabilityHelpers.validateTimeSlotOverlap(
  ///   newStart: TimeOfDay(hour: 8, minute: 0),
  ///   newEnd: TimeOfDay(hour: 12, minute: 0),
  ///   existingStart: TimeOfDay(hour: 12, minute: 0),
  ///   existingEnd: TimeOfDay(hour: 16, minute: 0),
  /// ); // Retorna: null
  /// ```
  /// 
  /// **Parâmetros:**
  /// - `newStart`/`newEnd`: Horários do novo intervalo
  /// - `existingStart`/`existingEnd`: Horários do intervalo existente
  /// 
  /// **Retorna:**
  /// - `OverlapType` se houver sobreposição
  /// - `null` se não houver sobreposição
  static OverlapType? validateTimeSlotOverlap({
    required TimeOfDay newStart,
    required TimeOfDay newEnd,
    required TimeOfDay existingStart,
    required TimeOfDay existingEnd,
  }) {
    // Verificar se há sobreposição
    if (!_hasTimeOverlap(newStart, newEnd, existingStart, existingEnd)) {
      return null;
    }

    // Determinar tipo de sobreposição
    return _determineOverlapType(
      newStart,
      newEnd,
      existingStart,
      existingEnd,
    );
  }

  /// Gera novos slots ajustados baseado em overlap
  /// 
  /// Recebe o slot existente, o novo intervalo, e o tipo de overlap.
  /// Retorna a lista de slots ajustados (sem incluir o novo slot).
  /// 
  /// **IMPORTANTE:**
  /// - Este helper APENAS ajusta os slots existentes
  /// - NÃO adiciona o novo slot
  /// - Retorna apenas a lista de slots ajustados
  /// 
  /// **Exemplos:**
  /// ```dart
  /// // Partial Before: ajusta início do slot existente
  /// final slots = AvailabilityHelpers.generateNewSlots(
  ///   existingSlot: TimeSlot(...), // 16:00-20:00
  ///   newStart: TimeOfDay(hour: 13, minute: 0),
  ///   newEnd: TimeOfDay(hour: 19, minute: 0),
  ///   overlapType: OverlapType.partialBefore,
  /// );
  /// // Retorna: [TimeSlot(19:00-20:00)]
  /// 
  /// // Contains: divide slot existente em dois
  /// final slots = AvailabilityHelpers.generateNewSlots(
  ///   existingSlot: TimeSlot(...), // 10:00-22:00
  ///   newStart: TimeOfDay(hour: 13, minute: 0),
  ///   newEnd: TimeOfDay(hour: 19, minute: 0),
  ///   overlapType: OverlapType.contains,
  /// );
  /// // Retorna: [TimeSlot(10:00-13:00), TimeSlot(19:00-22:00)]
  /// ```
  /// 
  /// **Parâmetros:**
  /// - `existingSlot`: Slot existente que será ajustado
  /// - `newStart`/`newEnd`: Horários do novo intervalo
  /// - `overlapType`: Tipo de sobreposição (deve ser válido, não null)
  /// 
  /// **Retorna:**
  /// Lista de `TimeSlot` com os slots ajustados (pode ser vazia se o slot for removido)
  static List<TimeSlot> generateNewSlots({
    required TimeSlot existingSlot,
    required TimeOfDay newStart,
    required TimeOfDay newEnd,
    required OverlapType overlapType,
  }) {
    // Converter strings de horário do slot existente para TimeOfDay
    final existingStart = _parseTimeString(existingSlot.startTime);
    final existingEnd = _parseTimeString(existingSlot.endTime);

    // Validar que realmente há overlap (safety check)
    final validatedOverlap = validateTimeSlotOverlap(
      newStart: newStart,
      newEnd: newEnd,
      existingStart: existingStart,
      existingEnd: existingEnd,
    );

    if (validatedOverlap == null) {
      // Se não há overlap, retornar slot original sem modificação
      return [existingSlot];
    }

    // Garantir que o tipo de overlap passado corresponde ao validado
    final finalOverlapType = validatedOverlap;

    const uuid = Uuid();

    switch (finalOverlapType) {
      case OverlapType.partialBefore:
        // Ajustar início do slot existente
        // Novo:      [13:00 ████████████ 19:00]
        // Existente:        [16:00 ████ 20:00] → [19:00 ████ 20:00]
        return [
          existingSlot.copyWith(
            startTime: _formatTimeOfDay(newEnd),
          ),
        ];

      case OverlapType.partialAfter:
        // Ajustar final do slot existente
        // Novo:              [13:00 ████████████ 19:00]
        // Existente: [10:00 ████ 15:00] → [10:00 ████ 13:00]
        return [
          existingSlot.copyWith(
            endTime: _formatTimeOfDay(newStart),
          ),
        ];

      case OverlapType.contains:
        // Dividir slot existente em dois
        // Novo:        [13:00 ████ 19:00]
        // Existente: [10:00 ████████████████ 22:00]
        // Resultado: [10:00 ████ 13:00] + [19:00 ████ 22:00]
        return [
          // Primeira parte (antes do novo slot)
          existingSlot.copyWith(
            endTime: _formatTimeOfDay(newStart),
          ),
          // Segunda parte (depois do novo slot)
          TimeSlot(
            slotId: uuid.v4(),
            startTime: _formatTimeOfDay(newEnd),
            endTime: existingSlot.endTime,
            status: existingSlot.status,
            valorHora: existingSlot.valorHora,
            sourcePatternId: existingSlot.sourcePatternId,
            blockReason: existingSlot.blockReason,
            bookingId: existingSlot.bookingId,
          ),
        ];

      case OverlapType.contained:
        // Remover slot existente completamente
        // Novo:      [10:00 ████████████████ 22:00]
        // Existente:   [13:00 ████ 19:00] → REMOVIDO
        return [];

      case OverlapType.exact:
        // Remover slot existente (será substituído pelo novo slot)
        // Novo:      [13:00 ████████████ 19:00] R$ 250
        // Existente: [13:00 ████████████ 19:00] R$ 200 → REMOVIDO
        return [];
    }
  }

  // ════════════════════════════════════════════════════════════════════
  // Métodos privados auxiliares
  // ════════════════════════════════════════════════════════════════════

  /// Converte código de dia da semana (MO, TU, etc) para número do DateTime
  /// 
  /// DateTime.monday = 1, DateTime.tuesday = 2, ..., DateTime.sunday = 7
  static int _codeToWeekday(String code) {
    switch (code.toUpperCase()) {
      case 'MO':
        return DateTime.monday;
      case 'TU':
        return DateTime.tuesday;
      case 'WE':
        return DateTime.wednesday;
      case 'TH':
        return DateTime.thursday;
      case 'FR':
        return DateTime.friday;
      case 'SA':
        return DateTime.saturday;
      case 'SU':
        return DateTime.sunday;
      default:
        throw ArgumentError('Código de dia da semana inválido: $code');
    }
  }

  /// Verifica se dois intervalos de horário se sobrepõem
  /// 
  /// **Lógica:**
  /// - Converte horários para minutos desde meia-noite
  /// - Aplica fórmula: `start1 < end2 && end1 > start2`
  /// 
  /// **Exemplos:**
  /// ```dart
  /// _hasTimeOverlap(12:00, 18:00, 16:00, 20:00) → true  (sobrepõe 16:00-18:00)
  /// _hasTimeOverlap(08:00, 12:00, 12:00, 16:00) → false (adjacentes)
  /// _hasTimeOverlap(14:00, 18:00, 10:00, 20:00) → true  (contido completamente)
  /// _hasTimeOverlap(08:00, 10:00, 14:00, 16:00) → false (sem sobreposição)
  /// ```
  static bool _hasTimeOverlap(
    TimeOfDay start1,
    TimeOfDay end1,
    TimeOfDay start2,
    TimeOfDay end2,
  ) {
    // Converter para minutos desde meia-noite
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    // Verificar sobreposição: start1 < end2 && end1 > start2
    return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
  }

  /// Determina o tipo de sobreposição entre dois slots
  /// 
  /// **Parâmetros:**
  /// - `newStart`/`newEnd`: Horários do novo slot
  /// - `existingStart`/`existingEnd`: Horários do slot existente
  /// 
  /// **Retorna:** Tipo de sobreposição identificado
  static OverlapType _determineOverlapType(
    TimeOfDay newStart,
    TimeOfDay newEnd,
    TimeOfDay existingStart,
    TimeOfDay existingEnd,
  ) {
    // Converter para minutos para comparação
    final newStartMin = newStart.hour * 60 + newStart.minute;
    final newEndMin = newEnd.hour * 60 + newEnd.minute;
    final existingStartMin = existingStart.hour * 60 + existingStart.minute;
    final existingEndMin = existingEnd.hour * 60 + existingEnd.minute;

    // Sobreposição exata (mesmos horários)
    if (newStartMin == existingStartMin && newEndMin == existingEndMin) {
      return OverlapType.exact;
    }

    // Novo slot CONTÉM completamente o slot existente
    // Novo:      [10:00 ████████████████ 22:00]
    // Existente:   [13:00 ████ 19:00]
    if (newStartMin <= existingStartMin && newEndMin >= existingEndMin) {
      return OverlapType.contained;
    }

    // Slot existente CONTÉM completamente o novo slot
    // Novo:        [13:00 ████ 19:00]
    // Existente: [10:00 ████████████████ 22:00]
    if (newStartMin >= existingStartMin && newEndMin <= existingEndMin) {
      return OverlapType.contains;
    }

    // Novo slot sobrepõe o INÍCIO do slot existente
    // Novo:      [13:00 ████████████ 19:00]
    // Existente:        [16:00 ████████████ 20:00]
    if (newStartMin < existingStartMin && newEndMin > existingStartMin) {
      return OverlapType.partialBefore;
    }

    // Novo slot sobrepõe o FINAL do slot existente
    // Novo:              [13:00 ████████████ 19:00]
    // Existente: [10:00 ████████████ 15:00]
    if (newStartMin < existingEndMin && newEndMin > existingEndMin) {
      return OverlapType.partialAfter;
    }

    // Fallback (não deveria chegar aqui se _hasTimeOverlap retornou true)
    return OverlapType.exact;
  }

  /// Formata TimeOfDay para string "HH:mm"
  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Converte string "HH:mm" para TimeOfDay
  static TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
