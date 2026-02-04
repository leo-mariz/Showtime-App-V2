import 'package:app/core/utils/timestamp_hook.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'pattern_metadata_entity.mapper.dart';

/// Metadata sobre o padrão de recorrência que gerou este dia
/// 
/// Permite rastrear e editar múltiplos dias de uma vez
@MappableClass(hook: TimestampHook())
class PatternMetadata with PatternMetadataMappable {
  /// ID único do padrão (todos os dias gerados do mesmo padrão têm o mesmo ID)
  final String patternId;
  
  /// Tipo de criação: recurring_pattern, manual, bulk_edit
  final String creationType;
  
  /// Configurações originais do padrão de recorrência
  final RecurrenceSettings? recurrence;
  
  /// Data de criação do padrão
  final DateTime createdAt;
  
  /// Última modificação do padrão
  final DateTime? updatedAt;
  
  const PatternMetadata({
    required this.patternId,
    required this.creationType,
    this.recurrence,
    required this.createdAt,
    this.updatedAt,
  });
}

/// Configurações de recorrência original
@MappableClass(hook: TimestampHook())
class RecurrenceSettings with RecurrenceSettingsMappable {
  /// Dias da semana (MO, TU, WE, TH, FR, SA, SU)
  final List<String>? weekdays;
  
  /// Período original
  final DateTime originalStartDate;
  final DateTime originalEndDate;
  
  /// Configurações originais de horário
  final String originalStartTime;
  final String originalEndTime;
  
  /// Valor original por hora
  final double originalValorHora;
  
  /// Endereço original
  final String originalAddressId;
  
  const RecurrenceSettings({
    this.weekdays,
    required this.originalStartDate,
    required this.originalEndDate,
    required this.originalStartTime,
    required this.originalEndTime,
    required this.originalValorHora,
    required this.originalAddressId,
  });
}
