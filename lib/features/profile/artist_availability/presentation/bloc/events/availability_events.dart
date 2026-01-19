import 'package:app/features/profile/artist_availability/domain/dtos/availability_dto.dart';

/// Eventos base para Availability
abstract class AvailabilityEvent {}

/// Evento para buscar disponibilidades
class GetAvailabilityEvent extends AvailabilityEvent {
  final GetAvailabilityDto dto;
  
  GetAvailabilityEvent(this.dto);
}

/// Evento para criar disponibilidade
class CreateAvailabilityEvent extends AvailabilityEvent {
  final CreateAvailabilityDto dto;
  
  CreateAvailabilityEvent(this.dto);
}

/// Evento para atualizar disponibilidade
class UpdateAvailabilityEvent extends AvailabilityEvent {
  final UpdateAvailabilityDto dto;
  
  UpdateAvailabilityEvent(this.dto);
}

/// Evento para deletar disponibilidade
class DeleteAvailabilityEvent extends AvailabilityEvent {
  final DeleteAvailabilityDto dto;
  
  DeleteAvailabilityEvent(this.dto);
}

/// Evento para resetar estado
class ResetAvailabilityStateEvent extends AvailabilityEvent {}
