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
  /// [isEndTime]: Se true e o horário for "00:00", trata como 24:00 (1440 minutos)
  ///              Isso permite intervalos que cruzam a meia-noite (ex: 18:00 até 00:00)
  /// 
  /// Exemplo: 
  /// - "17:30" -> 1050 minutos (17 * 60 + 30)
  /// - "00:00" com isEndTime=true -> 1440 minutos (24:00)
  /// - "00:00" com isEndTime=false -> 0 minutos
  static int timeToMinutes(String timeString, {bool isEndTime = false}) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    final totalMinutes = hours * 60 + minutes;
    
    // Se é horário fim e é 00:00, tratar como 24:00 (meia-noite do dia seguinte)
    if (isEndTime && totalMinutes == 0) {
      return 24 * 60; // 1440 minutos
    }
    
    return totalMinutes;
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
    final availabilityEndMinutes = timeToMinutes(horarioFim, isEndTime: true);

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

    // Ordenar bloqueios por horário de início
    blockedSlotsForDate.sort((a, b) {
      final aStart = timeToMinutes(a.startTime);
      final bStart = timeToMinutes(b.startTime);
      return aStart.compareTo(bStart);
    });

    // Verificar se os bloqueios cobrem completamente o período disponível
    // Percorrer os bloqueios e verificar se há espaço entre eles ou antes/depois deles
    int currentTime = availabilityStartMinutes;
    
    for (final blockedSlot in blockedSlotsForDate) {
      final blockedStartMinutes = timeToMinutes(blockedSlot.startTime);
      final blockedEndMinutes = timeToMinutes(blockedSlot.endTime);

      // Se há espaço antes deste bloqueio, ainda há disponibilidade
      if (blockedStartMinutes > currentTime) {
        return true;
      }

      // Atualizar tempo atual para após o bloqueio (usando o máximo para cobrir sobreposições)
      currentTime = blockedEndMinutes > currentTime ? blockedEndMinutes : currentTime;
    }

    // Verificar se há espaço após o último bloqueio
    // Se o tempo atual chegou ou ultrapassou o fim da disponibilidade, não há espaço
    if (currentTime < availabilityEndMinutes) {
      return true;
    }

    // Se chegou aqui, todos os bloqueios juntos cobrem completamente o horário disponível
    return false;
  }

  /// Verifica se uma data é válida para uma disponibilidade
  /// 
  /// Considera: dataInicio, dataFim, diasDaSemana (se repetir=true) e blockedSlots
  /// 
  /// Retorna true se a data é válida para a disponibilidade, false caso contrário
  static bool isDateValidForAvailability(
    DateTime dataInicio,
    DateTime dataFim,
    List<String> diasDaSemana,
    bool repetir,
    List<BlockedTimeSlot> blockedSlots,
    String horarioInicio,
    String horarioFim,
    DateTime selectedDate,
  ) {
    // 1. Verificar se a data está dentro do range
    if (!isDateWithinRange(dataInicio, dataFim, selectedDate)) {
      return false;
    }

    // 2. Verificar se o dia da semana é válido (se repetir=true)
    if (!isDayOfWeekValid(diasDaSemana, repetir, selectedDate)) {
      return false;
    }

    // 3. Verificar se há horário disponível na data (considerando blockedSlots)
    if (!hasAvailableTime(horarioInicio, horarioFim, blockedSlots, selectedDate)) {
      return false;
    }

    return true;
  }

  /// Calcula os intervalos de horários disponíveis para uma data específica
  /// 
  /// Considera a disponibilidade base e os blockedSlots para a data selecionada
  /// Retorna uma lista de strings formatadas com os intervalos (ex: ["11 até 13", "15 até 20"])
  static List<String> getAvailableTimeIntervals(
    String horarioInicio,
    String horarioFim,
    List<BlockedTimeSlot> blockedSlots,
    DateTime selectedDate,
  ) {
    final availabilityStartMinutes = timeToMinutes(horarioInicio);
    final availabilityEndMinutes = timeToMinutes(horarioFim, isEndTime: true);
    
    // Normalizar data selecionada para comparar apenas dia/mês/ano
    final normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Buscar bloqueios para esta data
    final blockedSlotsForDate = blockedSlots.where((blockedSlot) {
      final blockedDate = DateTime(
        blockedSlot.date.year,
        blockedSlot.date.month,
        blockedSlot.date.day,
      );
      return blockedDate == normalizedSelectedDate;
    }).toList();

    // Se não há bloqueios, retornar intervalo completo
    if (blockedSlotsForDate.isEmpty) {
      return ['$horarioInicio até $horarioFim'];
    }

    // Ordenar bloqueios por horário de início
    blockedSlotsForDate.sort((a, b) {
      final aStart = timeToMinutes(a.startTime);
      final bStart = timeToMinutes(b.startTime);
      return aStart.compareTo(bStart);
    });

    final intervals = <String>[];
    int currentTime = availabilityStartMinutes;

    // Percorrer bloqueios e criar intervalos disponíveis
    for (final blockedSlot in blockedSlotsForDate) {
      final blockedStartMinutes = timeToMinutes(blockedSlot.startTime);
      final blockedEndMinutes = timeToMinutes(blockedSlot.endTime);

      // Se há espaço antes do bloqueio, adicionar intervalo
      if (blockedStartMinutes > currentTime) {
        final startTime = _minutesToTimeString(currentTime);
        final endTime = _minutesToTimeString(blockedStartMinutes);
        intervals.add('$startTime até $endTime');
      }

      // Atualizar tempo atual para após o bloqueio
      currentTime = blockedEndMinutes > currentTime ? blockedEndMinutes : currentTime;
    }

    // Adicionar intervalo após o último bloqueio (se houver)
    if (currentTime < availabilityEndMinutes) {
      final startTime = _minutesToTimeString(currentTime);
      intervals.add('$startTime até $horarioFim');
    }

    return intervals;
  }

  /// Converte minutos desde meia-noite para string de horário (HH:mm)
  /// 
  /// Se minutes >= 1440, trata como 00:00 (meia-noite do dia seguinte)
  static String _minutesToTimeString(int minutes) {
    // Se for 1440 minutos (24:00), retornar 00:00
    if (minutes >= 24 * 60) {
      return '00:00';
    }
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}

