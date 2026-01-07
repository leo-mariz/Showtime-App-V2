import 'package:app/core/domain/artist/availability_calendar_entitys/availability_entity.dart';
import 'package:app/core/utils/availability_validator.dart';

/// UseCase: Verificar se uma disponibilidade é válida para uma data específica
/// 
/// RESPONSABILIDADES:
/// - Orquestrar todas as validações necessárias para verificar se uma disponibilidade
///   é válida para uma data específica
/// - Aplicar as validações na ordem correta usando helpers utilitários
/// 
/// VALIDAÇÕES APLICADAS (em ordem):
/// 1. Verificar se a data está dentro do range (dataInicio <= selectedDate <= dataFim)
/// 2. Verificar se o dia da semana corresponde aos diasDaSemana
/// 3. Verificar se não há horários bloqueados que cubram completamente o horário disponível
/// 
/// Retorna true se todas as validações passarem, false caso contrário
class IsAvailabilityValidForDateUseCase {
  IsAvailabilityValidForDateUseCase();

  /// Verifica se uma disponibilidade é válida para uma data específica
  /// 
  /// [availability]: Disponibilidade a ser verificada
  /// [selectedDate]: Data selecionada para verificação
  /// 
  /// Retorna true se a disponibilidade é válida para a data, false caso contrário
  bool call(AvailabilityEntity availability, DateTime selectedDate) {
    // Validação 1: Verificar se a data está dentro do range
    final isWithinDateRange = AvailabilityValidator.isDateWithinRange(
      availability.dataInicio,
      availability.dataFim,
      selectedDate,
    );
    if (!isWithinDateRange) {
      print('🔴 [VALIDATION] Disponibilidade ${availability.id} - Data $selectedDate FORA do range (${availability.dataInicio} a ${availability.dataFim})');
      return false;
    }
    print('🟢 [VALIDATION] Disponibilidade ${availability.id} - Data $selectedDate DENTRO do range');

    // Validação 2: Verificar se o dia da semana corresponde
    // Se repetir=false, considera todos os dias da semana disponíveis
    final isDayOfWeekValid = AvailabilityValidator.isDayOfWeekValid(
      availability.diasDaSemana,
      availability.repetir,
      selectedDate,
    );
    if (!isDayOfWeekValid) {
      print('🔴 [VALIDATION] Disponibilidade ${availability.id} - Dia da semana NÃO corresponde (repetir=${availability.repetir}, dias=${availability.diasDaSemana})');
      return false;
    }
    print('🟢 [VALIDATION] Disponibilidade ${availability.id} - Dia da semana VÁLIDO');

    // Validação 3: Verificar se não há horários bloqueados que cubram completamente o horário
    final hasAvailableTime = AvailabilityValidator.hasAvailableTime(
      availability.horarioInicio,
      availability.horarioFim,
      availability.blockedSlots,
      selectedDate,
    );
    if (!hasAvailableTime) {
      print('🔴 [VALIDATION] Disponibilidade ${availability.id} - Horário COMPLETAMENTE bloqueado');
      return false;
    }
    print('🟢 [VALIDATION] Disponibilidade ${availability.id} - Tem horário disponível');

    // Todas as validações passaram
    print('🟢 [VALIDATION] Disponibilidade ${availability.id} - TODAS as validações passaram! ✅');
    return true;
  }
}

