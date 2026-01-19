import 'package:app/core/domain/addresses/address_info_entity.dart';
import 'package:app/core/domain/artist/availability/time_slot_entity.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'address_availability_entity.mapper.dart';

/// Disponibilidade de um endereço específico em um dia
/// 
/// Um dia pode ter disponibilidade em múltiplos endereços
@MappableClass()
class AddressAvailabilityEntity with AddressAvailabilityEntityMappable {
  /// ID do endereço
  final String addressId;
  
  /// Raio de atuação em km
  final double raioAtuacao;
  
  /// Informações completas do endereço
  final AddressInfoEntity endereco;
  
  /// Slots de tempo disponíveis neste endereço
  final List<TimeSlot> slots;
  
  const AddressAvailabilityEntity({
    required this.addressId,
    required this.raioAtuacao,
    required this.endereco,
    required this.slots,
  });
  
  /// Verifica se tem algum slot disponível neste endereço
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
}
