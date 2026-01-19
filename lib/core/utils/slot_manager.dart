import 'dart:math';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:uuid/uuid.dart';

/// Gerenciador de slots de tempo
/// 
/// Responsável por operações de split, merge e validação de slots
class SlotManager {
  static const _uuid = Uuid();
  
  /// Duração mínima de um slot em minutos (padrão: 30 minutos)
  static const int minimumSlotDuration = 30;
  
  /// Converte horário "HH:mm" para minutos desde meia-noite
  static int timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  
  /// Converte minutos desde meia-noite para horário "HH:mm"
  static String minutesToTime(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final mins = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$mins';
  }
  
  /// Bloqueia um período específico, quebrando slots existentes se necessário
  /// 
  /// [existingSlots]: Lista de slots existentes
  /// [blockStart]: Horário de início do bloqueio (HH:mm)
  /// [blockEnd]: Horário de fim do bloqueio (HH:mm)
  /// [blockReason]: Motivo do bloqueio (opcional)
  /// 
  /// Retorna nova lista de slots com o bloqueio aplicado
  static List<TimeSlot> blockTimeRange({
    required List<TimeSlot> existingSlots,
    required String blockStart,
    required String blockEnd,
    String? blockReason,
  }) {
    final newSlots = <TimeSlot>[];
    
    for (final slot in existingSlots) {
      // Ignorar slots que não estão disponíveis
      if (slot.status != 'available') {
        newSlots.add(slot);
        continue;
      }
      
      // Calcular interseção
      final intersection = _calculateIntersection(
        slotStart: slot.startTime,
        slotEnd: slot.endTime,
        blockStart: blockStart,
        blockEnd: blockEnd,
      );
      
      // Se não há interseção, manter slot original
      if (intersection.type == IntersectionType.none) {
        newSlots.add(slot);
        continue;
      }
      
      // Se há interseção, dividir o slot
      final splitSlots = _splitSlotForBlock(
        originalSlot: slot,
        blockStart: blockStart,
        blockEnd: blockEnd,
        blockReason: blockReason,
      );
      
      newSlots.addAll(splitSlots);
    }
    
    // Ordenar por horário e fazer merge de slots contínuos
    return mergeContinuousSlots(newSlots);
  }
  
  /// Remove um bloqueio, podendo fazer merge com slots adjacentes
  /// 
  /// [existingSlots]: Lista de slots existentes
  /// [blockStart]: Horário de início do bloqueio a remover
  /// [blockEnd]: Horário de fim do bloqueio a remover
  /// [newStatus]: Novo status do slot (default: 'available')
  /// [valorHora]: Valor por hora (necessário se newStatus = 'available')
  /// 
  /// Retorna nova lista de slots com o bloqueio removido
  static List<TimeSlot> unblockTimeRange({
    required List<TimeSlot> existingSlots,
    required String blockStart,
    required String blockEnd,
    String newStatus = 'available',
    double? valorHora,
    String? sourcePatternId,
  }) {
    final newSlots = <TimeSlot>[];
    
    for (final slot in existingSlots) {
      final slotStartMin = timeToMinutes(slot.startTime);
      final slotEndMin = timeToMinutes(slot.endTime);
      final blockStartMin = timeToMinutes(blockStart);
      final blockEndMin = timeToMinutes(blockEnd);
      
      // Se o slot está completamente dentro do bloqueio a remover
      if (slotStartMin >= blockStartMin && slotEndMin <= blockEndMin) {
        // Converter para novo status
        if (slot.status == 'blocked') {
          newSlots.add(TimeSlot(
            slotId: slot.slotId,
            startTime: slot.startTime,
            endTime: slot.endTime,
            status: newStatus,
            valorHora: valorHora,
            sourcePatternId: sourcePatternId,
          ));
        } else {
          newSlots.add(slot);
        }
      } else {
        newSlots.add(slot);
      }
    }
    
    return mergeContinuousSlots(newSlots);
  }
  
