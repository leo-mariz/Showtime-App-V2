import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/pattern_metadata_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:app/core/utils/timestamp_hook.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'availability_entry_entity.mapper.dart';

/// Representa uma entrada de disponibilidade independente dentro de um dia
/// 
/// Cada entry corresponde a uma disponibilidade específica que pode ter sido:
/// - Gerada de um padrão de recorrência
/// - Criada manualmente
/// - Editada individualmente (override)
/// 
/// Estrutura simplificada:
/// - 1 endereço base + raio por disponibilidade
/// - Múltiplos slots de tempo com valores/h individuais
@MappableClass(hook: TimestampHook())
class AvailabilityEntry with AvailabilityEntryMappable {
  /// ID único desta disponibilidade
  final String availabilityId;
  
  /// Metadata sobre o padrão que gerou esta disponibilidade (se houver)
  final PatternMetadata? generatedFrom;
  
  // ========== ENDEREÇO E RAIO ==========
  
  /// ID do endereço base
  final String addressId;
  
  /// Raio de atuação em km a partir do endereço base
  final double raioAtuacao;
  
  /// Informações completas do endereço base
  final AddressInfoEntity endereco;
  
  // ========== SLOTS DE TEMPO ==========
  
  /// Slots de tempo com valores/h individuais
  /// 
  /// Cada slot pode ter:
  /// - Horário específico (startTime - endTime)
  /// - Valor/hora próprio
  /// - Status (disponível, bloqueado, reservado)
  final List<TimeSlot> slots;
  
  // ========== METADATA ==========
  
  /// Indica se esta disponibilidade foi editada manualmente
  /// 
  /// Quando true, futuras edições do padrão NÃO afetam esta entry
  final bool isManualOverride;
  
  /// Data de criação desta entry
  final DateTime createdAt;
  
  /// Última atualização desta entry
  final DateTime? updatedAt;
  
  const AvailabilityEntry({
    required this.availabilityId,
    this.generatedFrom,
    required this.addressId,
    required this.raioAtuacao,
    required this.endereco,
    required this.slots,
    this.isManualOverride = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  // ========== COMPUTED PROPERTIES ==========
  
  /// Verifica se esta entry tem slots disponíveis
  bool get hasAvailableSlots => slots.any((slot) => slot.isAvailable);
  
  /// Retorna apenas slots disponíveis
  List<TimeSlot> get availableSlots => 
      slots.where((slot) => slot.isAvailable).toList();
  
  /// Retorna slots bloqueados
  List<TimeSlot> get blockedSlots => 
      slots.where((slot) => slot.isBlocked).toList();
  
  /// Retorna slots reservados
  List<TimeSlot> get bookedSlots => 
      slots.where((slot) => slot.isBooked).toList();
  
  /// Retorna o ID do padrão (se existir)
  String? get patternId => generatedFrom?.patternId;
  
  /// Verifica se foi gerada de um padrão
  bool get isFromPattern => generatedFrom != null;
  
  /// Verifica se pode ser editada via "editar padrão"
  /// (só se foi gerada de padrão e não foi manualmente editada)
  bool get canUpdateViaPattern => isFromPattern && !isManualOverride;
  
  /// Retorna o menor valor/hora entre os slots disponíveis
  double? get minValorHora {
    final available = availableSlots;
    if (available.isEmpty) return null;
    
    final values = available
        .map((s) => s.valorHora)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    return values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b);
  }
  
  /// Retorna o maior valor/hora entre os slots disponíveis
  double? get maxValorHora {
    final available = availableSlots;
    if (available.isEmpty) return null;
    
    final values = available
        .map((s) => s.valorHora)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    return values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b);
  }
  
  /// Retorna o valor/hora médio dos slots disponíveis
  double? get avgValorHora {
    final available = availableSlots;
    if (available.isEmpty) return null;
    
    final values = available
        .map((s) => s.valorHora)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    if (values.isEmpty) return null;
    
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }
}
