import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';

/// Eventos base para Availability
abstract class AvailabilityEvent {}

// ════════════════════════════════════════════════════════════════════════════
// Eventos de Consulta
// ════════════════════════════════════════════════════════════════════════════

/// Evento para buscar todas as disponibilidades
class GetAllAvailabilitiesEvent extends AvailabilityEvent {
  final bool forceRemote;

  GetAllAvailabilitiesEvent({
    this.forceRemote = false,
  });
}

/// Evento para buscar disponibilidade de um dia específico
class GetAvailabilityByDateEvent extends AvailabilityEvent {
  final GetAvailabilityByDateDto dto;

  GetAvailabilityByDateEvent(this.dto);
}

// ════════════════════════════════════════════════════════════════════════════
// Eventos de Disponibilidade do Dia
// ════════════════════════════════════════════════════════════════════════════

/// Evento para ativar/desativar disponibilidade
class ToggleAvailabilityStatusEvent extends AvailabilityEvent {
  final ToggleAvailabilityStatusDto dto;

  ToggleAvailabilityStatusEvent(this.dto);
}

/// Evento para atualizar endereço e raio
class UpdateAddressRadiusEvent extends AvailabilityEvent {
  final UpdateAddressRadiusDto dto;

  UpdateAddressRadiusEvent(this.dto);
}

// ════════════════════════════════════════════════════════════════════════════
// Eventos de Slots
// ════════════════════════════════════════════════════════════════════════════

/// Evento para adicionar slot de horário
class AddTimeSlotEvent extends AvailabilityEvent {
  final SlotOperationDto dto;

  AddTimeSlotEvent(this.dto);
}

/// Evento para atualizar slot de horário
class UpdateTimeSlotEvent extends AvailabilityEvent {
  final SlotOperationDto dto;

  UpdateTimeSlotEvent(this.dto);
}

/// Evento para deletar slot de horário
class DeleteTimeSlotEvent extends AvailabilityEvent {
  final SlotOperationDto dto;

  DeleteTimeSlotEvent(this.dto);
}

// ════════════════════════════════════════════════════════════════════════════
// Eventos de Controle
// ════════════════════════════════════════════════════════════════════════════

/// Evento para resetar o estado
class ResetAvailabilityEvent extends AvailabilityEvent {}
