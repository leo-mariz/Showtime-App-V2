import 'package:app/core/domain/addresses/address_info_entity.dart';

/// DTO base para operações de disponibilidade
/// Contém apenas a data, comum a todas operações
abstract class AvailabilityOperationDto {
  final DateTime date;

  const AvailabilityOperationDto({required this.date});
}

// ════════════════════════════════════════════════════════════════════════════
// DTOs de Dados (Informações reutilizáveis)
// ════════════════════════════════════════════════════════════════════════════

/// DTO para informações de slot de horário
/// Usado para criar, atualizar ou deletar slots
class TimeSlotDto {
  final String? slotId; // null = criar novo, preenchido = update/delete
  final String? startTime; // null = não atualizar
  final String? endTime; // null = não atualizar
  final double? valorHora; // null = não atualizar

  const TimeSlotDto({
    this.slotId,
    this.startTime,
    this.endTime,
    this.valorHora,
  });

  /// Factory para criação de novo slot (sem slotId)
  factory TimeSlotDto.create({
    required String startTime,
    required String endTime,
    required double valorHora,
  }) {
    return TimeSlotDto(
      slotId: null,
      startTime: startTime,
      endTime: endTime,
      valorHora: valorHora,
    );
  }

  /// Factory para atualização de slot (com slotId)
  factory TimeSlotDto.update({
    required String slotId,
    String? startTime,
    String? endTime,
    double? valorHora,
  }) {
    return TimeSlotDto(
      slotId: slotId,
      startTime: startTime,
      endTime: endTime,
      valorHora: valorHora,
    );
  }

  /// Factory para deleção de slot (só precisa do slotId)
  factory TimeSlotDto.delete({
    required String slotId,
  }) {
    return TimeSlotDto(slotId: slotId);
  }

  /// Verifica se é operação de criação (sem slotId)
  bool get isCreate => slotId == null;

  /// Verifica se é operação de update/delete (com slotId)
  bool get isUpdate => slotId != null;
}

/// DTO para informações de endereço e raio
class AddressRadiusDto {
  final String addressId;
  final double raioAtuacao;
  final AddressInfoEntity endereco;

  const AddressRadiusDto({
    required this.addressId,
    required this.raioAtuacao,
    required this.endereco,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// DTOs de Operações (Composição dos DTOs de dados)
// ════════════════════════════════════════════════════════════════════════════

/// DTO para buscar disponibilidade de um dia específico
class GetAvailabilityByDateDto extends AvailabilityOperationDto {
  final bool forceRemote;

  const GetAvailabilityByDateDto({
    required super.date,
    this.forceRemote = false,
  });
}

/// DTO para ativar/desativar disponibilidade
class ToggleAvailabilityStatusDto extends AvailabilityOperationDto {
  final bool isActive;

  const ToggleAvailabilityStatusDto({
    required super.date,
    required this.isActive,
  });
}

/// DTO para atualizar endereço e raio
class UpdateAddressRadiusDto extends AvailabilityOperationDto {
  final AddressRadiusDto addressRadius;

  const UpdateAddressRadiusDto({
    required super.date,
    required this.addressRadius,
  });
}

/// DTO para operações com slots (add, update, delete)
class SlotOperationDto extends AvailabilityOperationDto {
  final TimeSlotDto slot;
  final bool deleteIfEmpty; // Usado apenas em delete

  const SlotOperationDto({
    required super.date,
    required this.slot,
    this.deleteIfEmpty = false,
  });

  /// Factory para adicionar slot
  factory SlotOperationDto.add({
    required DateTime date,
    required String startTime,
    required String endTime,
    required double valorHora,
  }) {
    return SlotOperationDto(
      date: date,
      slot: TimeSlotDto.create(
        startTime: startTime,
        endTime: endTime,
        valorHora: valorHora,
      ),
    );
  }

  /// Factory para atualizar slot
  factory SlotOperationDto.update({
    required DateTime date,
    required String slotId,
    String? startTime,
    String? endTime,
    double? valorHora,
  }) {
    return SlotOperationDto(
      date: date,
      slot: TimeSlotDto.update(
        slotId: slotId,
        startTime: startTime,
        endTime: endTime,
        valorHora: valorHora,
      ),
    );
  }

  /// Factory para deletar slot
  factory SlotOperationDto.delete({
    required DateTime date,
    required String slotId,
    bool deleteIfEmpty = false,
  }) {
    return SlotOperationDto(
      date: date,
      slot: TimeSlotDto.delete(slotId: slotId),
      deleteIfEmpty: deleteIfEmpty,
    );
  }
}