  /// Mescla slots contínuos com mesmas propriedades
  /// 
  /// Exemplo: [10:00-12:00, R$500] + [12:00-14:00, R$500] = [10:00-14:00, R$500]
  static List<TimeSlot> mergeContinuousSlots(List<TimeSlot> slots) {
    if (slots.isEmpty) return slots;
    
    // Ordenar por horário de início
    final sortedSlots = List<TimeSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    final merged = <TimeSlot>[sortedSlots.first];
    
    for (int i = 1; i < sortedSlots.length; i++) {
      final current = sortedSlots[i];
      final last = merged.last;
      
      // Verificar se podem ser mesclados
      final canMerge = last.endTime == current.startTime &&
          last.status == current.status &&
          last.valorHora == current.valorHora &&
          last.blockReason == current.blockReason &&
          last.sourcePatternId == current.sourcePatternId;
      
      if (canMerge) {
        // Mesclar expandindo o último slot
        merged.last = last.copyWith(
          endTime: current.endTime,
        );
      } else {
        merged.add(current);
      }
    }
    
    return merged;
  }
  
  /// Divide um slot baseado na interseção com um bloqueio
  static List<TimeSlot> _splitSlotForBlock({
    required TimeSlot originalSlot,
    required String blockStart,
    required String blockEnd,
    String? blockReason,
  }) {
    final slots = <TimeSlot>[];
    
    final slotStartMin = timeToMinutes(originalSlot.startTime);
    final slotEndMin = timeToMinutes(originalSlot.endTime);
    final blockStartMin = timeToMinutes(blockStart);
    final blockEndMin = timeToMinutes(blockEnd);
    
    // Slot ANTES do bloqueio (se existir espaço suficiente)
    if (slotStartMin < blockStartMin) {
      final beforeDuration = blockStartMin - slotStartMin;
      if (beforeDuration >= minimumSlotDuration) {
        slots.add(TimeSlot(
          slotId: '${originalSlot.slotId}_before',
          startTime: originalSlot.startTime,
          endTime: blockStart,
          status: 'available',
          valorHora: originalSlot.valorHora,
          sourcePatternId: originalSlot.sourcePatternId,
        ));
      }
    }
    
    // Slot BLOQUEADO (interseção)
    final blockedStart = minutesToTime(max(slotStartMin, blockStartMin));
    final blockedEnd = minutesToTime(min(slotEndMin, blockEndMin));
    slots.add(TimeSlot(
      slotId: '${originalSlot.slotId}_blocked',
      startTime: blockedStart,
      endTime: blockedEnd,
      status: 'blocked',
      blockReason: blockReason,
      sourcePatternId: originalSlot.sourcePatternId,
    ));
    
    // Slot DEPOIS do bloqueio (se existir espaço suficiente)
    if (slotEndMin > blockEndMin) {
      final afterDuration = slotEndMin - blockEndMin;
      if (afterDuration >= minimumSlotDuration) {
        slots.add(TimeSlot(
          slotId: '${originalSlot.slotId}_after',
          startTime: blockEnd,
          endTime: originalSlot.endTime,
          status: 'available',
          valorHora: originalSlot.valorHora,
          sourcePatternId: originalSlot.sourcePatternId,
        ));
      }
    }
    
    return slots;
  }
  
  /// Calcula a interseção entre um slot e um período de bloqueio
  static TimeIntersection _calculateIntersection({
    required String slotStart,
    required String slotEnd,
    required String blockStart,
    required String blockEnd,
  }) {
    final slotStartMin = timeToMinutes(slotStart);
    final slotEndMin = timeToMinutes(slotEnd);
    final blockStartMin = timeToMinutes(blockStart);
    final blockEndMin = timeToMinutes(blockEnd);
    
    // Sem interseção
    if (blockEndMin <= slotStartMin || blockStartMin >= slotEndMin) {
      return TimeIntersection.none();
    }
    
    // Interseção total (bloqueio cobre todo o slot)
    if (blockStartMin <= slotStartMin && blockEndMin >= slotEndMin) {
      return TimeIntersection.full();
    }
    
    // Interseção parcial
    return TimeIntersection.partial(
      overlapStart: max(slotStartMin, blockStartMin),
      overlapEnd: min(slotEndMin, blockEndMin),
    );
  }
  
