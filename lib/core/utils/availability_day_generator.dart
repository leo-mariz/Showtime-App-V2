import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/address_availability_entity.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/utils/slot_manager.dart';

/// Gerador de dias de disponibilidade a partir de padrões de recorrência
class AvailabilityDayGenerator {
  
  /// Gera lista de dias baseado em um padrão de recorrência
  /// 
  /// [startDate]: Data de início do período
  /// [endDate]: Data de fim do período
  /// [weekdays]: Dias da semana (MO, TU, WE, TH, FR, SA, SU). Null = todos os dias
  /// [startTime]: Horário de início (HH:mm)
  /// [endTime]: Horário de fim (HH:mm)
  /// [valorHora]: Valor por hora
  /// [addressId]: ID do endereço
  /// [geohash]: Geohash do endereço
  /// [raioAtuacao]: Raio de atuação em km
  /// [endereco]: Informações completas do endereço
  /// 
  /// Retorna lista de AvailabilityDay gerados
  static List<AvailabilityDayEntity> generateDaysFromPattern({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? weekdays,
    required String startTime,
    required String endTime,
    required double valorHora,
    required String addressId,
    required String geohash,
    required double raioAtuacao,
    required AddressInfoEntity endereco,
  }) {
    // Gerar ID único do padrão
    final patternId = SlotManager.generatePatternId();
    final now = DateTime.now();
    
    // Criar metadata do padrão
    final patternMetadata = PatternMetadata(
      patternId: patternId,
      creationType: weekdays != null ? 'recurring_pattern' : 'date_range',
      recurrence: RecurrenceSettings(
        weekdays: weekdays,
        originalStartDate: startDate,
        originalEndDate: endDate,
        originalStartTime: startTime,
        originalEndTime: endTime,
        originalValorHora: valorHora,
        originalAddressId: addressId,
      ),
      createdAt: now,
    );
    
    // Gerar lista de dias
    final days = <AvailabilityDayEntity>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (currentDate.isBefore(normalizedEndDate) || 
           currentDate.isAtSameMomentAs(normalizedEndDate)) {
      // Se weekdays foi especificado, verificar se o dia atual está na lista
      if (weekdays != null && weekdays.isNotEmpty) {
        final weekdayCode = _getWeekdayCode(currentDate.weekday);
        if (!weekdays.contains(weekdayCode)) {
          currentDate = currentDate.add(const Duration(days: 1));
          continue;
        }
      }
      
      // Criar slot único para o dia
      final slot = TimeSlot(
        slotId: SlotManager.generateSlotId(),
        startTime: startTime,
        endTime: endTime,
        status: 'available',
        valorHora: valorHora,
        sourcePatternId: patternId,
      );
      
      // Criar disponibilidade do endereço
      final addressAvailability = AddressAvailabilityEntity(
        addressId: addressId,
        raioAtuacao: raioAtuacao,
        endereco: endereco,
        slots: [slot],
      );
      
      // Criar documento do dia
      final day = AvailabilityDayEntity(
        date: currentDate,
        generatedFrom: patternMetadata,
        isOverridden: false,
        addresses: [addressAvailability],
        createdAt: now,
      );
      
      days.add(day);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return days;
  }
  
  /// Gera um único dia manualmente (sem padrão)
  static AvailabilityDayEntity generateSingleDay({
    required DateTime date,
    required String startTime,
    required String endTime,
    required double valorHora,
    required String addressId,
    required String geohash,
    required double raioAtuacao,
    required AddressInfoEntity endereco,
  }) {
    final now = DateTime.now();
    
    // Criar slot único
    final slot = TimeSlot(
      slotId: SlotManager.generateSlotId(),
      startTime: startTime,
      endTime: endTime,
      status: 'available',
      valorHora: valorHora,
    );
    
    // Criar disponibilidade do endereço
    final addressAvailability = AddressAvailabilityEntity(
      addressId: addressId,
      raioAtuacao: raioAtuacao,
      endereco: endereco,
      slots: [slot],
    );
    
    // Criar documento do dia (sem pattern metadata)
    return AvailabilityDayEntity(
      date: DateTime(date.year, date.month, date.day),
      generatedFrom: PatternMetadata(
        patternId: SlotManager.generatePatternId(),
        creationType: 'manual',
        createdAt: now,
      ),
      isOverridden: false,
      addresses: [addressAvailability],
      createdAt: now,
    );
  }
  
  /// Converte weekday do DateTime para código (MO, TU, etc)
  static String _getWeekdayCode(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        throw ArgumentError('Invalid weekday: $weekday');
    }
  }
  
  /// Converte código (MO, TU, etc) para weekday do DateTime
  static int codeToWeekday(String code) {
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
        throw ArgumentError('Invalid weekday code: $code');
    }
  }
  
  /// Mapeia nomes em português para códigos
  static final Map<String, String> weekdayNamesToCodes = {
    'Segunda': 'MO',
    'Terça': 'TU',
    'Quarta': 'WE',
    'Quinta': 'TH',
    'Sexta': 'FR',
    'Sábado': 'SA',
    'Domingo': 'SU',
  };
  
  /// Mapeia códigos para nomes em português
  static final Map<String, String> weekdayCodesToNames = {
    'MO': 'Segunda',
    'TU': 'Terça',
    'WE': 'Quarta',
    'TH': 'Quinta',
    'FR': 'Sexta',
    'SA': 'Sábado',
    'SU': 'Domingo',
  };
}
