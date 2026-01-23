import 'package:equatable/equatable.dart';
import 'package:app/core/domain/artist/availability/availability_day_entity.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlap_on_day_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/check_overlaps_dto.dart';
import 'package:app/features/profile/artist_availability/domain/dtos/open_period_dto.dart';

abstract class AvailabilityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AvailabilityInitialEvent extends AvailabilityEvent {}

// ==================== GET ALL AVAILABILITIES EVENTS ====================

/// Evento para buscar todas as disponibilidades de um artista
class GetAllAvailabilitiesEvent extends AvailabilityEvent {
  final bool forceRemote;

  GetAllAvailabilitiesEvent({
    this.forceRemote = false,
  });

  @override
  List<Object?> get props => [forceRemote];
}

// ==================== TOGGLE AVAILABILITY STATUS EVENTS ====================

/// Evento para ativar/desativar disponibilidade de um dia
class ToggleAvailabilityStatusEvent extends AvailabilityEvent {
  final DateTime date;
  final bool isActive;

  ToggleAvailabilityStatusEvent({
    required this.date,
    required this.isActive,
  });

  @override
  List<Object?> get props => [date, isActive];
}

// ==================== CHECK OVERLAP ON DAY EVENTS ====================

/// Evento para verificar overlaps em um único dia
class GetOrganizedDayAfterVerificationEvent extends AvailabilityEvent {
  final DateTime date;
  final CheckOverlapOnDayDto dto;

  GetOrganizedDayAfterVerificationEvent({
    required this.date,
    required this.dto,
  });

  @override
  List<Object?> get props => [date, dto];
}

// ==================== CHECK OVERLAPS ON PERIOD EVENTS ====================

/// Evento para verificar overlaps em um período (múltiplos dias)
class GetOrganizedAvailabilitiesAfterVerificationEvent extends AvailabilityEvent {
  final CheckOverlapsDto dto;
  final bool isClose;

  GetOrganizedAvailabilitiesAfterVerificationEvent({
    required this.dto,
    required this.isClose,
  });

  @override
  List<Object?> get props => [dto, isClose];
}

// ==================== OPEN PERIOD EVENTS ====================

/// Evento para abrir um período de disponibilidade
class OpenPeriodEvent extends AvailabilityEvent {
  final OpenPeriodDto dto;

  OpenPeriodEvent({
    required this.dto,
  });

  @override
  List<Object?> get props => [dto];
}

// ==================== CLOSE PERIOD EVENTS ====================

/// Evento para fechar um período de disponibilidade
class ClosePeriodEvent extends AvailabilityEvent {
  final OpenPeriodDto dto;

  ClosePeriodEvent({
    required this.dto,
  });

  @override
  List<Object?> get props => [dto];
}

// ==================== UPDATE AVAILABILITY DAY EVENTS ====================

/// Evento para atualizar disponibilidade de um dia (toggle isActive)
class ToggleAvailabilityDayEvent extends AvailabilityEvent {
  final AvailabilityDayEntity dayEntity;

  ToggleAvailabilityDayEvent({
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [dayEntity];
}

/// Evento para adicionar um slot a um dia
class AddTimeSlotEvent extends AvailabilityEvent {
  final AvailabilityDayEntity dayEntity;

  AddTimeSlotEvent({
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [dayEntity];
}

/// Evento para atualizar um slot existente
class UpdateTimeSlotEvent extends AvailabilityEvent {
  final AvailabilityDayEntity dayEntity;

  UpdateTimeSlotEvent({
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [dayEntity];
}

/// Evento para deletar um slot
class DeleteTimeSlotEvent extends AvailabilityEvent {
  final AvailabilityDayEntity dayEntity;

  DeleteTimeSlotEvent({
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [dayEntity];
}

/// Evento para atualizar endereço e raio de atuação
class UpdateAddressAndRadiusEvent extends AvailabilityEvent {
  final AvailabilityDayEntity dayEntity;

  UpdateAddressAndRadiusEvent({
    required this.dayEntity,
  });

  @override
  List<Object?> get props => [dayEntity];
}