  /// Valida se uma operação de bloqueio é permitida
  static ValidationResult validateBlockOperation({
    required List<TimeSlot> existingSlots,
    required String blockStart,
    required String blockEnd,
  }) {
    // Validar horários
    if (timeToMinutes(blockStart) >= timeToMinutes(blockEnd)) {
      return ValidationResult.error(
        'Horário de fim deve ser maior que o horário de início',
      );
    }
    
    // Verificar se criaria slots muito pequenos
    final wouldCreateTinySlots = _wouldCreateSlotsUnderMinimum(
      existingSlots: existingSlots,
      blockStart: blockStart,
      blockEnd: blockEnd,
    );
    
    if (wouldCreateTinySlots) {
      return ValidationResult.warning(
        'Isso criará slots muito pequenos (menos de $minimumSlotDuration minutos). '
        'Recomendamos ajustar os horários ou bloquear o período completo.',
      );
    }
    
    // Verificar se há slots disponíveis para bloquear
    final hasAvailableSlots = existingSlots.any((slot) {
      if (slot.status != 'available') return false;
      return _calculateIntersection(
        slotStart: slot.startTime,
        slotEnd: slot.endTime,
        blockStart: blockStart,
        blockEnd: blockEnd,
      ).type != IntersectionType.none;
    });
    
    if (!hasAvailableSlots) {
      return ValidationResult.warning(
        'Não há horários disponíveis neste período para bloquear.',
      );
    }
    
    return ValidationResult.success();
  }
  
  /// Verifica se a operação criaria slots abaixo do mínimo
  static bool _wouldCreateSlotsUnderMinimum({
    required List<TimeSlot> existingSlots,
    required String blockStart,
    required String blockEnd,
  }) {
    final blockStartMin = timeToMinutes(blockStart);
    final blockEndMin = timeToMinutes(blockEnd);
    
    for (final slot in existingSlots) {
      if (slot.status != 'available') continue;
      
      final slotStartMin = timeToMinutes(slot.startTime);
      final slotEndMin = timeToMinutes(slot.endTime);
      
      // Slot antes do bloqueio
      if (slotStartMin < blockStartMin && blockStartMin < slotEndMin) {
        final beforeDuration = blockStartMin - slotStartMin;
        if (beforeDuration > 0 && beforeDuration < minimumSlotDuration) {
          return true;
        }
      }
      
      // Slot depois do bloqueio
      if (slotStartMin < blockEndMin && blockEndMin < slotEndMin) {
        final afterDuration = slotEndMin - blockEndMin;
        if (afterDuration > 0 && afterDuration < minimumSlotDuration) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Gera um novo ID único para um slot
  static String generateSlotId() => _uuid.v4();
  
  /// Gera um novo ID único para um padrão
  static String generatePatternId() => 'pattern_${_uuid.v4()}';
}

/// Tipo de interseção entre dois períodos
enum IntersectionType {
  none,    // Sem interseção
  partial, // Interseção parcial
  full,    // Interseção total
}

/// Resultado de cálculo de interseção
class TimeIntersection {
  final IntersectionType type;
  final int? overlapStart;
  final int? overlapEnd;
  
  const TimeIntersection._(this.type, this.overlapStart, this.overlapEnd);
  
  factory TimeIntersection.none() => 
      const TimeIntersection._(IntersectionType.none, null, null);
  
  factory TimeIntersection.full() => 
      const TimeIntersection._(IntersectionType.full, null, null);
  
  factory TimeIntersection.partial({
    required int overlapStart,
    required int overlapEnd,
  }) => TimeIntersection._(IntersectionType.partial, overlapStart, overlapEnd);
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String? message;
  final ValidationLevel level;
  
  const ValidationResult._(this.isValid, this.message, this.level);
  
  factory ValidationResult.success() => 
      const ValidationResult._(true, null, ValidationLevel.success);
  
  factory ValidationResult.warning(String message) => 
      ValidationResult._(true, message, ValidationLevel.warning);
  
  factory ValidationResult.error(String message) => 
      ValidationResult._(false, message, ValidationLevel.error);
}

enum ValidationLevel {
  success,
  warning,
  error,
}
