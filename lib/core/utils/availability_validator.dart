import 'package:app/core/domain/artist/availability_calendar_entitys/blocked_time_slot.dart';

/// Helper para validações de disponibilidade
/// 
/// Contém funções utilitárias puras (stateless) para validar disponibilidades.
/// Essas validações são cálculos simples que não requerem dependências ou estado.
class AvailabilityValidator {
  /// Verifica se uma data está dentro do range de datas (inclusive)
  /// 
  /// [dataInicio]: Data de início do range
  /// [dataFim]: Data de fim do range
  /// [selectedDate]: Data selecionada para verificação
  /// 
  /// Retorna true se dataInicio <= selectedDate <= dataFim (comparando apenas datas, sem horários)
  static bool isDateWithinRange(
    DateTime dataInicio,
    DateTime dataFim,
    DateTime selectedDate,
  ) {
    // Normalizar datas para comparar apenas dia/mês/ano (ignorar horários)
    final normalizedStartDate = DateTime(
      dataInicio.year,
      dataInicio.month,
      dataInicio.day,
    );
    
    final normalizedEndDate = DateTime(
      dataFim.year,
      dataFim.month,
      dataFim.day,
    );
    
    final normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Verificar se a data está dentro do range (inclusive)
    return normalizedSelectedDate.isAtSameMomentAs(normalizedStartDate) ||
           normalizedSelectedDate.isAtSameMomentAs(normalizedEndDate) ||
           (normalizedSelectedDate.isAfter(normalizedStartDate) &&
            normalizedSelectedDate.isBefore(normalizedEndDate));
  }

  /// Mapeia o dia da semana (int) para o código usado na disponibilidade
  /// 
  /// DateTime.weekday retorna: 1=Monday, 2=Tuesday, ..., 7=Sunday
  /// Disponibilidade usa: 'MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'
  static String getDayOfWeekCode(int weekday) {
    const dayCodes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    // DateTime.weekday: 1=Monday (índice 0), 7=Sunday (índice 6)
    return dayCodes[weekday - 1];
  }

  /// Verifica se o dia da semana da data corresponde aos dias disponíveis
  /// 
  /// [diasDaSemana]: Lista de códigos de dias da semana ('MO', 'TU', etc.)
  /// [repetir]: Se false, considera todos os dias da semana disponíveis
  /// [selectedDate]: Data selecionada para verificação
  /// 
  /// Retorna true se o dia da semana da data estiver em diasDaSemana, false caso contrário
  /// Se repetir=false, retorna true (considera todos os dias disponíveis)
  /// Se diasDaSemana estiver vazio, retorna true (considera sempre disponível)
  static bool isDayOfWeekValid(
    List<String> diasDaSemana,
    bool repetir,
    DateTime selectedDate,
  ) {
    // Se repetir=false, considerar todos os dias da semana disponíveis
    if (!repetir) {
      return true;
    }

    // Se não há dias da semana definidos, considerar sempre disponível
    if (diasDaSemana.isEmpty) {
      return true;
    }

    // Obter código do dia da semana da data selecionada
    final selectedDayCode = getDayOfWeekCode(selectedDate.weekday);

    // Verificar se o dia está na lista de dias disponíveis
    return diasDaSemana.contains(selectedDayCode);
  }

  /// Converte string de horário (HH:mm) para minutos desde meia-noite
  /// 
  /// Exemplo: "17:30" -> 1050 minutos (17 * 60 + 30)
  static int timeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours * 60 + minutes;
  }

  /// Verifica se há horários bloqueados que impedem completamente a disponibilidade
  /// 
  /// [horarioInicio]: Horário de início da disponibilidade (formato: "HH:mm")
  /// [horarioFim]: Horário de fim da disponibilidade (formato: "HH:mm")
  /// [blockedSlots]: Lista de horários bloqueados
  /// [selectedDate]: Data selecionada para verificação
  /// 
  /// Retorna true se a disponibilidade ainda é válida (não está completamente bloqueada)
  /// Retorna false se o horário bloqueado cobre completamente o horário disponível
  static bool hasAvailableTime(
    String horarioInicio,
    String horarioFim,
    List<BlockedTimeSlot> blockedSlots,
    DateTime selectedDate,
  ) {
    // Se não há horários bloqueados, a disponibilidade é válida
    if (blockedSlots.isEmpty) {
      return true;
    }

    // Normalizar data selecionada para comparar apenas dia/mês/ano
    final normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Converter horários da disponibilidade para minutos
    final availabilityStartMinutes = timeToMinutes(horarioInicio);
    final availabilityEndMinutes = timeToMinutes(horarioFim);

    // Verificar se há algum bloqueio na data selecionada
    final blockedSlotsForDate = blockedSlots.where((blockedSlot) {
      final blockedDate = DateTime(
        blockedSlot.date.year,
        blockedSlot.date.month,
        blockedSlot.date.day,
      );
      return blockedDate == normalizedSelectedDate;
    }).toList();

    // Se não há bloqueios para esta data, a disponibilidade é válida
    if (blockedSlotsForDate.isEmpty) {
      return true;
    }

    // Verificar se algum bloqueio cobre completamente o horário disponível
    for (final blockedSlot in blockedSlotsForDate) {
      final blockedStartMinutes = timeToMinutes(blockedSlot.startTime);
      final blockedEndMinutes = timeToMinutes(blockedSlot.endTime);

      // Se o bloqueio cobre completamente o horário disponível, a disponibilidade não é válida
      if (blockedStartMinutes <= availabilityStartMinutes &&
          blockedEndMinutes >= availabilityEndMinutes) {
        return false;
      }
    }

    // Se chegou aqui, há bloqueios mas não cobrem completamente o horário disponível
    // Portanto, ainda há horário disponível (parcial)
    return true;
  }
}

